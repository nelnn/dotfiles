return {
  -- Mason setup to install LSPs and other tools
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ensure_installed = {
          "debugpy",
          "texlab",
          "latexindent", -- Ensure installed manually
        },
      })
    end,
  },
  -- Mason-LSPConfig to auto-install LSP servers
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "pyright",
          "volar",
          "ruff",
          "gopls",
          "texlab",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { 'saghen/blink.cmp', "nvim-telescope/telescope.nvim",
    },
    lazy = true,
    opts = {
      servers = {
        lua_ls = {},
        pyright = {},
        ruff = {},
        volar = {},
        gopls = {},
        texlab = {},
      }
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local builtin = require('telescope.builtin')
      local on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>gf", function() vim.lsp.buf.format({ async = true }) end, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gk", vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gK", vim.lsp.buf.signature_help, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gr", builtin.lsp_references, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions, { buffer = bufnr })
        vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, { buffer = bufnr })
        vim.keymap.set("n", "<space>ge", function()
          vim.diagnostic.open_float(0, { scope = "line" })
        end, { noremap = true, silent = true })

        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end
      end
      for server, config in pairs(opts.servers) do
        config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
        config.on_attach = on_attach
        lspconfig[server].setup(config)
      end

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = require("mason-registry").get_package("vue-language-server"):get_install_path() ..
                  "/node_modules/@vue/language-server",
              languages = { "vue" },
            },
          },
        },
      })
    end,
  },
  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- optional
      "neovim/nvim-lspconfig",         -- optional
    },
    opts = {},                         -- your configuration
    config = function()
      require("tailwind-tools").setup()
    end,
    ft = { "html", "ts", "js", "tsx", "vue" },
  }
}
