return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ensure_installed = {
          "debugpy",
        }
      })
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "rust_analyzer",
          "lua_ls",
          "tsserver",
          "pyright",
          "volar",
          "vuels",
          "ruff_lsp",

        }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local lspconfig = require("lspconfig")
      local on_attach = function(client)
        require 'completion'.on_attach(client)
      end
      lspconfig.rust_analyzer.setup({
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
            },
            procMacro = {
              enable = true
            },
          }
        }
      })
      lspconfig.volar.setup({
        capabilities = capabilities
      })
      lspconfig.vuels.setup({
        capabilities = capabilities
      })
      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
      lspconfig.tsserver.setup({
        capabilities = capabilities
      })
      lspconfig.pyright.setup({
        capabilities = capabilities

      })
      lspconfig.volar.setup({
        capabilities = capabilities

      })
      lspconfig.vuels.setup({
        capabilities = capabilities

      })
      lspconfig.ruff_lsp.setup({
        capabilities = capabilities
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', '<leader>gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', '<leader>gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', '<leader>gk', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    end
  },

}
