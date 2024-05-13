local o = vim.o

o.background = "dark"
o.hidden = true
o.nocompatible = true -- disable compatibility to old-time vi

o.number = true       -- add line numbers
o.relativenumber = true

o.showmatch = true      -- show matching
o.ignorecase = true     -- case insensitive

o.mouse = "v"           -- enable mouse click
o.mouse = "a"           -- middle-click paste with

o.hlsearch = true       -- highlight search
o.incsearch = true      -- incremental search

o.tabstop = 4           -- number of columns occupied by a tab
o.softtabstop = 4       -- see multiple spaces as tabstops so <BS> does the right thing
o.expandtab = true      -- converts tabs to white space
o.shiftwidth = 2        -- width for autoindents
o.autoindent = true     -- indent a new line the same amount as the line just typed
o.cc = 120              -- set an 120 column border for good coding style
o.clipboard = "unnamed" -- using system clipboard
o.ttyfast = true
o.syntax = "on"
o.cursorline = true
o.swapfile = false

vim.cmd('filetype on')
vim.cmd('filetype plugin on')
vim.cmd('filetype indent on')


-- ## Tabline, defines how tabpages title looks like
-- For convenience of cross-probjects development, show project names directly.
function MyTabLine()
  local tabline = ""
  for index = 1, vim.fn.tabpagenr('$') do
    -- select the highlighting
    if index == vim.fn.tabpagenr() then
      tabline = tabline .. '%#TabLineSel#'
    else
      tabline = tabline .. '%#TabLine#'
    end

    -- set the tab page number (for mouse clicks)
    tabline = tabline .. '%' .. index .. 'T'

    local win_num = vim.fn.tabpagewinnr(index)
    local working_directory = vim.fn.getcwd(win_num, index)
    local project_name = vim.fn.fnamemodify(working_directory, ":t")
    tabline = tabline .. " " .. index .. " " .. project_name .. " "
  end

  -- after the last tab fill with TabLineFill and reset tab page nr
  tabline = tabline .. '%#TabLineFill#%T'

  -- right-align the label to close the current tab page
  if vim.fn.tabpagenr('$') > 1 then
    tabline = tabline .. '%=%#TabLine#%999Xclose'
  end

  return tabline
end

vim.go.tabline = "%!v:lua.MyTabLine()"
