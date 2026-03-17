return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      require("mini.ai").setup()
      require('mini.cursorword').setup()
      require('mini.comment').setup()
      require('mini.icons').setup()
      require('mini.bracketed').setup()
      require('mini.jump').setup()
      require('mini.splitjoin').setup()
      require('mini.statusline').setup()
      require("mini.surround").setup()
      require('mini.tabline').setup()
      require('mini.trailspace').setup()
      require('mini.visits').setup()

      local minifiles = require('mini.files')
      minifiles.setup()
      vim.keymap.set("n", "<leader>xt", ":lua MiniTrailspace.trim()<CR>", { desc = "Trim trailing whitespace" })
      vim.keymap.set("n", "<leader>v", ":lua MiniVisits.select_path()<CR>", { desc = "Select visit path" })
      vim.keymap.set("n", "<leader>e", function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        local path = vim.fn.filereadable(buf_name) == 1 and buf_name or vim.fn.getcwd()
        minifiles.open(path)
        minifiles.reveal_cwd()
      end, { desc = "Open Mini Files" })
      vim.keymap.set("n", "-", ":lua MiniFiles.open()<CR>", { desc = "Open file explorer" })
      require('mini.hipatterns').setup({
        highlighters = {
          -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
          fixme     = { pattern = '%f[%w]()FIXME()%f[%W]:', group = 'MiniHipatternsFixme' },
          bug       = { pattern = '%f[%w]()BUG()%f[%W]:', group = 'MiniHipatternsFixme' },
          hack      = { pattern = '%f[%w]()HACK()%f[%W]:', group = 'MiniHipatternsHack' },
          todo      = { pattern = '%f[%w]()TODO()%f[%W]:', group = 'MiniHipatternsTodo' },
          note      = { pattern = '%f[%w]()NOTE()%f[%W]:', group = 'MiniHipatternsNote' },
          ai        = { pattern = '%f[%w]()AI()%f[%W]:', group = 'MiniHipatternsNote' },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
        },
      })
      require('mini.indentscope').setup({
        draw = {
          delay = 20,
          animation = require('mini.indentscope').gen_animation.none(),
        }
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
      local miniclue = require('mini.clue')
      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = { 'n', 'x' }, keys = '<Leader>' },

          -- `[` and `]` keys
          { mode = 'n',          keys = '[' },
          { mode = 'n',          keys = ']' },

          -- Built-in completion
          { mode = 'i',          keys = '<C-x>' },

          -- `g` key
          { mode = { 'n', 'x' }, keys = 'g' },

          -- Marks
          { mode = { 'n', 'x' }, keys = "'" },
          { mode = { 'n', 'x' }, keys = '`' },

          -- Registers
          { mode = { 'n', 'x' }, keys = '"' },
          { mode = { 'i', 'c' }, keys = '<C-r>' },

          -- Window commands
          { mode = 'n',          keys = '<C-w>' },

          -- `z` key
          { mode = { 'n', 'x' }, keys = 'z' },
        },

        window = {
          delay = 0,
          config = { width = 'auto' },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.square_brackets(),
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
      })
    end
  },
}
