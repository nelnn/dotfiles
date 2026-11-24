-- Run from the Neovim config directory:
-- nvim --headless -u NONE -l tests/clickhouse_schema.lua
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
  .. "/lua/plugins/custom/clickhouse.lua"
vim.env.CLICKHOUSE_USERNAME, vim.env.CLICKHOUSE_PASSWORD = "test", "test"

local commands, sent = {}, {}
vim.api.nvim_create_user_command = function(name, callback) commands[name] = callback end

-- Answer each query from a canned result instead of talking to ClickHouse.
local responses = {
  ["SHOW DATABASES"] = "default\nlogs\n",
  ["SHOW TABLES FROM `logs`"] = "events\n",
  ["DESCRIBE `logs`.`events`"] = "id\tUInt64\t\t\t\t\t\nname\tString\t\t\t\t\t\n",
}
vim.system = function(_, opts, callback)
  sent[#sent + 1] = opts.stdin
  callback({ code = 0, stdout = assert(responses[opts.stdin], "Unexpected query: " .. opts.stdin) })
  return { wait = function() end }
end
dofile(plugin)

---Run pending scheduled callbacks, then return the sidebar's lines.
local function lines()
  vim.wait(50, function() return false end)
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function press_enter_on(row)
  vim.api.nvim_win_set_cursor(0, { row, 0 })
  vim.api.nvim_feedkeys(vim.keycode("<cr>"), "x", false)
end

commands.ClickHouseSchema()
assert(vim.deep_equal(lines(), { "> default", "> logs" }), vim.inspect(lines()))

press_enter_on(2)
assert(vim.deep_equal(lines(), { "> default", "v logs", "  > events" }), vim.inspect(lines()))

vim.api.nvim_win_set_cursor(0, { 3, 0 })
vim.api.nvim_feedkeys(vim.keycode("<tab>"), "x", false)
assert(vim.deep_equal(lines(), { "> default", "v logs", "  v events",
  "      id                             UInt64", "      name                           String" }), vim.inspect(lines()))

press_enter_on(2) -- collapsing hides the loaded children without refetching
assert(vim.deep_equal(lines(), { "> default", "> logs" }), vim.inspect(lines()))
press_enter_on(2) -- reopening restores the inner state, from cache
assert(#lines() == 5, vim.inspect(lines()))

assert(vim.deep_equal(sent, { "SHOW DATABASES", "SHOW TABLES FROM `logs`", "DESCRIBE `logs`.`events`" }),
  vim.inspect(sent))
-- Enter previews tables immediately; neither preview key may prompt.
local preview_sql = "SELECT * FROM `logs`.`events` LIMIT 100"
responses[preview_sql] = "value\n1\n"
vim.fn.confirm = function() error("Preview must not ask for confirmation") end
local sidebar_win = vim.api.nvim_get_current_win()

vim.api.nvim_win_set_cursor(0, { 4, 0 })
vim.api.nvim_feedkeys("p", "x", false) -- columns must not run queries
assert(#sent == 3, vim.inspect(sent))

press_enter_on(3)
lines() -- wait for the preview buffer
assert(sent[4] == preview_sql, vim.inspect(sent))
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(0, 0, -1, false), { "value", "1", "" }))

vim.api.nvim_set_current_win(sidebar_win)
vim.api.nvim_win_set_cursor(0, { 3, 0 })
vim.api.nvim_feedkeys("p", "x", false)
lines()
assert(sent[5] == preview_sql, vim.inspect(sent))

print("ClickHouse schema tree checks passed")
