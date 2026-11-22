--- Run the SQL statement under the cursor against ClickHouse: into a scratch
--- buffer (`:ClickHouse`) or into VisiData in a Herdr pane/tab.

local PORT = 8123
local PREVIEW_ROWS = 100

---The SQL statement the cursor sits in, or nil (notifies) if it sits between statements.
---@return string?
local function current_query()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local position = vim.api.nvim_buf_get_offset(0, cursor[1] - 1) + cursor[2]
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
  local root = vim.treesitter.get_parser(0, "sql"):parse()[1]:root()
  local boundaries = {}

  -- ERROR nodes can contain several statements; only SQL delimiter tokens split them.
  ---@param node TSNode
  local function delimiters(node)
    if node:type() == ";" then
      local _, _, byte = node:start()
      boundaries[#boundaries + 1] = byte
    else
      for child in node:iter_children() do delimiters(child) end
    end
  end
  delimiters(root)
  boundaries[#boundaries + 1] = #text

  local start = 0
  for _, finish in ipairs(boundaries) do
    if position <= finish then
      local query = text:sub(start + 1, finish)
      local first, last = query:find("%S"), query:match(".*()%S")
      if first and position >= start + first - 1
        and (position < start + last or text:sub(position + 1, position + 1) == ";") then
        return query
      end
      break
    end
    start = finish + 1
  end

  vim.notify("Put the cursor inside a SQL statement", vim.log.levels.ERROR)
end

---A `curl` argv posting the query (read from stdin) to ClickHouse.
---@param params string URL query string, e.g. `"default_format=CSVWithNames"`.
---@return string[]
local function curl_args(params)
  return {
    "curl", "--show-error", "--fail-with-body",
    "http://localhost:" .. PORT .. "/?" .. params,
    "-H", "X-ClickHouse-User: " .. assert(os.getenv("CLICKHOUSE_USERNAME")),
    "-H", "X-ClickHouse-Key: " .. assert(os.getenv("CLICKHOUSE_PASSWORD")),
    "--data-binary", "@-",
  }
end

---Create a user command acting on the statement under the cursor.
---@param name string
---@param fn fun(query: string)
local function query_command(name, fn)
  vim.api.nvim_create_user_command(name, function()
    local query = current_query()
    if query then fn(query) end
  end, {})
end

---Run `query` and drop the pretty-printed result into a scratch buffer.
---@param query string
local function show_in_buffer(query)
  local args = curl_args("default_format=PrettyCompact&output_format_pretty_grid_charset=ASCII"
    .. "&output_format_pretty_color=0&output_format_pretty_max_value_width=30")
  vim.system(args, { stdin = query, text = true }, vim.schedule_wrap(function(result)
    vim.cmd("new")
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = 0, silent = true })
    local output = (result.code == 0 or result.stdout ~= "") and result.stdout or result.stderr
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n"))
  end))
end

query_command("ClickHouse", show_in_buffer)

---A `$'...'` shell literal, safe for newlines and quotes.
---@param value string
---@return string
local function shell_string(value)
  return "$'" .. value:gsub("[\\'\n\r\t]", {
    ["\\"] = "\\\\", ["'"] = "\\'", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t",
  }) .. "'"
end

---A shell command piping the query's CSV result into VisiData. On failure the error is
---printed and the shell waits for `q`, since the caller closes the pane afterwards.
---@param query string
---@return string
local function visidata_command(query)
  local args = curl_args("default_format=CSVWithNames")
  table.remove(args) -- drop `@-`: the query is passed as an argument, not on stdin
  return 'ch_output=$(mktemp) && { if '
    .. table.concat(vim.tbl_map(vim.fn.shellescape, args), " ")
    .. " " .. shell_string(query:gsub("%s*;?%s*$", "") .. ";")
    .. ' > "$ch_output"; then visidata -f csv - < "$ch_output";'
    .. ' else cat "$ch_output" >&2; printf "\\nPress q to close..." >&2;'
    -- `.` is the sentinel command substitution cannot strip: a bare one means EOF (no tty).
    .. ' tty=$(stty -g 2>/dev/null) && stty -icanon -echo min 1;'
    .. ' while :; do key=$(dd bs=1 count=1 2>/dev/null; printf .);'
    .. ' case $key in "q."|".") break;; esac; done;'
    .. ' [ -n "$tty" ] && stty "$tty";'
    .. ' fi; rm -f "$ch_output"; }'
