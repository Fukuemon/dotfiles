-- ファイルツリー: NERDTree

return {
  "preservim/nerdtree",
  cmd = { "NERDTree", "NERDTreeToggle", "NERDTreeFind" },
  init = function()
    -- NERDTreeを引数なしで起動した時に自動起動
    vim.api.nvim_create_autocmd("StdinReadPre", {
      callback = function()
        vim.g.std_in = 1
      end,
    })
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 and not vim.g.std_in then
          vim.cmd("NERDTree")
        end
      end,
    })
  end,
}

