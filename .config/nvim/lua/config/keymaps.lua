local map = vim.keymap.set

-- buffers
map("n", "<c-n>", vim.cmd.bnext)
map("n", "<c-p>", vim.cmd.bprevious)
map("n", "<leader>R", "<cmd>restart<cr>", { desc = "Restart Neovim" })

-- tmux
-- -- Open lazygit in a new tmux window
-- map("n", "<leader>gg", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazygit <CR><CR>",
--   { desc = "lazygit" })
--
-- -- Open lazyjj in a new tmux window
-- map("n", "<leader>jj", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazyjj <CR><CR>",
--   { desc = "jj" })
--
-- -- Open yazi in a new tmux window
-- vim.keymap.set("n", "<leader>y", "<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- yazi <CR><CR>",
--   { desc = "yazi" })

-- Herdr
local function herdr_tab(command)
  local herdr = vim.env.HERDR_BIN_PATH ~= "" and vim.env.HERDR_BIN_PATH or "herdr"
  local return_tab = vim.env.HERDR_TAB_ID or ""
  local tab = vim.fn.system({ herdr, "tab", "create", "--cwd", vim.fn.getcwd(), "--env", "ZDOTDIR=/nonexistent", "--focus" })
  if vim.v.shell_error ~= 0 then
    vim.notify(tab, vim.log.levels.ERROR)
    return
  end
  local pane_id = vim.json.decode(tab).result.root_pane.pane_id
  local cleanup = return_tab ~= "" and "; " .. vim.fn.shellescape(herdr) .. " tab focus " .. vim.fn.shellescape(return_tab) or ""
  vim.fn.jobstart({ herdr, "pane", "run", pane_id, command .. cleanup .. "; exit" })
end

map("n", "<leader>gg", function() herdr_tab("lazygit") end, { desc = "lazygit" })
map("n", "<leader>y", function() herdr_tab("yazi") end, { desc = "yazi" })
-- map("n", "<leader>jj", function() herdr_tab("lazyjj") end, { desc = "lazyjj" })
