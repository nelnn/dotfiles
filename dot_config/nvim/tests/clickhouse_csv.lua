-- nvim --headless -u NONE -l tests/clickhouse_csv.lua
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
  .. "/lua/plugins/custom/clickhouse.lua"
vim.env.CLICKHOUSE_USERNAME, vim.env.CLICKHOUSE_PASSWORD = "test", "test"
local commands, notices = {}, {}
vim.api.nvim_create_user_command = function(name, callback) commands[name] = callback end
vim.notify = function(message) notices[#notices + 1] = message end
dofile(plugin)
local export = commands.ClickHouseSaveCSV
for i = 1, 10 do
  local name = debug.getupvalue(export, i)
  if name == "current_query" then debug.setupvalue(export, i, function() return "SELECT 1" end) break end
end
local path = vim.fn.tempname() .. ".csv"
vim.ui.input = function(opts, callback)
  assert(opts.completion == "file")
  callback(path)
end
local calls, code = 0, 0
local csv = '"name","value"\n"a,b","line1\nline2"\n'
vim.system = function(args, opts, callback)
  calls = calls + 1
  assert(table.concat(args, " "):find("default_format=CSVWithNames", 1, true))
  assert(opts.stdin == "SELECT 1")
  callback({ code = code, stdout = code == 0 and csv or "query failed", stderr = "" })
end
local function run()
  export()
  vim.wait(50, function() return false end)
end
local function contents()
  local f = assert(io.open(path, "rb"))
  local text = f:read("*a")
  f:close()
  return text
end
run()
assert(contents() == csv, "CSV bytes must be preserved")
vim.fn.confirm = function() return 2 end
run()
assert(calls == 1, "Declining overwrite must not run query")
vim.fn.confirm = function() return 1 end
code = 1
run()
assert(contents() == csv, "Failed query must not overwrite file")
assert(notices[#notices] == "query failed")
vim.ui.input = function(_, callback) callback(nil) end
run()
assert(calls == 2, "Cancelling must not run query")
vim.fn.delete(path)
print("ClickHouse CSV export checks passed")
