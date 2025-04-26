return {
  -- LSP completion source for nvim-cmp
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  -- LuaSnip setup with friendly snippets and keybindings
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local ls = require("luasnip")
      require("luasnip.loaders.from_snipmate").lazy_load({ paths = "~/.config/nvim/lua/nsc/snippets" })
      vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end, { silent = true })
      vim.keymap.set({ "i", "s" }, "<C-H>", function() ls.jump(-1) end, { silent = true })
    end,
  },
  -- nvim-cmp configuration with multiple sources and keybindings
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "Exafunction/windsurf.nvim",
      "nvim-lua/plenary.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      require("luasnip.loaders.from_vscode").lazy_load()
      require("codeium").setup({}) -- Ensure you've configured Codeium as needed
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
          require("luasnip.loaders.from_lua").load({ paths = "~/.dotfiles/nvim/lua/nsc/snippets" })
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
          ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources(
          {
            { name = "codeium" },  -- AI-assisted completion
            { name = "nvim_lsp" }, -- LSP completions
            { name = "luasnip" },  -- Snippet completions
          },
          {
            { name = "buffer" }, -- Buffer completions
          }
        ),
      })
    end,
  },
}
