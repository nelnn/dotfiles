local g = vim.g

g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Buffers
vim.keymap.set("n", "<leader>bn", vim.cmd.bnext)
vim.keymap.set("n", "<leader>bp", vim.cmd.bprevious)
vim.keymap.set("n", "<leader>bd", vim.cmd.bdelete)
vim.keymap.set("n", "<leader>bvs", vim.cmd.vsplit)
vim.keymap.set("n", "<leader>bhs", vim.cmd.split)

local n_keymap = function(lhs, rhs)
	vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = true })
end

n_keymap("<Leader>w", ":bp|bd #")
