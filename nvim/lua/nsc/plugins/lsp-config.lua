return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ensure_installed = {
          "debugpy",
          "texlab",
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
      local util = require("lspconfig.util")
      local on_attach = function(client)
        require("completion").on_attach(client)
      end

      -- Existing LSP setups...
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
      local mason_registry = require('mason-registry')
      local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
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
      lspconfig.lua_ls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.ruff_lsp.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })

      -- Advanced TexLab setup
      lspconfig.texlab.setup({
        capabilities = capabilities,
        settings = {
          texlab = {
            rootDirectory = nil,
            build = {
              executable = 'latexmk',
              args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
              onSave = false,
              forwardSearchAfter = false,
            },
            auxDirectory = '.',
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
      local texlab_build_status = {
        [0] = 'Success',
        [1] = 'Error',
        [2] = 'Failure',
        [3] = 'Cancelled',
      }

      local texlab_forward_status = {
        [0] = 'Success',
        [1] = 'Error',
        [2] = 'Failure',
        [3] = 'Unconfigured',
      }

      local function buf_build()
        local bufnr = vim.api.nvim_get_current_buf()
        local texlab_client = util.get_active_client_by_name(bufnr, 'texlab')
        if texlab_client then
          texlab_client.request('textDocument/build', vim.lsp.util.make_position_params(), function(err, result)
            if err then
              error(tostring(err))
            end
            vim.notify('Build ' .. texlab_build_status[result.status], vim.log.levels.INFO)
          end, bufnr)
        else
          vim.notify(
            'method textDocument/build is not supported by any servers active on the current buffer',
            vim.log.levels.WARN
          )
        end
      end

      local function buf_search()
        local bufnr = vim.api.nvim_get_current_buf()
        local texlab_client = util.get_active_client_by_name(bufnr, 'texlab')
        if texlab_client then
          texlab_client.request('textDocument/forwardSearch', vim.lsp.util.make_position_params(), function(err, result)
            if err then
              error(tostring(err))
            end
            vim.notify('Search ' .. texlab_forward_status[result.status], vim.log.levels.INFO)
          end, bufnr)
        else
          vim.notify(
            'method textDocument/forwardSearch is not supported by any servers active on the current buffer',
            vim.log.levels.WARN
          )
        end
      end

      local function cleanArtifacts()
        local bufnr = vim.api.nvim_get_current_buf()
        if not util.get_active_client_by_name(bufnr, 'texlab') then
          return vim.notify('Texlab client not found', vim.log.levels.ERROR)
        end
        vim.lsp.buf.execute_command {
          command = 'texlab.cleanArtifacts',
          arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
        }
        vim.notify('Artifacts cleaned successfully', vim.log.levels.INFO)
      end

      local function cleanAuxiliary()
        local bufnr = vim.api.nvim_get_current_buf()
        if not util.get_active_client_by_name(bufnr, 'texlab') then
          return vim.notify('Texlab client not found', vim.log.levels.ERROR)
        end
        vim.lsp.buf.execute_command {
          command = 'texlab.cleanAuxiliary',
          arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
        }
        vim.notify('Auxiliary files cleaned successfully', vim.log.levels.INFO)
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
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<space>ge", function()
            vim.diagnostic.open_float(0, { scope = "line" })
          end, { noremap = true, silent = true })
          -- LaTeX-specific keymaps
          if vim.bo[ev.buf].filetype == "tex" then
            vim.keymap.set("n", "<leader>lb", buf_build, { buffer = ev.buf, desc = "Build LaTeX document" })
            vim.keymap.set("n", "<leader>lf", buf_search, { buffer = ev.buf, desc = "Forward search" })
            vim.keymap.set("n", "<leader>lc", cleanArtifacts, { buffer = ev.buf, desc = "Clean LaTeX artifacts" })
            vim.keymap.set("n", "<leader>lC", cleanAuxiliary, { buffer = ev.buf, desc = "Clean LaTeX auxiliary files" })
            -- ... [Add other LaTeX-specific keymaps here]
          end
        end,
      })

      -- LaTeX-specific commands
      vim.api.nvim_create_user_command("TexlabBuild", buf_build, { desc = "Build the current buffer" })
      vim.api.nvim_create_user_command("TexlabForward", buf_search, { desc = "Forward search from current position" })
      -- ... [Add other LaTeX-specific commands here]
    end,
  },
}
