return {
  {
    'ibhagwan/fzf-lua',
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>",           desc = "Files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>",       desc = "Grep" },
      { '<leader>fb', "<cmd>FzfLua buffers<CR>",         desc = "Buffers" },
      { '<leader>fh', "<cmd>FzfLua help_tags<CR>",       desc = "Help Tags" },
      { '<leader>fd', "<cmd>FzfLua git_commits<CR>",     desc = "Git Commits" },
      { '<leader>fm', "<cmd>FzfLua marks<CR>",           desc = "Marks" },
      { '<leader>:',  "<cmd>FzfLua command_history<CR>", desc = "Command History" },
      { '<leader>fy', "<cmd>FzfLua registers<CR>",       desc = "Registers" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<CR>",      desc = "Grep Word Under Cursor" },
      { "<leader>ft", "<cmd>FzfLua treesitter<CR>",      desc = "Treesitter" },
    },
    config = function()
      require("fzf-lua").setup {
        file_icon_padding = ' ',
        --   -- MISC GLOBAL SETUP OPTIONS, SEE BELOW
        --   -- fzf_bin = ...,
        --   winopts = { ...  },     -- UI Options
        --   keymap = { ...  },      -- Neovim keymaps / fzf binds
        --   actions = { ...  },     -- Fzf "accept" binds
        --   fzf_opts = { ...  },    -- Fzf CLI flags
        --   fzf_colors = { ...  },  -- Fzf `--color` specification
        --   hls = { ...  },         -- Highlights
        --   previewers = { ...  },  -- Previewers options
        --   -- SPECIFIC COMMAND/PICKER OPTIONS, SEE BELOW
        --   -- files = { ... },
        keymap = {
          -- Below are the default binds, setting any value in these tables will override
          -- the defaults, to inherit from the defaults change [1] from `false` to `true`
          builtin = {
            -- neovim `:tmap` mappings for the fzf win
            -- true,        -- uncomment to inherit all the below in your custom config
            ["<M-Esc>"]    = "hide", -- hide fzf-lua, `:FzfLua resume` to continue
            ["<F1>"]       = "toggle-help",
            ["<F2>"]       = "toggle-fullscreen",
            -- Only valid with the 'builtin' previewer
            ["<F3>"]       = "toggle-preview-wrap",
            ["<F4>"]       = "toggle-preview",
            -- Rotate preview clockwise/counter-clockwise
            ["<F5>"]       = "toggle-preview-ccw",
            ["<F6>"]       = "toggle-preview-cw",
            -- `ts-ctx` binds require `nvim-treesitter-context`
            ["<F7>"]       = "toggle-preview-ts-ctx",
            ["<F8>"]       = "preview-ts-ctx-dec",
            ["<F9>"]       = "preview-ts-ctx-inc",
            ["<S-Left>"]   = "preview-reset",
            ["<S-down>"]   = "preview-page-down",
            ["<S-up>"]     = "preview-page-up",
            ["<M-S-down>"] = "preview-down",
            ["<M-S-up>"]   = "preview-up",
            ["<c-f>"]      = "preview-page-down",
            ["<c-b>"]      = "preview-page-up",
          },
          fzf = {
            -- fzf '--bind=' options
            -- true,        -- uncomment to inherit all the below in your custom config
            ["ctrl-z"]     = "abort",
            -- ["ctrl-u"]     = "unix-line-discard",
            -- ["ctrl-f"]     = "half-page-down",
            -- ["ctrl-b"]     = "half-page-up",
            ["ctrl-a"]     = "beginning-of-line",
            ["ctrl-e"]     = "end-of-line",
            ["alt-a"]      = "toggle-all",
            ["alt-g"]      = "first",
            ["alt-G"]      = "last",
            -- Only valid with fzf previewers (bat/cat/git/etc)
            ["f3"]         = "toggle-preview-wrap",
            ["f4"]         = "toggle-preview",
            ["shift-down"] = "preview-page-down",
            ["shift-up"]   = "preview-page-up",

            ["ctrl-q"]     = "select-all+accept",
            ["ctrl-u"]     = "half-page-up",
            ["ctrl-d"]     = "half-page-down",
            ["ctrl-x"]     = "jump",
          },
        },
      }
    end,

  }
}
