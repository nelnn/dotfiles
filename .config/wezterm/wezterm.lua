local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- config.color_scheme = 'AdventureTime'
config.enable_tab_bar = false
config.window_decorations = "RESIZE"

return config
