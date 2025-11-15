return {
  {
    'stevearc/oil.nvim',
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        view_options = {
          -- Show files and directories that start with "."
          show_hidden = true,
          -- This function defines what is considered a "hidden" file
          is_hidden_file = function(name, bufnr)
            return vim.startswith(name, ".")
          end,
        }
      })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end
  },
  {
    ---@type LazySpec
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>y",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>-",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        '<c-up>',
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    ---@type YaziConfig
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = '<f1>',
      },
    },
    config = function()
      require("yazi").setup(opts)
    end
  },
  {
    'j-morano/buffer_manager.nvim',
    config = function()
      local opts = { noremap = true }
      local map = vim.keymap.set

      ---- Setup
      require("buffer_manager").setup({
        select_menu_item_commands = {
          v = {
            key = "<C-v>",
            command = "vsplit"
          },
          h = {
            key = "<C-h>",
            command = "split"
          }
        },
        focus_alternate_buffer = false,
        short_file_names = true,
        short_term_names = true,
        loop_nav = false,
        highlight = 'Normal:BufferManagerBorder',
        win_extra_options = {
          winhighlight = 'Normal:BufferManagerNormal',
        },
        use_shortcuts = true,
      })

      ---- Navigate buffers bypassing the menu
      local bmui = require("buffer_manager.ui")
      local keys = '1234567890'
      for i = 1, #keys do
        local key = keys:sub(i, i)
        map(
          'n',
          string.format('<leader>%s', key),
          function() bmui.nav_file(i) end,
          opts
        )
      end

      ---- Just the menu
      map({ 't', 'n' }, '<M-Space>', bmui.toggle_quick_menu, opts)

      ---- Next/Prev
      -- map('n', '<M-j>', bmui.nav_next, opts)
      -- map('n', '<M-k>', bmui.nav_prev, opts)
    end
  },
}
