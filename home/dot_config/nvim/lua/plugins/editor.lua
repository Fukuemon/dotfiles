-- 編集まわりの強化（LazyVim 標準に含まれないもの）
--
-- 標準で入っているので足していないもの:
--   flash.nvim（移動）/ grug-far.nvim（一括置換 <leader>sr）/ todo-comments /
--   gitsigns / trouble / mini.ai（テキストオブジェクト）/ ts-comments（コメント）

return {
  -- LSP rename をインクリメンタルにプレビューする（<leader>cr）
  { import = "lazyvim.plugins.extras.editor.inc-rename" },
  -- 変数抽出 / 関数抽出などのリファクタリング（<leader>r）
  -- refactoring.nvim は Neovim 0.12 以上が必要（devbox global の neovim で満たす）
  { import = "lazyvim.plugins.extras.editor.refactoring" },
  -- カーソル下のシンボルと同じものをハイライト、]] / [[ で移動
  { import = "lazyvim.plugins.extras.editor.illuminate" },
  -- <C-a> / <C-x> の対象を拡張（true/false、日付、hex など）
  { import = "lazyvim.plugins.extras.editor.dial" },
  -- <M-h/j/k/l> で行・選択範囲を移動
  { import = "lazyvim.plugins.extras.editor.mini-move" },
  -- sa / sd / sr で囲み文字を追加・削除・置換
  { import = "lazyvim.plugins.extras.coding.mini-surround" },
  -- hex カラーや TODO などのパターンを色付け
  { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
  -- 画面外まで続く関数・ブロックの見出しを上部に固定表示
  { import = "lazyvim.plugins.extras.ui.treesitter-context" },
}
