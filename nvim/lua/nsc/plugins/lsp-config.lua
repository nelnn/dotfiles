return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ensure_installed = {
          "debugpy",
          "texlab",
          "latexindent", -- Need to install manually in Mason
        },
      })
    end,
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
          "ruff_lsp",
          "gopls",
          "texlab",
          "marksman",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")
      local on_attach = function(client)
        require("completion").on_attach(client)
      end

      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.ruff_lsp.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.marksman.setup({ capabilities = capabilities })

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
              enable = true,
            },
          },
        },
      })
      -- VUE setup
      local vue_language_server_path = (
        require('mason-registry')
        .get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
      )
      lspconfig.tsserver.setup {
        init_options = {
          plugins = {
            {
              name = '@vue/typescript-plugin',
              location = vue_language_server_path,
              languages = { 'vue' },
            },
          },
        },
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
      }
      lspconfig.volar.setup({})

      -- Advanced TexLab setup
      lspconfig.texlab.setup({
        capabilities = capabilities,
        settings = {
          texlab = {
            rootDirectory = nil,
            build = {
              executable = 'tectonic',
              args = {
                '-X',
                'compile',
                '%f',
                '--keep-logs',
                '--keep-intermediates',
                '--outdir=build'
              },
              onSave = false,
              forwardSearchAfter = false,
            },
            auxDirectory = 'build',
            forwardSearch = {
              executable = nil,
              args = {},
            },
            chktex = {
              onOpenAndSave = false,
              onEdit = false,
            },
            diagnosticsDelay = 300,
            latexFormatter = 'latexindent',
            latexindent = {
              ['local'] = nil,
              modifyLineBreaks = false,
            },
            bibtexFormatter = 'texlab',
            formatterLineLength = 80,
          },
        },
        on_attach = function(client, bufnr)
          on_attach(client)
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

      -- LaTeX-specific functions
      local function tectonic_build()
        local filename = vim.fn.expand('%:p')
        local cmd = string.format('tectonic -X compile %s --keep-logs --keep-intermediates', filename)
        vim.fn.system(cmd)
        vim.notify('Built with Tectonic', vim.log.levels.INFO)
      end

      local function clean_build_dir()
        vim.fn.system('find . -name "*.aux" -type f -delete')
        vim.fn.system('find . -name "*.log" -type f -delete')
        vim.notify('Cleaned build directory', vim.log.levels.INFO)
      end

      local function tectonic_build_and_clean()
        vim.cmd('write')
        tectonic_build()
        clean_build_dir()
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
          -- Buffer local mappings.
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "<leader>gf", function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = ev.buf, desc = "Format document" })
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
          -- LaTeX-specific keymaps
          vim.keymap.set("n", "<leader>lb", tectonic_build_and_clean,
            { buffer = ev.bufnr, desc = "Build LaTeX with Tectonic" })
          vim.keymap.set("n", "<leader>lc", clean_build_dir, { buffer = ev.bufnr, desc = "Clean LaTeX build directory" })
        end,
      })
    end,
  },
}
