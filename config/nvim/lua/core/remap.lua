local g = vim.g

g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Buffers
vim.keymap.set("n", "<c-n>", vim.cmd.bnext)
vim.keymap.set("n", "<c-p>", vim.cmd.bprevious)
