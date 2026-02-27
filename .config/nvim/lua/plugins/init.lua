return {
  "christoomey/vim-tmux-navigator",
  "xiyaowong/transparent.nvim",
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require("rose-pine").setup()
      vim.cmd("colorscheme rose-pine")
    end,
  },
}
