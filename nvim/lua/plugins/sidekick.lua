return {
  -- LazyVimのsidekick extraをインポート（Copilot統合、キーマップ、lualine連携が自動設定される）
  { import = "lazyvim.plugins.extras.ai.sidekick" },

  -- Copilot LSPを有効化（NES機能に必要）
  {
    "neovim/nvim-lspconfig",
    opts = function()
      -- Copilot LSPを有効化
      vim.lsp.enable("copilot")
    end,
  },

  -- sidekick.nvimのカスタム設定
  {
    "folke/sidekick.nvim",
    opts = {
      -- NES (Next Edit Suggestions) 設定
      nes = {
        -- 提案のデバウンス遅延（ミリ秒）
        debounce = 100,
        -- Escキーで提案をクリア
        clear = {
          esc = true,
        },
        -- インラインdiffの粒度 ("words" / "chars" / false)
        diff = {
          inline = "words",
        },
      },
      -- CLI設定（AIツールとの連携）
      cli = {
        -- ファイル変更を監視
        watch = true,
        -- ウィンドウレイアウト
        win = {
          layout = "right",
        },
        -- デフォルトツール（Claude Codeを使用する場合）
        default = "claude",
      },
      -- ジャンプ設定
      jump = {
        -- ジャンプリストにエントリを追加
        jumplist = true,
      },
    },
  },

  -- better-escape.nvim: ターミナルモードからの離脱を簡単にする
  -- jkでノーマルモードに戻れるようになる（記事で推奨）
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    opts = {
      timeout = 200,
      default_mappings = true,
      mappings = {
        t = {
          j = {
            k = "<C-\\><C-n>",
          },
        },
      },
    },
  },
}
