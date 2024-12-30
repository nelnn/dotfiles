return {
  'norcalli/nvim-colorizer.lua',
  config = function()
    require('colorizer').setup {
      'css',
      'javascript',
      'vue',
      html = {
        mode = 'foreground',
      }
    }
  end
}
