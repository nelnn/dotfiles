-- Open lazygit in a new tmux window
vim.keymap.set("n", "<leader>gg", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazygit <CR><CR>",
  { desc = "lazygit" })

-- Open lazyjj in a new tmux window
vim.keymap.set("n", "<leader>jj", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazyjj <CR><CR>",
  { desc = "jj" })

-- Open yazi in a new tmux window
vim.keymap.set("n", "<leader>y", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- yazi <CR><CR>",
  { desc = "yazi" })
