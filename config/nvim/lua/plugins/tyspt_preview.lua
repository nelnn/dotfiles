return {
  'chomosuke/typst-preview.nvim',
  ft = 'typst',
  version = '1.*',
  opts = {
    dependencies_bin = { ['tinymist'] = 'tinymist' }
  },
  config = function(_, opts)
    require('typst-preview').setup(opts)
  end
}
