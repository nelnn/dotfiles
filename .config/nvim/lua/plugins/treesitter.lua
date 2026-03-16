return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        "python", "css", "javascript", "typescript",
        "html", "regex", "toml", "yaml", "latex",
        "markdown", "markdown_inline", "dockerfile",
      },
      auto_install = true,
    },
  },
  {
    "windwp/nvim-ts-autotag",
    lazy = true,
    ft = { "html", "vue", "ts", "tsx" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          -- Defaults
          enable_close = true,         -- Auto close tags
          enable_rename = true,        -- Auto rename pairs of tags
          enable_close_on_slash = true -- Auto close on trailing </
        },
        -- Also override individual filetype configs, these take priority.
        -- Empty by default, useful if one of the "opts" global settings
        -- doesn't work well in a specific filetype
        -- per_filetype = {
        --   ["html"] = {
        --     enable_close = false
        --   }
        -- }
      })
    end
  },
}
