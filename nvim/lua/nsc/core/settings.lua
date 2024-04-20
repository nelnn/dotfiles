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
