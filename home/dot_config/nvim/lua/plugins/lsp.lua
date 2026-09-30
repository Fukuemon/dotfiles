-- LSP 全体の振る舞い（言語ごとの設定は lang.lua）

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- 型やパラメータ名をバーチャルテキストで出す（<leader>uh でトグル）
      inlay_hints = { enabled = true },
      -- 参照数やテスト実行などの codelens（<leader>uL でトグル）
      codelens = { enabled = true },
      diagnostics = {
        -- どのリンタ / LSP が出した診断かを行末に出す
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
      },
      servers = {
        -- gopls は mise（go:golang.org/x/tools/gopls）で管理しているので
        -- mason 側で二重に入れない。
        gopls = { mason = false },
      },
    },
  },

  -- Mason の UI を開くキーマップは LazyVim 標準（:Mason）。
  -- ここでは「宣言したものは起動時に自動で入れる」だけ有効にしておく。
  {
    "mason-org/mason.nvim",
    opts = {
      ui = { border = "rounded" },
    },
  },
}
