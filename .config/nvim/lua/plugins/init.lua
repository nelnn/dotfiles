return {
  "christoomey/vim-tmux-navigator",
  "xiyaowong/transparent.nvim",
  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>B", ":G blame<CR>", { desc = "Git blame" })
      vim.keymap.set("n", "<leader>D", ":Gvdiffsplit<CR>", { desc = "Git diff split" })
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end
  },
  {
    "mbbill/undotree",
    config = function()
      vim.keymap.set('n', '<leader>U', vim.cmd.UndotreeToggle, { desc = "Toggle undo tree" })
    end
  },

  -- Harpoon alternative
  {
    "otavioschwanck/arrow.nvim",
    dependencies = {
      { "echasnovski/mini.nvim" },
    },
    opts = {
      show_icons = true,
      leader_key = ';',                -- Recommended to be a single key
      buffer_leader_key = '<leader>m', -- Per Buffer Mappings
      hide_handbook = true,
      hide_buffer_handbook = true,
    }
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter').install {
        "lua", "vim", "vimdoc", "query",
        "python", "css", "javascript", "typescript",
        "html", "regex", "toml", "yaml", "typst",
        "markdown", "markdown_inline", "dockerfile",
      }
    end,
  },

  -- Completion
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = {
      -- "fang2hou/blink-copilot",
      'rafamadriz/friendly-snippets',
    },
    version = '1.*',
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      -- See :h blink-cmp-config-keymap for defining your own keymap
      keymap = {
        preset = 'default',

        ['<Tab>'] = { 'accept', 'fallback' },
        ['<C-j>'] = { 'show_documentation', 'fallback' },
      },

      appearance = {
        nerd_font_variant = 'mono'
      },

      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = false } },

      signature = { enabled = true },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            opts = {},
            score_offset = 1000,
          },
          snippets = {
            name = "Snippet",
            module = "blink.cmp.sources.snippets",
            score_offset = 800,
            async = true,
          },
        }
      },

      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
  },

  -- File Tree
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      columns = { "icon", "permissions", "size", "mtime" },
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<S-l>"] = "actions.select", -- remapped
        ["<C-s>"] = { "actions.select", opts = { vertical = true } },
        ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = { "actions.close", mode = "n" },
        ["<C-l>"] = "actions.refresh",
        ["<S-h>"] = { "actions.parent", mode = "n" }, -- remapped
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["`"] = { "actions.cd", mode = "n" },
        ["g~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
        ["gs"] = { "actions.change_sort", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
        ["g\\"] = { "actions.toggle_trash", mode = "n" },
      },
      -- Skip the confirmation popup for simple operations (:help oil.skip_confirm_for_simple_edits)
      skip_confirm_for_simple_edits = true,
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
        -- This function defines what is considered a "hidden" file
        is_hidden_file = function(name, bufnr)
          local m = name:match("^%.")
          return m ~= nil
        end,
        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, bufnr)
          return false
        end,
      },
      win_options = {
        signcolumn = "yes",
      },
    },
    dependencies = { { "nvim-mini/mini.nvim", opts = {} } },
    lazy = false,
    vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  },

  -- Fuzzy Finder
  {
    'ibhagwan/fzf-lua',
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<CR>",                desc = "Files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<CR>",            desc = "Grep" },
      { '<leader>fb', "<cmd>FzfLua buffers<CR>",              desc = "Buffers" },
      { '<leader>fh', "<cmd>FzfLua help_tags<CR>",            desc = "Help Tags" },
      { '<leader>fd', "<cmd>FzfLua git_commits<CR>",          desc = "Git Commits" },
      { '<leader>fm', "<cmd>FzfLua marks<CR>",                desc = "Marks" },
      { '<leader>:',  "<cmd>FzfLua command_history<CR>",      desc = "Command History" },
      { '<leader>fy', "<cmd>FzfLua registers<CR>",            desc = "Registers" },
      { "<leader>fw", "<cmd>FzfLua grep_cword<CR>",           desc = "Grep Word Under Cursor" },
      { "<leader>ft", "<cmd>FzfLua treesitter<CR>",           desc = "Treesitter" },
      { "<leader>fc", "<cmd>FzfLua awesome_colorschemes<CR>", desc = "Colour Picker" },
    },
    config = function()
      -- config runs once at plugin load time.
      -- If a colorscheme loads after, it resets all highlights — including FzfLuaCursorLine.
      -- By also registering the function as a ColorScheme autocmd, it re-runs every time
      -- a colorscheme is applied, keeping the highlight intact.
      local function set_hl()
        vim.api.nvim_set_hl(0, "FzfLuaCursorLine", { bg = "#8b0000", fg = "#ffffff" })
      end
      set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })
      local function save_colorscheme(selected, opts)
        require("fzf-lua.actions").colorscheme(selected, opts)
        local cs = vim.g.colors_name
        if cs then
          local f = io.open(vim.fn.stdpath("data") .. "/colorscheme", "w")
          if f then
            f:write(cs)
            f:close()
          end
        end
      end

      require("fzf-lua").setup({
        colorschemes = { actions = { ["default"] = save_colorscheme } },
        awesome_colorschemes = { actions = { ["default"] = save_colorscheme } },
        -- fzf_colors = {
        --   true,
        --   ["fg+"] = "#ffffff",
        --   ["bg+"] = "#8b0000",
        -- },
        file_icon_padding = ' ',
        defaults = {
          formatter = "path.filename_first",
        },
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
      })
    end,
  }
}
