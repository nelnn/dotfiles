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
          "tailwindcss",
          "lua_ls",
          "ts_ls",
          "vtsls",
          "vue_ls",
          "pyright",
          "ruff",
          "gopls",
          "texlab",
          "tinymist",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      'saghen/blink.cmp',
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      servers = {
        tailwindcss = {},
        lua_ls = {},
        pyright = {},
        ruff = {},
        gopls = {},
        texlab = {},
        vue_ls = {},
        vtsls = {},
        ts_ls = {
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                location = vim.fn.stdpath('data') ..
                    "/mason/packages/vue-language-server/node_modules/@vue/language-server",
                languages = { 'vue' },
                configNamespace = 'typescript',
              }
            },
          },
          filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },

        },
      }
    },
    config = function(_, opts)
      local builtin = require('telescope.builtin')
      local on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>gf", function() vim.lsp.buf.format({ async = true }) end, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gk", vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gK", vim.lsp.buf.signature_help, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gr", builtin.lsp_references, { buffer = bufnr })
        -- vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { buffer = bufnr })
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
        config.on_attach = on_attach
        vim.lsp.config(server, config)
      end
    end,
  },
}
