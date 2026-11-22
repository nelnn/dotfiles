#!/usr/bin/env python3
"""Check rendered Mac Neovim without installing plugins or touching live config."""
import io
import json
import os
from pathlib import Path
import subprocess
import tarfile
import tempfile

source = Path(__file__).resolve().parents[1]
override = json.dumps({'profile': 'mac', 'chezmoi': {'os': 'darwin'}})
payload = subprocess.check_output(['chezmoi', '--source', str(source), '--override-data', override,
                                   'archive', '--format', 'tar'])
with tempfile.TemporaryDirectory(prefix='mac-nvim-test-') as temporary:
    root = Path(temporary)
    config = root / 'config/nvim'
    with tarfile.open(fileobj=io.BytesIO(payload)) as archive:
        files = {m.name: archive.extractfile(m).read() for m in archive.getmembers()
                 if m.isfile() and m.name.startswith('.config/nvim/')}
    assert not any('clickhouse' in p.lower() or b'clickhouse' in body.lower() for p, body in files.items())
    for name, body in files.items():
        path = config / name.removeprefix('.config/nvim/')
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(body)
    test = root / 'test.lua'
    test.write_text(r'''
local root = assert(vim.env.TEST_NVIM_CONFIG)
vim.opt.rtp:prepend(root)
local lua_files = vim.fn.glob(root .. "/**/*.lua", false, true)
for _, path in ipairs(lua_files) do assert(loadfile(path)) end

-- Verify init resolves the correct lazy path, but never clone or install plugins.
local expected_lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local fs_stat = vim.uv.fs_stat
vim.uv.fs_stat = function(path)
  if path == expected_lazy then return { type = "directory" } end
  return fs_stat(path)
end
package.preload.lazy = function()
  return { setup = function(spec) assert(spec == "plugins") end }
end
dofile(root .. "/init.lua")
assert(vim.opt.rtp:get()[1] == expected_lazy)
assert(vim.g.mapleader == " ")

-- Key callbacks use argv lists, including cwd with spaces, never shell concatenation.
local jobs = {}
vim.fn.executable = function() return 1 end
vim.fn.jobstart = function(argv, opts)
  jobs[#jobs + 1] = { argv = argv, opts = opts }
  return 1
end
local function invoke(lhs)
  local mapping = vim.fn.maparg(lhs, "n", false, true)
  assert(type(mapping.callback) == "function", lhs)
  mapping.callback()
end
vim.env.TMUX = "test"
invoke(" gg")
assert(vim.deep_equal(jobs[1].argv, { "tmux", "new-window", "-c", vim.fn.getcwd(), "lazygit" }))
vim.env.TMUX = nil
invoke(" y")
assert(jobs[2].argv[1] == "yazi" and jobs[2].opts.term)
vim.cmd("stopinsert")

local specs = dofile(root .. "/lua/plugins/init.lua")
local navigation
for _, spec in ipairs(specs) do
  if type(spec) == "table" and spec[1] == "christoomey/vim-tmux-navigator" then navigation = spec end
end
assert(navigation and not navigation.config, "must not source an external Herdr script")
navigation.init()
for _, key in ipairs(navigation.keys) do vim.keymap.set("n", key[1], key[2]) end
for key, command in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
  assert(vim.fn.maparg("<C-" .. key .. ">", "n"):find("TmuxNavigate" .. command))
end

local dap = { configurations = { python = {} }, listeners = { before = {
  attach = {}, launch = {}, event_terminated = {}, event_exited = {},
} } }
for _, name in ipairs({ "continue", "restart", "terminate", "toggle_breakpoint", "step_into", "step_over", "step_out" }) do
  dap[name] = function() end
end
package.loaded.dap = dap
package.loaded.dapui = { setup = function() end, open = function() end, toggle = function() end }
local debugpy
package.loaded["dap-python"] = { setup = function(path) debugpy = path end }
for _, spec in ipairs(dofile(root .. "/lua/plugins/dev-tools.lua")) do
  if spec[1] == "mfussenegger/nvim-dap" then spec.config() end
end
assert(debugpy == vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
assert(vim.fn.maparg(" dd", "n", false, true).callback == dap.continue)

vim.keymap.set("n", "<leader>gf", function() end, { buffer = true })
dofile(root .. "/after/ftplugin/csv.lua")
assert(vim.fn.maparg(" cv", "n"):find("CsvViewToggle"))
assert(type(vim.fn.maparg(" gf", "n", false, true).callback) == "function")
print("Mac Neovim: Lua syntax, bootstrap paths, tool launchers, navigation, DAP and CSV bindings OK")
''')
    env = dict(os.environ, XDG_CONFIG_HOME=str(root / 'config'), XDG_DATA_HOME=str(root / 'data'),
               XDG_STATE_HOME=str(root / 'state'), XDG_CACHE_HOME=str(root / 'cache'),
               TEST_NVIM_CONFIG=str(config))
    subprocess.run(['nvim', '--headless', '-u', 'NONE', '-i', 'NONE', '-l', str(test)], env=env, check=True)
