local map = vim.keymap.set

map("n", "<C-n>", vim.cmd.bnext, { desc = "Next buffer" })
map("n", "<C-p>", vim.cmd.bprevious, { desc = "Previous buffer" })
map("n", "<leader>R", "<cmd>restart<cr>", { desc = "Restart Neovim" })
map("n", "<leader>w", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>S", "<cmd>set spell!<cr>", { desc = "Toggle spelling" })

-- Mac uses tmux, not Ubuntu's Herdr. Outside tmux, use a terminal tab.
local function open_tool(tool)
  if vim.fn.executable(tool) ~= 1 then
    vim.notify(tool .. " is not on PATH", vim.log.levels.WARN)
    return
  end
  if vim.env.TMUX and vim.env.TMUX ~= "" and vim.fn.executable("tmux") == 1 then
    vim.fn.jobstart({ "tmux", "new-window", "-c", vim.fn.getcwd(), tool })
    return
  end
  vim.cmd("tabnew")
  vim.fn.jobstart({ tool }, { term = true })
  vim.cmd("startinsert")
end

map("n", "<leader>gg", function() open_tool("lazygit") end, { desc = "Lazygit" })
map("n", "<leader>y", function() open_tool("yazi") end, { desc = "Yazi" })
map("n", "<leader>jj", function() open_tool("lazyjj") end, { desc = "Lazyjj" })
