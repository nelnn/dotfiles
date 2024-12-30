return {
  "OXY2DEV/markview.nvim",
  lazy = false, -- Recommended
  -- ft = "markdown" -- If you decide to lazy-load anyway
  dependencies = {
    -- You will not need this if you installed the
    -- parsers manually
    -- Or if the parsers are in your $RUNTIMEPATH
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- Add a comma here to avoid syntax issues
  },
  config = function()
    require("markview").setup({
      modes = { "n", "no", "c" }, -- Change these modes
      -- to what you need

      hybrid_modes = { "n" }, -- Uses this feature on
      -- normal mode
      code_blocks = {
        style = "minimal",
        position = nil,
        min_width = 70,

        pad_amount = 3,
        pad_char = " ",

        hl = "CursorLine"
      },
      -- This is nice to have
      callbacks = {
        on_enable = function(_, win)
          vim.wo[win].conceallevel = 2;
          vim.wo[win].concealcursor = "c";
        end
      }
    })
  end,
}
