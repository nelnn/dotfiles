return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  config = function()
    -- Configure the Snacks plugin options
    -- Apply the configuration
    local snacks = require('snacks')
    snacks.setup(
      {
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
          },
        }
      }
    )

    vim.keymap.set('n', '<leader>fn', snacks.notifier.show_history, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>w', function() snacks.bufdelete() end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gg', function() snacks.lazygit() end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gb', function() snacks.git.blame_line() end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gB', function() snacks.gitbrowse() end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gl', function() snacks.lazygit.log() end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>cR', snacks.rename.rename_file, { noremap = true, silent = true })
    vim.keymap.set('n', ']]', function() snacks.words.jump(vim.v.count1) end, { noremap = true, silent = true })
    vim.keymap.set('n', '[[]', function() snacks.words.jump(-vim.v.count1) end, { noremap = true, silent = true })
    vim.keymap.set('t', ']]', function() snacks.words.jump(vim.v.count1) end, { noremap = true, silent = true })
    vim.keymap.set('t', '[[]', function() snacks.words.jump(-vim.v.count1) end, { noremap = true, silent = true })

    -- Autocmd for 'VeryLazy' event
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          snacks.debug.inspect(...)
        end
        _G.bt = function()
          snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>S")
        snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        snacks.toggle.diagnostics():map("<leader>ud")
        snacks.toggle.line_number():map("<leader>ul")
        snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map(
          "<leader>uc")
        snacks.toggle.treesitter():map("<leader>uT")
        snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        snacks.toggle.inlay_hints():map("<leader>uh")
      end,
    })
  end
}
