-- Neovim設定ファイル (エントリーポイント)
-- Ref: https://zenn.dev/ras96/articles/4d9d9493d29c06
-- Ref: https://neovim.io/doc/user/lua-guide.html#lua-guide-modules

-- 基本設定を読み込み
require("config.options")

-- lazy.nvimの設定とプラグイン読み込み
require("config.lazy")

-- LSP設定を読み込み
require("config.lsp")
