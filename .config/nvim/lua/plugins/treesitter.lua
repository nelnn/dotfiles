return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- A list of parser names, or "all" (the five listed parsers should always be installed)
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "query",
          "python",
          "css",
          "javascript",
          "typescript",
          "html",
          "regex",
          "toml",
          "yaml",
          "latex",
          "markdown",
          "markdown_inline",
          "dockerfile",
        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        -- List of parsers to ignore installing (or "all")
        -- ignore_install = { "javascript" },

        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })

      vim.keymap.set('n', '<leader>ft', require('telescope.builtin').treesitter, {})
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
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup {
        'css',
        'javascript',
        'vue',
        html = {
          mode = 'foreground',
        }
      }
    end
  }
}
