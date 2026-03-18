-- Track function history
-- Append function under the cursor to a cache file with M.save()
-- Use as a learning tool for languages

-- Global state persists across module reloads
local state = _G.FnHistory or {
  cfg        = {},
  file_cache = {}, -- history_path -> bool: avoids repeated filereadable calls
  ns         = vim.api.nvim_create_namespace('fn-history'),
}
_G.FnHistory = state

local M = {}

local defaults = {
  dir  = vim.fn.stdpath('data') .. '/fn-history',
  sign = { text = '󰋚', hl = 'DiagnosticSignInfo' },
}

-- comment prefixes
local comment_prefix = {
  c = '//',
  cpp = '//',
  h = '//',
  js = '//',
  ts = '//',
  jsx = '//',
  tsx = '//',
  java = '//',
  go = '//',
  rs = '//',
  py = '#',
  sh = '#',
  bash = '#',
  rb = '#',
  r = '#',
  lua = '--',
  hs = '--',
  elm = '--',
}

-- treesitter node types
local function_types = {
  function_definition  = true, -- C, C++, Python
  function_declaration = true, -- JS/TS
  function_item        = true, -- Rust
  method_definition    = true, -- JS/TS class methods
  method_declaration   = true, -- Java
  func_literal         = true, -- Go
  function_statement   = true, -- Lua
  local_function       = true, -- Lua
}

local class_types = {
  class_definition  = true, -- Python
  class_declaration = true, -- JS/TS, Java
  class             = true, -- JS/TS (expression form)
  class_specifier   = true, -- C++
  struct_specifier  = true, -- C++
  impl_item         = true, -- Rust
}

-- helpers
local function short_hash(s)
  local h = 5381
  for i = 1, #s do h = (h * 33 + s:byte(i)) % 0x100000000 end
  return string.format('%08x', h)
end

local function find_project_root(from)
  local path = from or vim.fn.expand('%:p:h')
  local git  = vim.fn.finddir('.git', path .. ';')
  if git ~= '' then return vim.fn.fnamemodify(git, ':p:h') end
  return vim.fn.getcwd()
end

local function get_function_node()
  local node = vim.treesitter.get_node()
  while node do
    if function_types[node:type()] then return node end
    node = node:parent()
  end
  return nil
end

-- Recursively find the first identifier/name node inside a function node.
-- Walks into declarator-like children to handle C pointer returns, etc.
local function find_identifier(node, bufnr)
  local declarator_types = {
    declarator           = true,
    function_declarator  = true,
    pointer_declarator   = true,
    reference_declarator = true,
  }
  for child in node:iter_children() do
    local t = child:type()
    if t == 'identifier' or t == 'name' then
      return vim.treesitter.get_node_text(child, bufnr)
    elseif declarator_types[t] then
      local name = find_identifier(child, bufnr)
      if name then return name end
    end
  end
  return nil
end

local function get_class_name(fn_node, bufnr)
  local node = fn_node:parent()
  while node do
    if class_types[node:type()] then
      return find_identifier(node, bufnr)
    end
    node = node:parent()
  end
  return nil
end

local function get_qualified_name(fn_node, bufnr)
  local fn_name = find_identifier(fn_node, bufnr)
  if not fn_name then return nil end
  local class_name = get_class_name(fn_node, bufnr)
  if class_name then return class_name .. '.' .. fn_name end
  return fn_name
end

