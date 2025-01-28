return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.ai").setup()
    require("mini.surround").setup()
    require('mini.comment').setup()
    require('mini.splitjoin').setup()
    require('mini.jump').setup()
    require('mini.trailspace').setup()
    require('mini.cursorword').setup()
    require('mini.pairs').setup({
      mappings = {
        ['('] = false,
        ['['] = false,
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },

        [')'] = false,
        [']'] = false,
        ['}'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },

        ['"'] = false,
        ["'"] = false,
        ['`'] = false,
      },
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
  end
}
