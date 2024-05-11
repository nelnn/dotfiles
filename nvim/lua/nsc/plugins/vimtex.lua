return {
  "lervag/vimtex",
  lazy = false, -- we don't want to lazy load VimTeX
  -- tag = "v2.15", -- uncomment to pin to a specific release
  init = function()
    -- VimTeX configuration goes here
    vim.g.maplocalleader = " "
  end
}

-- leader ll = start compiling.
-- leader lk = stop compiling.
-- leader lc = clean auxiliary files.
