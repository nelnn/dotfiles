return {
  -- Mason setup to install LSPs and other tools
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  -- Mason-LSPConfig to auto-install LSP servers
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "clangd",
          "bashls",
          "tailwindcss",
          "lua_ls",
          "ts_ls",
          "vtsls",
          "vue_ls",
          -- "ty",
          "ruff",
          "gopls",
          "tinymist",
          "pyright",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      'saghen/blink.cmp',
      'ibhagwan/fzf-lua',
    },
    opts = {
      servers = {
        clangd = {
          filetypes = { "c", "cpp" },
        },
        bashls = {},
        tailwindcss = {},
        lua_ls = {},
        -- ty = {},
        ruff = {},
        pyright = {},
        gopls = {},
        vue_ls = {},
        vtsls = {},
        ts_ls = {
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                location = vim.fn.stdpath('data') ..
                    "/mason/packages/vue-language-server/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin",

                languages = { 'vue' },
                configNamespace = 'typescript',
              }
            },
          },
          filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },

        },
        tinymist = {
          settings = {
            formatterMode = "typstyle",
            -- exportPdf = "onType",
            semanticTokens = "disable",
            formatterProseWrap = true, -- wrap lines in content mode
            formatterPrintWidth = 80,  -- limit line length to 80 if possible
            -- formatterIndentSize = 4,   -- indentation width
          }
        },
      }
    },
    config = function(_, opts)
      local builtin = require('fzf-lua')
      local on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>gf", function() vim.lsp.buf.format({ async = true }) end, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gd", builtin.lsp_definitions, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gk", vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gK", vim.lsp.buf.signature_help, { buffer = bufnr })
        vim.keymap.set("n", "<leader>gr", builtin.lsp_references, { buffer = bufnr })
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
