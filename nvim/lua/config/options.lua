-- Neovim基本設定

vim.opt.shell = "/bin/zsh"
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.textwidth = 0
vim.opt.autoindent = true
vim.opt.hlsearch = true
vim.opt.clipboard = "unnamed"
vim.opt.termguicolors = true
vim.opt.syntax = "on"

-- fzf のランタイムパス設定
vim.opt.rtp:append("/usr/local/opt/fzf")

