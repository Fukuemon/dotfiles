local wezterm = require("wezterm")

-- 背景画像のパスを設定
-- [HOME]はsetup.shで$HOMEに置き換えられます
local background_image = "[HOME]/.config/wezterm/background/メガカイリュー.jpg"

-- グラデーションレイヤー
local gradient_layer = {
  source = {
    Gradient = {
      colors = { "#287C95", "#1C517C" },
      orientation = {
        Linear = { angle = -30.0 },
      },
    },
  },
  opacity = 1,
  width = "100%",
  height = "100%",
}

-- 画像レイヤー
local image_layer = {
  source = { File = background_image },
  opacity = 0.2,
  vertical_align = "Middle", -- 上下中央揃え
  horizontal_align = "Right", -- 右揃え
  horizontal_offset = "0px",
  repeat_x = "NoRepeat",
  repeat_y = "NoRepeat",

  width = "50%",
  height = "100%",
}
-- デフォルトのbackground（グラデーション + 画像）
local default_bg = {
  gradient_layer,
  image_layer,
}

-- Neovim使用時のbackground（グラデーションのみ）
local neovim_bg = {
  gradient_layer,
}

local prev_process_name = nil

wezterm.on("update-status", function(window, pane)
  -- フォアグラウンドプロセスの名前を取得
  local process_name = pane:get_foreground_process_name()

  -- 前のプロセス名と同じであればなにもしない
  if process_name == prev_process_name then
    return
  end

  -- プロセス名にnvimが含まれているか判定
  local new_background = process_name and process_name:find("nvim") and neovim_bg or default_bg

  -- 背景を切り替え
  window:set_config_overrides({
    background = new_background,
  })

  prev_process_name = process_name
end)

-- デフォルトのbackgroundを返す（wezterm.luaで使用）
return default_bg