local function history_path(filepath, name, ext)
  local dir = state.cfg.dir
  if vim.fn.isabsolutepath(dir) == 1 then
    -- Global store: {hash}__{name}.{ext}  (hash is djb2 of the full filepath)
    return dir .. '/' .. short_hash(filepath) .. '__' .. name .. '.' .. ext
  else
    -- Project-relative store
    local root    = find_project_root(vim.fn.fnamemodify(filepath, ':h'))
    local rel     = filepath:sub(#root + 2)
    local rel_dir = vim.fn.fnamemodify(rel, ':r')
    return root .. '/' .. dir .. '/' .. rel_dir .. '/' .. name .. '.' .. ext
  end
end

-- save
function M.save()
  local bufnr    = vim.api.nvim_get_current_buf()
  local filepath = vim.fn.expand('%:p')
  local ext      = vim.fn.expand('%:e')

  if filepath == '' then
    vim.notify('fn-history: buffer has no file', vim.log.levels.WARN)
    return
  end

  local node = get_function_node()
  if not node then
    vim.notify('fn-history: cursor is not inside a function', vim.log.levels.WARN)
    return
  end

  local text = vim.treesitter.get_node_text(node, bufnr)
  local name = get_qualified_name(node, bufnr)
  if not name then
    vim.notify('fn-history: could not determine function name', vim.log.levels.WARN)
    return
  end

  local dest = history_path(filepath, name, ext)
  vim.fn.mkdir(vim.fn.fnamemodify(dest, ':h'), 'p')

  local prefix = comment_prefix[ext] or '//'
  local header = string.format('%s %s\n', prefix, os.date('%Y-%m-%d %H:%M:%S'))

  local f = io.open(dest, 'a')
  if not f then
    vim.notify('fn-history: cannot write to ' .. dest, vim.log.levels.ERROR)
    return
  end
  f:write('\n' .. header .. text .. '\n')
  f:close()

  state.file_cache[dest] = true -- update cache immediately after write

  -- Stamp RELIC marker above the function in the source buffer (idempotent)
  local fn_row           = node:start()
  local marker           = prefix .. ' RELIC'
  local prev             = fn_row > 0 and vim.api.nvim_buf_get_lines(bufnr, fn_row - 1, fn_row, false)[1] or ''
  if not prev:find('RELIC', 1, true) then
    vim.api.nvim_buf_set_lines(bufnr, fn_row, fn_row, false, { marker })
  end

  vim.notify('tracked: ' .. name, vim.log.levels.INFO)
  M.refresh_signs(bufnr)
end

-- delete
function M.delete()
  local bufnr    = vim.api.nvim_get_current_buf()
  local filepath = vim.fn.expand('%:p')
  local ext      = vim.fn.expand('%:e')

  local node     = get_function_node()
  if not node then
    vim.notify('fn-history: cursor is not inside a function', vim.log.levels.WARN)
    return
  end

  local name = get_qualified_name(node, bufnr)
  if not name then return end

  local dest = history_path(filepath, name, ext)
  if vim.fn.filereadable(dest) == 0 then
    vim.notify('fn-history: no history for ' .. name, vim.log.levels.INFO)
    return
  end

  vim.fn.delete(dest)
  state.file_cache[dest] = false
  vim.notify('fn-history: deleted → ' .. dest, vim.log.levels.INFO)
  M.refresh_signs(bufnr)
end

-- open
function M.open()
  local bufnr    = vim.api.nvim_get_current_buf()
  local filepath = vim.fn.expand('%:p')
  local ext      = vim.fn.expand('%:e')

  local node     = get_function_node()
  if not node then
    vim.notify('fn-history: cursor is not inside a function', vim.log.levels.WARN)
    return
  end

  local name = get_qualified_name(node, bufnr)
  if not name then return end

  local dest = history_path(filepath, name, ext)

  local readable = state.file_cache[dest]
  if readable == nil then readable = vim.fn.filereadable(dest) == 1 end
  if not readable then
    vim.notify('fn-history: no history for ' .. name, vim.log.levels.INFO)
    return
  end

  vim.cmd('vsplit ' .. vim.fn.fnameescape(dest))
  vim.cmd('normal! G') -- jump to end (latest entry)
  vim.keymap.set('n', 'q', '<cmd>bd<cr>', { buffer = true, nowait = true })
end

-- signs
local function walk_functions(node, fn)
  if function_types[node:type()] then fn(node) end
  for child in node:iter_children() do
    walk_functions(child, fn)
  end
end

function M.refresh_signs(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == '' or filepath:sub(1, #state.cfg.dir) == state.cfg.dir then return end

  local ext    = vim.fn.fnamemodify(filepath, ':e')
  local parser = vim.treesitter.get_parser(bufnr, nil, { error = false })
  if not parser then return end

  vim.api.nvim_buf_clear_namespace(bufnr, state.ns, 0, -1)

  local tree = parser:parse()[1]
  walk_functions(tree:root(), function(node)
    local name = get_qualified_name(node, bufnr)
    if name then
      local dest = history_path(filepath, name, ext)
      local cached = state.file_cache[dest]
      if cached == nil then
        cached = vim.fn.filereadable(dest) == 1
        state.file_cache[dest] = cached
      end
      if cached then
        local row = node:start()
        vim.api.nvim_buf_set_extmark(bufnr, state.ns, row, 0, {
          sign_text     = state.cfg.sign.text,
          sign_hl_group = state.cfg.sign.hl,
        })
      end
    end
  end)
end

-- setup
function M.setup(opts)
  state.cfg = vim.tbl_deep_extend('force', defaults, opts or {})

  vim.api.nvim_create_autocmd({ 'BufRead', 'BufEnter' }, {
    callback = function(ev)
      if ev.file:sub(1, #state.cfg.dir) ~= state.cfg.dir then
        M.refresh_signs(ev.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd('BufRead', {
    pattern  = state.cfg.dir .. '/*',
    callback = function(ev)
      vim.diagnostic.enable(false, { bufnr = ev.buf })
    end,
  })

  vim.api.nvim_create_user_command('FnSave', M.save, { desc = 'Save current function to history' })
  vim.api.nvim_create_user_command('FnOpen', M.open, { desc = 'Open history file for current function' })
  vim.api.nvim_create_user_command('FnDelete', M.delete, { desc = 'Delete history file for current function' })
end

return {
  name   = 'fn-history',
  dir    = vim.fn.stdpath('config'),
  ft     = { 'c', 'cpp', 'js', 'ts', 'jsx', 'tsx', 'java', 'go', 'rust', 'python', 'sh', 'ruby', 'r', 'lua', 'haskell' },
  keys   = {
    { '<leader>fs', function() M.save() end,   desc = 'fn-history: save function snapshot' },
    { '<leader>fo', function() M.open() end,   desc = 'fn-history: open function history' },
    { '<leader>fd', function() M.delete() end, desc = 'fn-history: delete function history' },
  },
  config = function() M.setup() end,
}
