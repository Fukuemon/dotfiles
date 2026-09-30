-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- === 表示 ===
opt.relativenumber = true -- 相対行番号（LazyVim 標準だが明示しておく）
opt.cursorline = true
opt.scrolloff = 8 -- カーソル上下に常に確保する行数
opt.sidescrolloff = 8
opt.list = true -- 不可視文字を表示（全角スペースは autocmds.lua でハイライト）
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }

-- === 折り返し ===
-- 折り返しはデフォルト off（LazyVim 標準）。markdown / text だけ autocmds.lua で on にする。
opt.linebreak = true -- 折り返すときは単語の途中で切らない
opt.breakindent = true -- 折り返した行のインデントを揃える

-- === 日本語まわり ===
-- 全角括弧を % の対応候補に入れる
opt.matchpairs:append("（:）,「:」,『:』,【:】,〈:〉,《:》")
-- m: 日本語の任意の位置で折り返す / M: 結合時に空白を入れない / j: コメントリーダを賢く消す
opt.formatoptions:append("mMj")

-- === 編集 ===
opt.undofile = true -- undo をファイルに永続化（LazyVim 標準）
opt.undolevels = 10000
opt.confirm = true -- 未保存のまま終了しようとしたら確認する

-- === 検索 ===
opt.ignorecase = true
opt.smartcase = true -- 大文字を含む場合だけ大文字小文字を区別する
