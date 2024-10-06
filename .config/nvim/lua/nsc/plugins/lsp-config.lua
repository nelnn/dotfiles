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
        },
      })
    end,
  },
  -- LSPConfig setup for various language servers
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    config = function()
      -- Capabilities for nvim-cmp integration
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      -- General on_attach function
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
        -- Buffer local mappings for LSP actions
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
      end

      -- LSP server setups
      local lspconfig = require("lspconfig")

      -- Lua LSP setup
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Python LSP setup
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Ruff LSP for Python linting
      lspconfig.ruff_lsp.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Go LSP setup
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Markdown LSP setup
      lspconfig.marksman.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Rust Analyzer with custom settings
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

      -- TypeScript and JavaScript LSP setup (tsserver)
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

      -- Volar (Vue) setup
      lspconfig.volar.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Advanced TexLab setup for LaTeX
      lspconfig.texlab.setup({
        capabilities = capabilities,
        settings = {
          texlab = {
            build = {
              executable = "tectonic",
              args = { "-X", "compile", "%f", "--keep-logs", "--keep-intermediates", "--outdir=build" },
              onSave = false,
            },
            auxDirectory = "build",
            latexFormatter = "latexindent",
            latexindent = { ["local"] = nil, modifyLineBreaks = false },
            chktex = { onOpenAndSave = false, onEdit = false },
          },
        },
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)
          -- Enable formatting
          client.server_capabilities.documentFormattingProvider = true
          -- Set up formatting on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end,
      })

      -- LaTeX build and clean functions
      local function tectonic_build()
        local filename = vim.fn.expand("%:p")
        local cmd = string.format("tectonic -X compile %s --keep-logs --keep-intermediates", filename)
        vim.fn.system(cmd)
        vim.notify("Built with Tectonic", vim.log.levels.INFO)
      end

      local function clean_build_dir()
        vim.fn.system("find . -name '*.aux' -type f -delete")
        vim.fn.system("find . -name '*.log' -type f -delete")
        vim.notify("Cleaned build directory", vim.log.levels.INFO)
      end

      local function tectonic_build_and_clean()
        vim.cmd("write")
        tectonic_build()
        clean_build_dir()
      end

      -- LSPAttach autocmd to set up LaTeX-specific keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          vim.keymap.set("n", "<leader>lb", tectonic_build_and_clean,
            { buffer = ev.bufnr, desc = "Build LaTeX with Tectonic" })
          vim.keymap.set("n", "<leader>lc", clean_build_dir, { buffer = ev.bufnr, desc = "Clean LaTeX build directory" })
        end,
      })
    end,
  },
}
