return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {
      "nvim-lua/plenary.nvim",
      'nvim-telescope/telescope.nvim'
    },
    config = function()
      local harpoon = require('harpoon')
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        }):find()
      end

      vim.keymap.set("n", "<leader>fe", function() toggle_telescope(harpoon:list()) end,
        { desc = "Open harpoon window" })
      vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
      vim.keymap.set("n", "<leader>he", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
      vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)
      vim.keymap.set("n", "<leader>6", function() harpoon:list():select(6) end)
      vim.keymap.set("n", "<leader>7", function() harpoon:list():select(7) end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", "<leader>p", function() harpoon:list():prev() end)
      vim.keymap.set("n", "<leader>n", function() harpoon:list():next() end)
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