end

---Run `herdr <args...>` and hand the decoded `result` field to `callback`.
---@param args string[]
---@param callback? fun(result: table)
local function run_herdr(args, callback)
  if vim.env.HERDR_ENV ~= "1" then
    vim.notify("ClickHouse VisiData commands require Herdr", vim.log.levels.ERROR)
    return
  end

  vim.system(vim.list_extend({ "herdr" }, args), { text = true }, vim.schedule_wrap(function(result)
    if result.code ~= 0 then
      vim.notify(result.stderr ~= "" and result.stderr or "Herdr command failed", vim.log.levels.ERROR)
    elseif callback then
      callback(vim.json.decode(result.stdout).result)
    end
  end))
end

---@type string? Pane id of the last VisiData split, reused so only one stays open.
local clickhouse_pane

query_command("ClickHouseVisiDataPane", function(query)
  local command = visidata_command(query)

  local function open()
    run_herdr({ "pane", "split", "--current", "--direction", "down", "--cwd", vim.fn.getcwd(), "--focus" }, function(result)
      clickhouse_pane = result.pane.pane_id
      run_herdr({ "pane", "run", clickhouse_pane, command .. "; herdr pane close " .. vim.fn.shellescape(clickhouse_pane) })
    end)
  end

  if not clickhouse_pane then return open() end
  -- The pane closes itself when VisiData exits, so the id may already be stale.
  run_herdr({ "pane", "list", "--workspace", vim.env.HERDR_WORKSPACE_ID }, function(result)
    if vim.tbl_contains(vim.tbl_map(function(pane) return pane.pane_id end, result.panes), clickhouse_pane) then
      return run_herdr({ "pane", "close", clickhouse_pane }, open)
    end
    open()
  end)
end)

query_command("ClickHouseVisiDataTab", function(query)
  local command = visidata_command(query)
  local current_tab = vim.env.HERDR_TAB_ID
  run_herdr({ "tab", "create", "--workspace", vim.env.HERDR_WORKSPACE_ID, "--cwd", vim.fn.getcwd(), "--focus" }, function(result)
    run_herdr({ "pane", "run", result.root_pane.pane_id, command
      .. "; herdr tab focus " .. vim.fn.shellescape(current_tab)
      .. "; herdr tab close " .. vim.fn.shellescape(result.tab.tab_id) })
  end)
end)

---Run `sql` and hand the tab-separated result rows to `callback`.
---@param sql string
---@param callback fun(rows: string[])
local function fetch(sql, callback)
  vim.system(curl_args("default_format=TSV"), { stdin = sql, text = true }, vim.schedule_wrap(function(result)
    if result.code ~= 0 then
      return vim.notify(result.stdout ~= "" and result.stdout or result.stderr, vim.log.levels.ERROR)
    end
    callback(vim.split(vim.trim(result.stdout), "\n", { trimempty = true }))
  end))
end

---@class ch.Node A row of the schema tree.
---@field label string Text shown after the indent.
---@field name string? Column name, for `column` nodes.
---@field kind "database"|"table"|"column"
---@field depth integer
---@field db string? Owning database, for `table` nodes.
---@field expanded boolean
---@field children ch.Node[]? Fetched on first expand.

local sidebar = { buf = nil, root = {}, lines = {} }

