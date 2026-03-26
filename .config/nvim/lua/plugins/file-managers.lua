return {
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      columns = { "icon", "permissions", "size", "mtime" },
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<S-l>"] = "actions.select", -- remapped
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-l>"] = "actions.refresh",
        ["<S-h>"] = { "actions.parent", mode = "n" }, -- remapped
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = true,
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
        -- This function defines what is considered a "hidden" file
        is_hidden_file = function(name, bufnr)
          local m = name:match("^%.")
          return m ~= nil
        end,
        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, bufnr)
          return false
        end,
      },
      win_options = {
        signcolumn = "yes",
      },
    },
    -- Optional dependencies
    dependencies = { { "nvim-mini/mini.nvim", opts = {} } },
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  },
  {
    "refractalize/oil-git-status.nvim",

    dependencies = {
      "stevearc/oil.nvim",
    },

    config = true,
  },
  {
    "otavioschwanck/arrow.nvim",
    dependencies = {
      { "echasnovski/mini.nvim" },
    },
    opts = {
      show_icons = true,
      leader_key = ';',                -- Recommended to be a single key
      buffer_leader_key = '<leader>m', -- Per Buffer Mappings
      hide_handbook = true,
      hide_buffer_handbook = true,
    }
  },
  -- {
  --   "ThePrimeagen/harpoon",
  --   branch = "harpoon2",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   config = function()
  --     local harpoon = require('harpoon')
  --     vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
  --     vim.keymap.set("n", "<leader>he", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
  --
  --     vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
  --     vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
  --     vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
  --     vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
  --     vim.keymap.set("n", "<leader>5", function() harpoon:list():select(5) end)
  --     vim.keymap.set("n", "<leader>6", function() harpoon:list():select(6) end)
  --     vim.keymap.set("n", "<leader>7", function() harpoon:list():select(7) end)
  --
  --     -- Toggle previous & next buffers stored within Harpoon list
  --     vim.keymap.set("n", "<leader>p", function() harpoon:list():prev() end)
  --     vim.keymap.set("n", "<leader>n", function() harpoon:list():next() end)
  --   end
  -- },
}
