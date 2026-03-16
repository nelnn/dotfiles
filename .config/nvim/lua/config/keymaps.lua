local map = vim.keymap.set

-- buffers
map("n", "<c-n>", vim.cmd.bnext)
map("n", "<c-p>", vim.cmd.bprevious)

-- tmux
-- Open lazygit in a new tmux window
map("n", "<leader>gg", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazygit <CR><CR>",
  { desc = "lazygit" })

-- Open lazyjj in a new tmux window
map("n", "<leader>jj", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazyjj <CR><CR>",
  { desc = "jj" })

-- Open yazi in a new tmux window
vim.keymap.set("n", "<leader>y", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- yazi <CR><CR>",
  { desc = "yazi" })
