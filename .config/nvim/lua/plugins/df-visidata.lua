return {
  -- Local development path to your plugin
  dir = "~/Documents/Github/nvim-df-visidata",

  -- Dependencies
  dependencies = {
    "mfussenegger/nvim-dap", -- This plugin depends on nvim-dap
  },

  -- Plugin configuration options
  opts = {
    -- Customize default options if needed
    temp_dir = "/Users/nsc/Desktop",
    file_name = "aaa.csv",
    window = {
      width = 0.5,
      height = 0.8,
      border = "rounded"
    },
    -- keymap = {
    --   visualize = "<Leader><leader>o"
    -- }
  },

  -- Call plugin setup function
  config = function(_, opts)
    local df_visidata = require("df-visidata")
    df_visidata.setup(opts)
    -- vim.keymap.set("n", "<leader><leader>p", ":lua require('df-visidata').visualize()<CR>")
    vim.keymap.set("n", "<leader><leader>p", df_visidata.visualise)
    --   { silent = true, noremap = true })
  end,

  -- Optional: Specify lazy-loading conditions
  -- For example, only load in debug sessions or when specific filetypes are active
  ft = { "python" }, -- Load when editing Python files
}
