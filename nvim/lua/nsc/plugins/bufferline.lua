return {
  'akinsho/bufferline.nvim',
  event = "VeryLazy",
  config = function()
    require("bufferline").setup {}
  end
}
