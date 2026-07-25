-- blink.cmp: 高速な補完プラグイン（nvim-cmpの代替）
-- LazyVimのblink.cmp extraを使用

return {
  -- LazyVimのblink.cmp extraをインポート（nvim-cmpを無効化してblink.cmpに切り替え）
  { import = "lazyvim.plugins.extras.coding.blink" },

  -- blink.cmpのカスタム設定
  {
    "saghen/blink.cmp",
    opts = {
      -- キーマップ: 'default', 'super-tab', 'enter' から選択
      keymap = { preset = "default" },
      appearance = {
        -- Nerd Fontの種類: 'mono' or 'normal'
        nerd_font_variant = "mono",
      },
      completion = {
        -- ドキュメントポップアップを手動トリガー時のみ表示
        documentation = { auto_show = true },
      },
      -- 有効なソース
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      -- Rustファジーマッチャー（タイポ耐性と高速化）
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
