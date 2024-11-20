return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      local snacks = require("snacks")
      snacks.setup({
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        notifier = {
          enabled = true,
          timeout = 3000,
        },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
          notification = {
            wo = { wrap = true } -- Wrap notifications
          }
        }
      })

      local keymaps = {
        { "<leader>bd", function() snacks.bufdelete() end,               desc = "Delete Buffer" },
        { "<leader>gg", function() snacks.lazygit() end,                 desc = "Lazygit" },
        { "<leader>gb", function() snacks.git.blame_line() end,          desc = "Git Blame Line" },
        { "<leader>gB", function() snacks.gitbrowse() end,               desc = "Git Browse" },
        { "<leader>gf", function() snacks.lazygit.log_file() end,        desc = "Lazygit Current File History" },
        { "<leader>gl", function() snacks.lazygit.log() end,             desc = "Lazygit Log (cwd)" },
        { "<leader>cR", function() snacks.rename.rename_file() end,      desc = "Rename File" },
        { "]]",         function() snacks.words.jump(vim.v.count1) end,  desc = "Next Reference",              mode = { "n", "t" } },
        { "[[",         function() snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference",              mode = { "n", "t" } },
      }

      --      Register key mappings
      for _, keymap in ipairs(keymaps) do
        vim.keymap.set("n", keymap[1], keymap[2], { noremap = true, silent = true, desc = keymap.desc })
      end
    end,
  },
}
