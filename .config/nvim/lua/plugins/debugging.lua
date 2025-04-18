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

    -- -- Add this function inside the config function of your original file
    -- local function visualize_dataframe_float()
    --   -- Check if we're in an active debug session
    --   local session = dap.session()
    --   if not session then
    --     vim.notify("No active debug session", vim.log.levels.ERROR)
    --     return
    --   end

    --   -- Get the variable under cursor or prompt for variable name
    --   local variable = vim.fn.expand("<cword>")
    --   if variable == "" then
    --     variable = vim.fn.input("Enter dataframe variable name: ")
    --     if variable == "" then
    --       vim.notify("No variable specified", vim.log.levels.WARN)
    --       return
    --     end
    --   end

    --   -- Create a temporary file in /tmp with a unique name
    --   local temp_file = "/tmp/df_debug.csv"

    --   -- Construct the Python expression for saving dataframe to CSV
    --   local expr = string.format([[
    --       try:
    --           try:
    --               import polars as pl
    --               is_polars_installed = True
    --           except ImportError:
    --               is_polars_installed = False

    --           import pandas as pd

    --           if '%s' not in locals() and '%s' not in globals():
    --               print("ERROR: Variable '%s' not found")
    --               exit()

    --           df_var = %s

    --           if not isinstance(df_var, pd.DataFrame):
    --               if is_polars_installed:
    --                   if not isinstance(df_var, pl.DataFrame) and not isinstance(df_var, pl.LazyFrame):
    --                       print("ERROR: '%s' is not a DataFrame, it's a " + str(type(df_var)))
    --                       exit()
    --               else:
    --                   print("ERROR: '%s' is not a pandas DataFrame, and polars is not installed.")
    --                   exit()

    --           if isinstance(df_var, pd.DataFrame):
    --               df_var.to_csv('%s', index=True)
    --           elif is_polars_installed and isinstance(df_var, pl.DataFrame):
    --               df_var.write_csv('%s')
    --           elif is_polars_installed and isinstance(df_var, pl.LazyFrame):
    --               df_var.collect().write_csv('%s')

    --           print("SUCCESS: DataFrame saved to %s")

    --       except Exception as e:
    --           print("ERROR: " + str(e))
    --   ]], variable, variable, variable, variable, variable, temp_file, temp_file, temp_file, temp_file, temp_file)

    --   -- Evaluate the expression using the session's evaluate method
    --   session:evaluate(expr, function(err, result)
    --     if err then
    --       vim.notify("Evaluation error: " .. vim.inspect(err), vim.log.levels.ERROR)
    --       return
    --     end

    --     if vim.fn.filereadable(temp_file) == 1 then
    --       vim.notify("DataFrame saved successfully to " .. temp_file, vim.log.levels.INFO)

    --       -- Create floating window
    --       local width = math.floor(vim.o.columns * 0.9)
    --       local height = math.floor(vim.o.lines * 0.8)
    --       local buf = vim.api.nvim_create_buf(false, true)

    --       local win = vim.api.nvim_open_win(buf, true, {
    --         relative = "editor",
    --         width = width,
    --         height = height,
    --         col = math.floor((vim.o.columns - width) / 2),
    --         row = math.floor((vim.o.lines - height) / 2),
    --         style = "minimal",
    --         border = "rounded"
    --       })

    --       -- Open visidata in the terminal buffer
    --       vim.fn.termopen("visidata " .. temp_file, {
    --         on_exit = function()
    --           -- Clean up the temporary file
    --           vim.fn.system("rm -f " .. temp_file)
    --         end
    --       })

    --       vim.cmd("startinsert")
    --     else
    --       vim.notify("Failed to export DataFrame: File not created", vim.log.levels.ERROR)
    --     end
    --   end)
    -- end

    -- -- Add this keymap at the end of your config function
    -- vim.keymap.set("n", "<Leader>df", visualize_dataframe_float, { desc = "Visualize DataFrame (float)" })

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
}
