return {
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
  }
}
