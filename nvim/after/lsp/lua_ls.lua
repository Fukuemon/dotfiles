-- Lua言語サーバーの上書き設定
-- Neovim Runtimeの定義を読み込んでvimキーワードの警告を消す
-- Ref: https://zenn.dev/ras96/articles/4d9d9493d29c06

---@type vim.lsp.Config
return {
  settings = {
    Lua = {
      workspace = {
        library = {
          vim.env.VIMRUNTIME .. "/lua",
        },
      },
    },
  },
}

