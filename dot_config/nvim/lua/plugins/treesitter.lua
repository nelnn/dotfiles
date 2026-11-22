return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- main branch for neovim >= 0.12.0 (nigtly at the moment)
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "python", "css", "javascript", "typescript",
          "html", "regex", "toml", "yaml",
          "markdown", "markdown_inline", "dockerfile",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
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
