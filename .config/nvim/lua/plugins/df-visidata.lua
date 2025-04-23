return {
  "nelnn/visidataframe.nvim",
  dependencies = {
    "mfussenegger/nvim-dap",
  },

  opts = {
    window = {
      width = 0.9,
      height = 0.8,
      border = "rounded"
    },
  },

  config = function(_, opts)
    local df_visidata = require("visidataframe")
    df_visidata.setup(opts)
  end,

  ft = { "python" },
}
