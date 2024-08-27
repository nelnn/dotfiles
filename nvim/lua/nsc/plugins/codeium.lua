return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("codeium").setup({
    })
    require("cmp").setup({
      sources = {
        { name = "codeium" }
      },
    })
  end
}

-- Next Suggestion: <M-]>
-- Prev Suggestion: <M-[>
-- Clear Suggestion: <C-]>
-- Accept Suggestion: Tab
