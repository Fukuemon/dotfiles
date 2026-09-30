-- テスト実行（neotest）とデバッガ（nvim-dap）
--
-- アダプタは言語 extras 側が足す:
--   Go     … neotest-golang / nvim-dap-go（delve は mason が入れる）
--   Python … neotest-python / nvim-dap-python
--   TS/JS  … neotest-vitest, neotest-jest / js-debug-adapter
--
-- 主なキーマップ（LazyVim 標準）:
--   <leader>tt 直近のファイルを実行 / <leader>tr カーソル位置のテスト / <leader>ts サマリ
--   <leader>db ブレークポイント / <leader>dc 継続 / <leader>du dap-ui トグル

return {
  { import = "lazyvim.plugins.extras.test.core" },
  { import = "lazyvim.plugins.extras.dap.core" },
}
