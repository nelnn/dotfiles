-- Run from the Neovim config directory:
-- nvim --headless -u NONE -l tests/clickhouse_query.lua
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
  .. "/lua/plugins/custom/clickhouse.lua"
vim.env.CLICKHOUSE_USERNAME, vim.env.CLICKHOUSE_PASSWORD = "test", "test"
local commands, notification = {}, nil
vim.api.nvim_create_user_command = function(name, callback) commands[name] = callback end
vim.notify = function(message) notification = message end
dofile(plugin)

local function current_query(command)
  for i = 1, math.huge do
    local name, value = debug.getupvalue(commands[command], i)
    assert(name, "Missing current_query")
    if name == "current_query" then return value() end
  end
end

local function check(sql, row, col, expected)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(sql, "\n", { plain = true }))
  vim.api.nvim_win_set_cursor(0, { row, col })
  for _, command in ipairs({ "ClickHouse", "ClickHouseVisiDataPane", "ClickHouseVisiDataTab" }) do
    notification = nil
    local sent = current_query(command)
    if expected then
      assert(sent == expected, command .. ": " .. tostring(sent))
      assert(notification == nil, notification)
    else
      assert(sent == nil, command .. " must not execute outside a statement")
      assert(notification == "Put the cursor inside a SQL statement", tostring(notification))
    end
  end
end

local describe = "DESCRIBE TABLE ls_raw.insight;\n\n-- shorthand\nDESC ls_raw.insight;"
check(describe, 1, 0, "DESCRIBE TABLE ls_raw.insight")
check(describe, 1, 29, "DESCRIBE TABLE ls_raw.insight")
check(describe, 4, 0, "\n\n-- shorthand\nDESC ls_raw.insight")

local invalid = "with cte as (\nselect *\nfrom sensorium.property)\nselect * from cte 100"
check(invalid .. ";", 2, 0, invalid)
check(invalid .. ";", 4, 19, invalid) -- Cursor on the error node.
check(invalid, 2, 0, invalid) -- No final semicolon.
check(invalid .. ";\n\n", 5, 0, nil) -- Blank line below the query.
check(invalid .. ";\n\n", 6, 0, nil)
check(invalid .. "\n\n", 5, 0, nil)
check(invalid .. ";\nselect 2;", 2, 0, invalid)
check(invalid .. ";\nselect 2;", 5, 0, "\nselect 2")
check("select ';' as value; select 2;", 1, 8, "select ';' as value")
check("select 1 /* ; */; select 2;", 1, 7, "select 1 /* ; */")
print("ClickHouse query extraction checks passed")
