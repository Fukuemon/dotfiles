-- Yazi init.lua
--
-- 公式/Minerva 記事に寄せて、必要なプラグインは init.lua で `setup()` します。
--
-- 参考:
-- - Minerva 記事: https://minerva.mamansoft.net/2025-09-14-yazi-tui-file-manager-finder-replacement#zoxide.lua%20(Yazi)%20zoxide.lua
-- - Yazi CLI（ya pkg）: https://yazi-rs.github.io/docs/cli

-- smart-enter（複数選択を open 対象にしたい場合）
do
  local ok, se = pcall(require, "smart-enter")
  if ok and se and type(se.setup) == "function" then
    se:setup {
      open_multi = true,
    }
  end
end

-- full-border（UI を枠線で強化）
do
  local ok, fb = pcall(require, "full-border")
  if ok and fb and type(fb.setup) == "function" then
    fb:setup {
      type = ui.Border.ROUNDED,
    }
  end
end

-- zoxide.lua（ビルトイン拡張）: yazi 操作中の移動も zoxide DB に登録する
do
  local ok, zx = pcall(require, "zoxide")
  if ok and zx and type(zx.setup) == "function" then
    zx:setup {
      update_db = true,
    }
  end
end

-- bunny.yazi（ブックマークで移動）
-- `e` でメニューを開く（keymap 側で `plugin bunny`）
do
  local ok, bunny = pcall(require, "bunny")

  local hops = {
    { key = "f", path = "~/src/github.com/Fukuemon", desc = "Fukuemon" },
    { key = "c", path = "~/.config", desc = "Config files" },
  }

  -- マシン固有の hop は ~/.config/yazi/local.lua に置く（hops のテーブルを return する）。
  -- 公開したくないパスをこのリポジトリに載せないための逃げ道。
  -- ファイルが無ければ何もしない。
  local local_ok, extra = pcall(dofile, (os.getenv("HOME") or "") .. "/.config/yazi/local.lua")
  if local_ok and type(extra) == "table" then
    for _, hop in ipairs(extra) do
      table.insert(hops, hop)
    end
  end

  if ok and bunny and type(bunny.setup) == "function" then
    bunny:setup {
      hops = hops,
      desc_strategy = "path",
      ephemeral = true,
      tabs = true,
      notify = false,
      fuzzy_cmd = "fzf",
    }
  end
end


