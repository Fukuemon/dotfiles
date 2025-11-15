local wezterm = require("wezterm")
local background = require("background")
local config = wezterm.config_builder()
config.automatically_reload_config = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.use_ime = true

-- Styles
config.font_size = 12.0
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

-- title bar & tab bar
config.hide_tab_bar_if_only_one_tab = true
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- 背景の設定（background.luaからレイヤー配列を取得）
-- background.luaはレイヤーの配列を返す
-- ドキュメント: https://wezterm.org/config/lua/config/background.html
config.background = require("background")

-- active tab
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background

  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

return config
