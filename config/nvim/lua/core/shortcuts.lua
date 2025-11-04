-- Get all available colorschemes
local schemes = vim.fn.getcompletion("", "color")
local index = 1

local function cycle_colors()
  index = index % #schemes + 1
  vim.cmd.colorscheme(schemes[index])
  print("Colorscheme: " .. schemes[index])
  -- vim.cmd([[ highlight Normal ctermbg=NONE guibg=NONE ]])
  vim.notify("Colorscheme: " .. schemes[index], vim.log.levels.INFO, { title = "Colorscheme Changed" })
end

-- Map to <leader>c
vim.keymap.set("n", "<leader>c", cycle_colors, { desc = "Cycle colorscheme" })
