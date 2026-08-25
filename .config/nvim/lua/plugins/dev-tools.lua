return {
  {
    "ej-shafran/compile-mode.nvim",
    version = "^5.0.0",
    -- branch = "latest",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      ---@type CompileModeOpts
      vim.g.compile_mode = {
        -- if you use something like `nvim-cmp` or `blink.cmp` for completion,
        -- set this to fix tab completion in command mode:
        input_word_completion = true,

        -- to add ANSI escape code support, add:
        -- baleia_setup = true,

        -- to make `:Compile` replace special characters (e.g. `%`) in
        -- the command (and behave more like `:!`), add:
        -- bang_expansion = true,
      }
      vim.keymap.set("n", "<leader>r", "<CMD>Recompile<CR>", { desc = "Recompile" })
      vim.keymap.set("n", "<leader>cc", ":Compile ", { desc = "Compile" })
    end,
  },

  {
    dir = "/Users/nsc/projects/bear.pr",
    -- "nelnn/bear.nvim",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    -- opts = {},
    -- opts = {
    --   cache_dir = "~/.cache/nvim/bear",
    --   file_name = "tmp_" .. os.date("%m%d_%H%M%S") .. ".csv",
    --   remove_file = false,
    --   window = {
    --     width = 0.9,
    --     height = 0.8,
    --     border = "rounded"
    --   },
    --   keymap = {
    --     visualise = "<Leader>df",
    --     visualise_buf = "<leader>bdf",
    --   }
    -- },
    config = function(_, opts)
      local df_visidata = require("bear")
      df_visidata.setup(opts)
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    lazy = true,
    ft = { "html", "vue", "ts", "tsx" },
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          -- Defaults
          enable_close = true,         -- Auto close tags
          enable_rename = true,        -- Auto rename pairs of tags
          enable_close_on_slash = true -- Auto close on trailing </
        },
        -- Also override individual filetype configs, these take priority.
        -- Empty by default, useful if one of the "opts" global settings
        -- doesn't work well in a specific filetype
        -- per_filetype = {
        --   ["html"] = {
        --     enable_close = false
        --   }
        -- }
      })
    end
  },

  {
    "mfussenegger/nvim-dap",
    ft = "python",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mfussenegger/nvim-dap-python",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      local dap, dapui = require("dap"), require("dapui")
      require("dap-python").setup(path)
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "watches",     size = 0.20 },
              { id = "scopes",      size = 0.40 },
              { id = "breakpoints", size = 0.20 },
              { id = "stacks",      size = 0.20 },
            },
            size = 30,
            position = "left",
          },
          {
            elements = {
              -- { id = "console", size = 0.25 },
              { id = "repl", size = 1 },
            },
            size = 10,
            position = "bottom",
          },
        },
      })

      -- Python Debugging configuration. Set cwd as root directory.
      -- !Important: PYTHONPATH starts with "/Users/..."
      local function create_python_config(name, project_path)
        local cwd = vim.fn.getcwd() .. project_path
        return {
          type = "python",
          request = "launch",
          name = name,
          program = "${file}",
          cwd = function()
            print(cwd)
            return cwd
          end,
          env = {
            PYTHONPATH = cwd .. ":${env:PYTHONPATH}"
          }
        }
      end

      table.insert(dap.configurations.python, create_python_config("Root", ""))

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.toggle()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.toggle()
      end

      vim.keymap.set("n", "<Leader>dd", dap.run, { desc = "DAP run" })
      vim.keymap.set("n", "<Leader>dr", dap.restart, { desc = "DAP restart" })
      vim.keymap.set("n", "<Leader>dt", dap.terminate, { desc = "DAP terminate" })
      vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "DAP toggle breakpoint" })
      vim.keymap.set("n", "<Leader>dc", dap.continue, { desc = "DAP continue" })
      vim.keymap.set("n", "<Leader>di", dap.step_into, { desc = "DAP step into" })
      vim.keymap.set("n", "<Leader>dn", dap.step_over, { desc = "DAP step over" })
      vim.keymap.set("n", "<Leader>do", dap.step_out, { desc = "DAP step out" })
      vim.keymap.set("n", "<Leader>dw", dapui.toggle, { desc = "DAP toggle UI" })
    end,
  },

  -- Below are LSP Stuff
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "clangd",
          "bashls",
          "tailwindcss",
          "lua_ls",
          "ts_ls",
          "vue_ls",
          "ty",
          "ruff",
          "gopls",
          "tinymist",
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
        ty = {},
        ruff = {},
        gopls = {},
        vue_ls = {},
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
      local on_attach = function(_, bufnr)
        vim.keymap.set("n", "<leader>gf", function() vim.lsp.buf.format({ async = true }) end,
          { buffer = bufnr, desc = "Format buffer" })
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
      end
      for server, config in pairs(opts.servers) do
        config.on_attach = on_attach
        vim.lsp.config(server, config)
      end
    end,
  },
}
