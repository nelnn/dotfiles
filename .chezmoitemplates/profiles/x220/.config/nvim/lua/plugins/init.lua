return {
  -- JW's theme
  {
    "dgrco/deepwater.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("deepwater")
    end,
  },
  "christoomey/vim-tmux-navigator",
  "xiyaowong/transparent.nvim",
}
