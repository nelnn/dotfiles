require("core.remap")
require("core.settings")
require("core.shortcuts")

local lazypath = vim.fn.stdpath("data") .. "lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- vim.cmd("colorscheme lunaperche")
-- vim.cmd([[ highlight Normal ctermbg=NONE guibg=NONE ]])
vim.cmd([[set linebreak]])

require("lazy").setup("plugins", {
  change_detection = {
    notify = false,
  },
})

local ejj = eee
return eee
