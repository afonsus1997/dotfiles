-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'
config.color_scheme = 'Abernathy'

-- config.font = wezterm.font 'Hack Nerd Font'

config.colors = {
  -- The default text color
  foreground = 'white',
  -- The default background color
  background = 'black',

  -- Overrides the cell background color when the current cell is occupied by the
  -- cursor and the cursor style is set to Block
  cursor_bg = '#52ad70',
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = 'black',
  -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- or the color of the vertical or horizontal bar when the cursor style is set to
  -- Bar or Underline.
  cursor_border = '#52ad70',

  -- the foreground color of selected text
  selection_fg = 'black',
  -- the background color of selected text
  selection_bg = '#fffacd',
}

config.window_padding = {
  left = 0,
  right = 0,
  top = 2,
  bottom = 0,
}


config.window_background_opacity = 0.5

config.font_size = 15

config.hide_tab_bar_if_only_one_tab = true

config.detect_password_input = true

config.keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to
  -- be potentially recognized and handled by the tab
  {
    key = 'Enter',
    mods = 'ALT',
    action = 'DisableDefaultAssignment'
  },
}


-- and finally, return the configuration to wezterm
return config

