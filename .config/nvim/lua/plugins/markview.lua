return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("markview").setup({
      -- normal mode
      code_blocks = {
        style = "minimal",
        position = nil,
        min_width = 90,
        pad_amount = 0,
        pad_char = " ",
        -- hl = "CursorLine"
      },
    })
  end,
}
