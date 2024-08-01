-- return {
--   "ellisonleao/gruvbox.nvim",
--   priority = 1000,
--   config = function()
--     vim.cmd([[colorscheme gruvbox]])
--   end,
-- }

-- return {
--   "catppuccin/nvim",
--   priority = 1000,
--   config = function()
--     vim.cmd([[colorscheme catppuccin-macchiato]])
--   end,
-- }

return {
  "EdenEast/nightfox.nvim",
  priority = 1000,
  config = function()
    require('nightfox').setup({
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        }
      }
    })
    vim.cmd([[colorscheme carbonfox]])
  end,
}
