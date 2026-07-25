# Neovim Configuration

LazyVimをベースにしたNeovim設定です。AI支援コーディング機能を重視した構成になっています。

## 要件

- Neovim >= 0.11.2
- Git
- [Nerd Font](https://www.nerdfonts.com/)（アイコン表示用）
- [yazi](https://github.com/sxyazi/yazi)（ファイルマネージャー）
- [claude](https://claude.ai/claude-code)（AI CLI）

## ディレクトリ構成

```
nvim/
├── init.lua                 # エントリーポイント
├── lua/
│   ├── config/
│   │   ├── lazy.lua         # lazy.nvim設定
│   │   ├── options.lua      # Neovimオプション
│   │   ├── keymaps.lua      # カスタムキーマップ
│   │   └── autocmds.lua     # 自動コマンド
│   └── plugins/
│       ├── sidekick.lua     # AI支援（sidekick.nvim）
│       ├── blink-cmp.lua    # 補完エンジン
│       └── yazi.lua         # ファイルマネージャー
└── lazy-lock.json           # プラグインバージョンロック
```

## プラグイン構成

### ベース
- **[LazyVim](https://www.lazyvim.org/)** - Neovimディストリビューション
- **[lazy.nvim](https://github.com/folke/lazy.nvim)** - プラグインマネージャー

### AI支援 (sidekick.lua)

#### sidekick.nvim
Copilot LSPのNext Edit Suggestions (NES)とAI CLIツールを統合するプラグイン。

| 設定項目 | 値 | 説明 |
|---------|-----|------|
| `nes.debounce` | 100ms | 提案リクエストの遅延 |
| `nes.clear.esc` | true | Escキーで提案をクリア |
| `nes.diff.inline` | "words" | 単語単位のインラインdiff |
| `cli.default` | "claude" | デフォルトAIツール |
| `cli.win.layout` | "right" | CLIウィンドウを右側に表示 |

**キーマップ:**

| キー | モード | 説明 |
|------|--------|------|
| `<Tab>` | n | NES提案を適用/次へジャンプ |
| `<C-.>` | n/i/v | CLIターミナルをトグル |
| `<leader>aa` | n | CLIをトグル |
| `<leader>as` | n | CLIツールを選択 |
| `<leader>ad` | n | CLIセッションを切断 |
| `<leader>at` | n/v | 選択内容をAIに送信 |
| `<leader>af` | n | ファイル全体をAIに送信 |
| `<leader>ap` | n/v | プロンプトを選択 |
| `<leader>uN` | n | NESのトグル |

#### better-escape.nvim
ターミナルモードからの離脱を簡単にするプラグイン。

| キー | モード | 説明 |
|------|--------|------|
| `jk` | i/t | ノーマルモードに戻る |

### 補完 (blink-cmp.lua)

#### blink.cmp
Rustで書かれた高速な補完エンジン。nvim-cmpの代替。

| 設定項目 | 値 | 説明 |
|---------|-----|------|
| `keymap.preset` | "default" | C-yで補完を確定 |
| `appearance.nerd_font_variant` | "mono" | Nerd Font Mono使用 |
| `completion.documentation.auto_show` | true | ドキュメント自動表示 |
| `fuzzy.implementation` | "prefer_rust_with_warning" | Rustファジーマッチャー |

**補完ソース:** LSP, Path, Snippets, Buffer

**キーマップ:**

| キー | 説明 |
|------|------|
| `<C-y>` | 補完を確定 |
| `<C-n>` | 次の候補 |
| `<C-p>` | 前の候補 |
| `<C-Space>` | 補完を手動トリガー |

### ファイルマネージャー (yazi.lua)

#### yazi.nvim
ターミナルベースの高速ファイルマネージャーyaziをNeovimから使用。

| キー | モード | 説明 |
|------|--------|------|
| `<leader>-` | n/v | 現在のファイルでyaziを開く |
| `<leader>fy` | n | yaziを開く |
| `<leader>cw` | n | 作業ディレクトリでyaziを開く |
| `<C-Up>` | n | 前回のyaziセッションを再開 |
| `<F1>` | - | yazi内でヘルプを表示 |

## LazyVim Extras

以下のLazyVim Extrasが有効になっています：

- `lazyvim.plugins.extras.ai.sidekick` - Sidekick AI統合
- `lazyvim.plugins.extras.coding.blink` - blink.cmp補完

## セットアップ

### 1. Copilot認証（NES機能を使う場合）

```vim
:LspCopilotSignIn
```

ブラウザでGitHubにサインインしてデバイスコードを入力。

### 2. ヘルスチェック

```vim
:checkhealth sidekick
:checkhealth lazy
```

### 3. プラグイン管理

```vim
:Lazy              " プラグインマネージャーを開く
:Lazy sync         " プラグインを同期
:Lazy update       " プラグインを更新
```

## LazyVimに含まれる主要プラグイン

LazyVimには以下のプラグインがデフォルトで含まれています：

| カテゴリ | プラグイン |
|---------|-----------|
| LSP | nvim-lspconfig, mason.nvim |
| Treesitter | nvim-treesitter |
| ファイラー | neo-tree.nvim |
| Fuzzy Finder | telescope.nvim |
| Git | gitsigns.nvim, lazygit |
| UI | lualine.nvim, bufferline.nvim |
| カラースキーム | tokyonight.nvim |

詳細: https://www.lazyvim.org/plugins

## 参考リンク

- [LazyVim Documentation](https://www.lazyvim.org/)
- [sidekick.nvim](https://github.com/folke/sidekick.nvim)
- [blink.cmp](https://github.com/saghen/blink.cmp)
- [yazi.nvim](https://github.com/mikavilpas/yazi.nvim)
- [better-escape.nvim](https://github.com/max397574/better-escape.nvim)
