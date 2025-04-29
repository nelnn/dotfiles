return {
  {
    "nelnn/bear.nvim",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    opts = {
      cache_dir = "~/.cache/nvim/bear",
      file_name = "df_debug" .. os.time() .. ".csv",
      window = {
        width = 0.9,
        height = 0.8,
        border = "rounded"
      },
      keymap = {
        visualise = "<Leader>df"
      }
    },
    config = function(_, opts)
      local df_visidata = require("bear")
      df_visidata.setup(opts)
    end,
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

      table.insert(dap.configurations.python, create_python_config("Autostock", "/projects/autostock"))
      table.insert(dap.configurations.python, create_python_config("Client Reports", "/projects/client-reports"))
      table.insert(dap.configurations.python, create_python_config("Perfect Workforce", "/projects/perfect_workforce"))
      table.insert(dap.configurations.python, create_python_config("Huboo Utils", "/lib/huboo-utils"))
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

      vim.keymap.set("n", "<Leader>dd", dap.run, {})
      vim.keymap.set("n", "<Leader>dr", dap.restart, {})
      vim.keymap.set("n", "<Leader>dt", dap.terminate, {})
      vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, {})
      vim.keymap.set("n", "<Leader>dc", dap.continue, {})
      vim.keymap.set("n", "<Leader>di", dap.step_into, {})
      vim.keymap.set("n", "<Leader>dn", dap.step_over, {})
      vim.keymap.set("n", "<Leader>do", dap.step_out, {})
      vim.keymap.set("n", "<Leader>dw", dapui.toggle, {})
    end,
  },
}
