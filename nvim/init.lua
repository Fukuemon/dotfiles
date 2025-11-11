-- NeoVim設定ファイル (lazy.nvim)

-- 基本設定
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

-- セットアップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- プラグイン設定
require("lazy").setup({
  -- カラースキーム
  {
    "ntk148v/vim-horizon",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme horizon")
      vim.api.nvim_set_hl(0, "Normal", { bg = "#2e2e2e", fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "Cursor", { fg = "black", bg = "white" })
      vim.api.nvim_set_hl(0, "lCursor", { fg = "white", bg = "black" })
      vim.api.nvim_set_hl(0, "Visual", { bg = "#44475a", fg = "NONE" })
      vim.opt.guicursor = "n-v-c:block-Cursor/lCursor"
    end,
  },

  -- ファイルツリー
  {
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
  },

  -- ファジーファインダー
  {
    "junegunn/fzf",
    build = ":call fzf#install()",
    dependencies = { "junegunn/fzf.vim" },
    cmd = { "FZF", "Files", "Buffers", "Rg" },
  },

  -- Treesitter (シンタックスハイライト)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "c",
          "cpp",
          "css",
          "go",
          "html",
          "javascript",
          "json",
          "lua",
          "python",
          "rust",
          "typescript",
          "yaml",
        },
        highlight = {
          enable = true,
        },
      })
    end,
  },

  -- Mason (LSP インストーラー)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason LSP Config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "tsserver",
          "pyright",
          "html",
          "cssls",
          "emmet_ls",
          "rust_analyzer",
          "yamlls",
          "jsonls",
        },
      })
    end,
  },

  -- blink.cmp (補完)
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
      -- 'super-tab' for mappings similar to vscode (tab to accept)
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      keymap = { preset = "default" },
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        nerd_font_variant = "mono",
      },
      -- (Default) Only show the documentation popup when manually triggered
      completion = { documentation = { auto_show = false } },
      -- Default list of enabled providers
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      -- Rust fuzzy matcher for typo resistance and significantly better performance
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      require("lsp")
    end,
  },


  -- Lualine (ステータスライン)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "ntk148v/vim-horizon" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "horizon",
        },
      })
    end,
  },

  -- Gitsigns (git gutter)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          vim.keymap.set("n", "<leader>hn", require("gitsigns").next_hunk, { buffer = bufnr })
          vim.keymap.set("n", "<leader>hp", require("gitsigns").prev_hunk, { buffer = bufnr })
        end,
      })
    end,
  },
})

-- fzf のランタイムパス設定
vim.opt.rtp:append("/usr/local/opt/fzf")

