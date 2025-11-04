return {
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      -- Remember to export QUARTO_PYTHON=/path/to/your/venv/bin/python
      local quarto = require('quarto')
      quarto.setup {
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = true,
          chunks = "curly",
          languages = { "r", "python", "julia", "bash", "html" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
          ft_runners = { python = "molten" },
          never_run = { 'yaml' },
        },
      }
      vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true })
    end
  },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    config = function()
      -- Remember to install the user
      -- python -m ipykernel install --user --name project_name
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = { "*.ipynb", "*.qmd" },
        callback = function()
          vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>",
            { silent = true, desc = "Initialize the plugin" })
          vim.keymap.set("n", "<leader>e", ":MoltenEvaluateOperator<CR>",
            { silent = true, desc = "run operator selection" })
          vim.keymap.set("n", "<leader>l", ":MoltenEvaluateLine<CR>",
            { silent = true, desc = "evaluate line" })
          vim.keymap.set("n", "<leader>rr", ":MoltenReevaluateCell<CR>",
            { silent = true, desc = "re-evaluate cell" })
          vim.keymap.set("v", "<leader>r", ":<C-u>MoltenEvaluateVisual<CR>gv",
            { silent = true, desc = "evaluate visual selection" })
          vim.keymap.set("n", "<leader>rd", ":MoltenDelete<CR>",
            { silent = true, desc = "molten delete cell" })
          vim.keymap.set("n", "<leader>oh", ":MoltenHideOutput<CR>",
            { silent = true, desc = "hide output" })
          vim.keymap.set("n", "<leader>os", ":noautocmd MoltenEnterOutput<CR>",
            { silent = true, desc = "show/enter output" })
        end,
      })
    end,
  },
  { -- paste an image from the clipboard or drag-and-drop
    'HakonHarnes/img-clip.nvim',
    event = 'BufEnter',
    ft = { 'markdown', 'quarto', 'latex' },
    opts = {
      default = {
        dir_path = 'img',
      },
      filetypes = {
        markdown = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
        quarto = {
          url_encode_path = true,
          template = '![$CURSOR]($FILE_PATH)',
          drag_and_drop = {
            download_images = false,
          },
        },
      },
    },
    config = function(_, opts)
      require('img-clip').setup(opts)
      vim.keymap.set('n', '<leader>ii', ':PasteImage<cr>', { desc = 'insert [i]mage from clipboard' })
    end,
  },
}
