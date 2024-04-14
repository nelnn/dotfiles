local g = vim.g

g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)


-- Buffers
vim.keymap.set('n', '<leader>n', vim.cmd.bnext)
vim.keymap.set('n', '<leader>p', vim.cmd.bprevious)
vim.keymap.set('n', '<leader>d', vim.cmd.bdelete)
vim.keymap.set('n', '<leader>vs', vim.cmd.vsplit)
vim.keymap.set('n', '<leader>hs', vim.cmd.split)
