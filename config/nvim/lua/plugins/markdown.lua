return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()

    end
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    ft = { "markdown" },
  },
  {
    "roodolv/markdown-toggle.nvim",
    config = function()
      require("markdown-toggle").setup({
        keymaps = {
          toggle = {
            ["<leader>q"] = "quote",
            ["<leader>l"] = "list",
            ["<C-n>"] = "olist",
            ["<C-c>"] = "checkbox",
            ["<C-h>"] = "heading",
          },
        },
      })
    end,
  },
}