---Append the visible nodes to `lines` (display text) and `sidebar.lines` (line -> node).
---@param nodes ch.Node[]
---@param lines string[]
local function flatten(nodes, lines)
  for _, node in ipairs(nodes) do
    sidebar.lines[#sidebar.lines + 1] = node
    lines[#lines + 1] = ("  "):rep(node.depth)
      .. (node.kind == "column" and "  " or node.expanded and "v " or "> ") .. node.label
    if node.expanded and node.children then flatten(node.children, lines) end
  end
end

local function render()
  local lines = {}
  sidebar.lines = {}
  flatten(sidebar.root, lines)
  vim.bo[sidebar.buf].modifiable = true
  vim.api.nvim_buf_set_lines(sidebar.buf, 0, -1, false, lines)
  vim.bo[sidebar.buf].modifiable = false
end

---Fetch `node`'s children, then redraw.
---@param node ch.Node
local function expand(node)
  if node.kind == "database" then
    fetch("SHOW TABLES FROM `" .. node.label .. "`", function(rows)
      node.children = vim.tbl_map(function(name)
        return { label = name, kind = "table", depth = 1, db = node.label, expanded = false }
      end, rows)
      render()
    end)
  else
    fetch("DESCRIBE `" .. node.db .. "`.`" .. node.label .. "`", function(rows)
      node.children = vim.tbl_map(function(row)
        -- DESCRIBE yields name, type, default_kind, ...; only the first two matter.
        local name, type_ = row:match("^([^\t]*)\t([^\t]*)")
        return { label = ("%-30s %s"):format(name or row, type_ or ""), name = name or row,
          kind = "column", depth = 2, expanded = false }
      end, rows)
      render()
    end)
  end
end

---`<CR>`: fold a database or table, or put a column name in the window you came from.
local function toggle()
  local node = sidebar.lines[vim.api.nvim_win_get_cursor(0)[1]]
  if not node then return end
  if node.kind == "column" then
    vim.cmd.wincmd("p")
    return vim.api.nvim_put({ node.name }, "", true, true)
  end
  node.expanded = not node.expanded
  if node.expanded and not node.children then return expand(node) end
  render()
end

---`p`: show the SELECT that would preview a table's rows, and run it if confirmed.
local function preview()
  local node = sidebar.lines[vim.api.nvim_win_get_cursor(0)[1]]
  if not node or node.kind ~= "table" then return end
  local query = ("SELECT * FROM `%s`.`%s` LIMIT %d"):format(node.db, node.label, PREVIEW_ROWS)
  if vim.fn.confirm(query, "&Run\n&Cancel", 2) ~= 1 then return end
  vim.cmd.wincmd("p") -- the result splits the editing window, not the narrow sidebar
  show_in_buffer(query)
end

-- Databases -> tables -> columns, in a tree buffer on the left. `p` previews a table.
-- Closing it (`q`) drops the cached tree, so reopening refreshes.
vim.api.nvim_create_user_command("ClickHouseSchema", function()
  local win = sidebar.buf and vim.fn.bufwinid(sidebar.buf) or -1
  if win ~= -1 then return vim.api.nvim_set_current_win(win) end

  fetch("SHOW DATABASES", function(databases)
    vim.cmd("vertical topleft 40new")
    sidebar.buf = vim.api.nvim_get_current_buf()
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
    vim.wo.number, vim.wo.relativenumber, vim.wo.winfixwidth = false, false, true
    vim.keymap.set("n", "<cr>", toggle, { buffer = sidebar.buf })
    vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = sidebar.buf })
    vim.keymap.set("n", "p", preview, { buffer = sidebar.buf })
    sidebar.root = vim.tbl_map(function(name)
      return { label = name, kind = "database", depth = 0, expanded = false }
    end, databases)
    render()
  end)
end, {})

vim.keymap.set("n", "<leader>ch", "<cmd>ClickHouseVisiDataPane<cr>", { desc = "ClickHouse in pane" })
vim.keymap.set("n", "<leader>Ch", "<cmd>ClickHouseVisiDataTab<cr>", { desc = "ClickHouse in tab" })
vim.keymap.set("n", "<leader>bch", "<cmd>ClickHouse<cr>", { desc = "ClickHouse in buffer" })
vim.keymap.set("n", "<leader>cs", "<cmd>ClickHouseSchema<cr>", { desc = "ClickHouse schema browser" })

return {}
