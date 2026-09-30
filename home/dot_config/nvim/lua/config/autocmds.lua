-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local function augroup(name)
  return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end

-- 全角スペースを可視化する（listchars では表現できないため match で塗る）
-- ColorScheme のたびに定義し直さないと、テーマ切り替えでハイライトが消える。
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = augroup("ideographic_space"),
  callback = function()
    vim.api.nvim_set_hl(0, "IdeographicSpace", { link = "Error" })
  end,
})
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
  group = augroup("ideographic_space_match"),
  callback = function()
    vim.fn.matchadd("IdeographicSpace", "　")
  end,
})

-- 日本語を書くファイルは折り返す（LazyVim 標準の wrap+spell に加えて conceal を切る）
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_ja"),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.textwidth = 0
  end,
})

-- 挿入モードを抜けたら IME を英数に戻す。
-- macOS では `im-select` が要る。入っていなければ何もしない。
if vim.fn.has("mac") == 1 and vim.fn.executable("im-select") == 1 then
  vim.api.nvim_create_autocmd({ "InsertLeave", "FocusGained" }, {
    group = augroup("ime_off"),
    callback = function()
      vim.system({ "im-select", "com.apple.keylayout.ABC" }, { detach = true })
    end,
  })
end
