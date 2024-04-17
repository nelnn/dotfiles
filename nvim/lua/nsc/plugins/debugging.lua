return {
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
    dapui.setup()

    -- Python Debugging configuration. Set cwd as root directory.
    table.insert(require("dap").configurations.python, {
      type = "python",
      request = "launch",
      name = "Client Reports",
      program = "${file}",
      cwd = vim.fn.getcwd() .. "/projects/client-reports",
    })

    table.insert(require("dap").configurations.python, {
      type = "python",
      request = "launch",
      name = "Perfect Workforce",
      program = "${file}",
      cwd = vim.fn.getcwd() .. "/projects/perfect_workforce",
    })

    table.insert(require("dap").configurations.python, {
      type = "python",
      request = "launch",
      name = "Huboo Utils",
      program = "${file}",
      cwd = vim.fn.getcwd() .. "/lib/huboo-utils",
    })

    table.insert(require("dap").configurations.python, {
      type = "python",
      request = "launch",
      name = "Root",
      program = "${file}",
      cwd = vim.fn.getcwd(),
    })

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
    vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, {})
    vim.keymap.set("n", "<Leader>dc", dap.continue, {})
    vim.keymap.set("n", "<Leader>dw", dapui.toggle, {})
  end,
}
