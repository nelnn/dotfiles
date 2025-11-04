local g = vim.g

g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Buffers
vim.keymap.set("n", "<leader>bn", vim.cmd.bnext)
vim.keymap.set("n", "<leader>bp", vim.cmd.bprevious)

-- vim.api.nvim_set_keymap("n", "<Leader>w", ":bp|bd #", { noremap = true, silent = true }) -- Close current buffer (disabled, use snacks <leader>bd instead)

vim.api.nvim_set_keymap('n', '<tab>', ':if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>', -- Tab to next buffer
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<s-tab>',
  ':if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>',
  { noremap = true, silent = true }) -- Shift-Tab to prvious buffer
