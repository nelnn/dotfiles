local g = vim.g

g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)


-- Buffers
vim.keymap.set('n', '<leader>bn', vim.cmd.bnext)
vim.keymap.set('n', '<leader>bp', vim.cmd.bprevious)
vim.keymap.set('n', '<leader>bd', vim.cmd.bdelete)
vim.keymap.set('n', '<leader>bvs', vim.cmd.vsplit)
vim.keymap.set('n', '<leader>bhs', vim.cmd.split)
