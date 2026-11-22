-- Run from the Neovim config directory:
-- nvim --headless -u NONE -l tests/clickhouse_visidata.lua
local plugin = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
  .. "/lua/plugins/custom/clickhouse.lua"
local commands = {}
vim.api.nvim_create_user_command = function(name, callback) commands[name] = callback end
vim.env.CLICKHOUSE_USERNAME, vim.env.CLICKHOUSE_PASSWORD = "test", "test"
dofile(plugin)

-- `query_command` wraps each command callback, so search nested closures too.
local function search(fn, wanted, seen)
  for i = 1, math.huge do
    local name, value = debug.getupvalue(fn, i)
    if not name then return nil end
    if name == wanted then return value end
    if type(value) == "function" and not seen[value] then
      seen[value] = true
      local found = search(value, wanted, seen)
      if found then return found end
    end
  end
end

local function upvalue(fn, wanted)
  return search(fn, wanted, {}) or error("Missing upvalue: " .. wanted)
end

local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp)
for _, name in ipairs({ "ClickHouseVisiDataPane", "ClickHouseVisiDataTab" }) do
  local command = upvalue(commands[name], "visidata_command")("select * from cte aoisf;")
  local captured = vim.system({ "bash", "-c",
    "curl() { printf '%s\\n' \"$@\" >&2; return 22; }; " .. command,
  }, { env = { TMPDIR = tmp }, text = true }):wait()
  assert(captured.stderr == table.concat({
    "--show-error", "--fail-with-body", "http://localhost:9440/?default_format=CSVWithNames",
    "-H", "X-ClickHouse-User: test", "-H", "X-ClickHouse-Key: test",
    "--data-binary", "select * from cte aoisf;", "",
  }, "\n") .. "\nPress q to close...", captured.stderr)
  for _, code in ipairs({ 0, 22, 7 }) do
    local body = code == 0 and 'value\n1\n' or code == 22 and 'Code: 62. SYNTAX_ERROR\n' or ''
    local script = "curl() { printf %s " .. vim.fn.shellescape(body) .. "; return " .. code .. "; }; "
      .. "visidata() { printf 'VISIDATA\\n'; cat; }; " .. command
    local result = vim.system({ "bash", "-c", script }, { env = { TMPDIR = tmp }, text = true }):wait()
    if code == 0 then
      assert(result.stdout == "VISIDATA\n" .. body, result.stdout)
      assert(result.stderr == "", result.stderr)
    else
      assert(result.stdout == "", "VisiData must not run on curl failure: " .. result.stdout)
      -- Nothing to read (stdin is a closed pipe), so the wait ends instead of spinning.
      assert(result.stderr == body .. "\nPress q to close...", result.stderr)
    end
    assert(#vim.fn.readdir(tmp) == 0, "Temporary output must be removed")
  end
end
-- The error stays up until `q`, and only `q`: earlier keys are swallowed, later ones are not.
local command = upvalue(commands.ClickHouseVisiDataPane, "visidata_command")("select 1")
local waited = vim.system({ "bash", "-c",
  "curl() { return 22; }; " .. command .. "; cat",
}, { env = { TMPDIR = tmp }, stdin = "abcqLEFTOVER", text = true }):wait()
assert(waited.stdout == "LEFTOVER", waited.stdout)
assert(#vim.fn.readdir(tmp) == 0, "Temporary output must be removed")

vim.fn.delete(tmp, "d")
print("ClickHouse VisiData error handling checks passed")
