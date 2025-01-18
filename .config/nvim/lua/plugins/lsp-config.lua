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
          "rust_analyzer",
          "lua_ls",
          "tsserver",
          "pyright",
          "volar",
          "ruff_lsp",
          "gopls",
          "texlab",
          "marksman",
          "html",
          "htmx",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    config = function()
      -- Capabilities for nvim-cmp integration
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

        local opts = { buffer = bufnr }
        vim.keymap.set("n", "<leader>gf", function() vim.lsp.buf.format({ async = true }) end, opts)
        vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "<leader>gk", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>gK", vim.lsp.buf.signature_help, opts)
        vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<space>ge", function()
          vim.diagnostic.open_float(0, { scope = "line" })
        end, { noremap = true, silent = true })

        -- client.server_capabilities.documentFormattingProvider = true
        -- Format on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end

      local lspconfig = require("lspconfig")
      local html_capabilities = vim.lsp.protocol.make_client_capabilities()
      html_capabilities.textDocument.completion.completionItem.snippetSupport = true
      lspconfig.html.setup({
        capabilities = html_capabilities,
      })

      lspconfig.htmx.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Lua
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Python
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Ruff LSP for Python linting
      lspconfig.ruff_lsp.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Go
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Markdown
      lspconfig.marksman.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Rust Analyzer
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          ["rust-analyzer"] = {
            imports = {
              granularity = { group = "module" },
              prefix = "self",
            },
            cargo = { buildScripts = { enable = true } },
            procMacro = { enable = true },
          },
        },
      })

      -- TypeScript and JavaScript (tsserver)
      lspconfig.tsserver.setup({
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

      -- Volar (Vue)
      lspconfig.volar.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Texlab
      lspconfig.texlab.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end,
  },
}
