-- ファジーファインダー: fzf

return {
  "junegunn/fzf",
  build = ":call fzf#install()",
  dependencies = { "junegunn/fzf.vim" },
  cmd = { "FZF", "Files", "Buffers", "Rg" },
}

