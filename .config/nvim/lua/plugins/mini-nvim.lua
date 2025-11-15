return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.ai").setup()
      require('mini.cursorword').setup()
      require('mini.comment').setup()
      require('mini.icons').setup()
      require('mini.jump').setup()
      require('mini.splitjoin').setup()
      require('mini.statusline').setup()
      require("mini.surround").setup()
      require('mini.tabline').setup()
      require('mini.trailspace').setup()
      require('mini.visits').setup({
        vim.keymap.set("n", "<leader>v", ":lua MiniVisits.select_path()<CR>")
      })
      require('mini.files').setup({
        vim.keymap.set("n", "<leader>e", ":lua MiniFiles.open()<CR>")
      })
      require('mini.move').setup({
        mappings = {
          -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
          left = "<leader>h",
          right = "<leader>l",
          down = "<leader>j",
          up = "<leader>k",

          -- Move current line in Normal mode
          line_left = "<leader>h",
          line_right = "<leader>l",
          line_down = "<leader>j",
          line_up = "<leader>k",
        },
      })
      vim.keymap.set("n", "<leader>xt", ":lua MiniTrailspace.trim()<CR>")
    end
  },
}
