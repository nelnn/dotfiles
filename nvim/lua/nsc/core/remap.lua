local g = vim.g
local n_keymap = function(lhs, rhs)
  vim.api.nvim_set_keymap("n", lhs, rhs, { noremap = true, silent = true })
end

g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Buffers
vim.keymap.set("n", "<leader>bn", vim.cmd.bnext)
vim.keymap.set("n", "<leader>bp", vim.cmd.bprevious)
vim.keymap.set("n", "<leader>bd", vim.cmd.bdelete)
vim.keymap.set("n", "<leader>bvs", vim.cmd.vsplit)
vim.keymap.set("n", "<leader>bhs", vim.cmd.split)

n_keymap("<Leader>w", ":bp|bd #")                                                                                        -- Close current buffer

vim.api.nvim_set_keymap('n', '<tab>', ':if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>', -- Tab to next buffer
  { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<s-tab>',
  ':if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>',
  { noremap = true, silent = true }) -- Shift-Tab to prvious buffer

-- Tabs
n_keymap("<leader>t", ":tabnew")
n_keymap("<leader>tt", ":tabc")
n_keymap("<leader>1", "1gt")
n_keymap("<leader>2", "2gt")
n_keymap("<leader>3", "3gt")
n_keymap("<leader>4", "4gt")
n_keymap("<leader>5", "5gt")
n_keymap("<leader>6", "6gt")
n_keymap("<leader>7", "7gt")
n_keymap("<leader>8", "8gt")
n_keymap("<leader>9", "9gt")
