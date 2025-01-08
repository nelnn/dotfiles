return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      'nvim-lua/plenary.nvim',
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope-live-grep-args.nvim",
    },
    config = function()
      require("nvim-treesitter").setup()
      local builtin = require('telescope.builtin')
      local telescope = require("telescope")
      local actions = require "telescope.actions"
      local lga_actions = require("telescope-live-grep-args.actions")
      local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

      telescope.setup({
        pickers = {
          find_files = {
            find_command = { "rg", "-uuu", "--files", "--hidden", "--glob", "!**/.git/*", "-g", "!**/__pycache__/*", "-g", "!**/node_modules/*" },
          },
          live_grep = {
            glob_pattern = { "!**/__pycache__/*" },
          },
          buffers = {
            mappings = {
              i = {
                ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
              }
            },
          }
        },
        extensions = {
          live_grep_args = {
            auto_quoting = true, -- enable/disable auto-quoting
            -- define mappings, e.g.
            mappings = {         -- extend mappings
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                -- freeze the current list and start a fuzzy search in the frozen list
                ["<C-space>"] = actions.to_fuzzy_refine,
              },
            },
          }
        }
      })
      telescope.load_extension("live_grep_args")

      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set("n", "<leader>fG", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      vim.keymap.set('n', '<leader>fd', builtin.git_commits, {})
      vim.keymap.set('n', '<leader>gr', builtin.lsp_references, {})
      vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, {})
      vim.keymap.set('n', '<leader>ft', builtin.treesitter, {})
      vim.keymap.set('n', '<leader>fm', builtin.marks, {})
      vim.keymap.set('n', '<leader>fc', builtin.command_history, {})
      vim.keymap.set('n', '<leader>fy', builtin.registers, {})
      vim.keymap.set("n", "<leader>gc", live_grep_args_shortcuts.grep_word_under_cursor)
      vim.keymap.set("n", "<leader>gc", live_grep_args_shortcuts.grep_word_under_cursor)
    end
  },
}
