return {
  {
    "sotte/presenting.nvim",
    opts = {
      -- fill in your options here
      -- see :help Presenting.config
    },
    cmd = { "Presenting" },
  },
  {
    -- View images in nvim
    "3rd/image.nvim",
    build = false,
    opts = {
      processor = "magick_cli",
      integrations = {
        markdown = {
          only_render_image_at_cursor = true,
        },
        typst = {
          only_render_image_at_cursor = true,
        },
      },
    },
    config = function(_, opts)
      require("image").setup(opts)
      local group = vim.api.nvim_create_augroup("ImageOnlyInNormal", { clear = true })
      local image = require("image")
      vim.keymap.set("n", "<leader>i", function()
        if image.is_enabled() then
          vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false }) -- closes an open image popup
          image.disable()
        else
          image.enable()
          vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
        end
      end, { desc = "Toggle image preview" })
      local disabled_outside_normal = false
      vim.api.nvim_create_autocmd("ModeChanged", {
        group = group,
        callback = function()
          if vim.api.nvim_get_mode().mode == "n" then
            if disabled_outside_normal then image.enable() end
            disabled_outside_normal = false
          elseif image.is_enabled() then
            vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false }) -- closes an open image popup
            image.disable()
            disabled_outside_normal = true
          end
        end,
      })
    end,
  },
  {
    'chomosuke/typst-preview.nvim',
    ft = 'typst',
    version = '1.*',
    opts = {
      dependencies_bin = { ['tinymist'] = 'tinymist' }
    },
    config = function(_, opts)
      require('typst-preview').setup(opts)
    end
  },

  -- Markdown
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    ft = { "markdown" },
  },

  -- CSV Preview
  {
    "hat0uma/csvview.nvim",
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
    config = function(_, opts)
      require("csvview").setup(opts)
    end,
  },
}
