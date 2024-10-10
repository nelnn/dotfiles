return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {},
  config = function()
    require("ibl").setup({
      enabled = true,
      scope = {
        enabled = true,
      },
      indent = {
        char = '▏',
      },
    })
  end,
}
