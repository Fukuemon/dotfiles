# dotfiles

dotfiles やその他設定ファイルを管理するためのリポジトリです。

## 構成

このリポジトリには以下の設定ファイルが含まれています：

- **wezterm**: ターミナルエミュレータの設定

  - `wezterm/wezterm.lua`: メイン設定ファイル
  - `wezterm/keybinds.lua`: キーバインド設定
  - `wezterm/background.lua`: 背景画像設定
  - `wezterm/background/change_bg.sh`: 背景画像切り替えスクリプト

- **zsh**: シェル設定

  - `zsh/.zshrc`: zsh 設定ファイル（sheldon 使用）
  - `zsh/sheldon.toml`: sheldon プラグイン設定

- **nvim**: NeoVim 設定

  - `nvim/init.lua`: エントリーポイント
  - `nvim/lua/config/`: 設定ファイル
    - `lazy.lua`: lazy.nvim 設定
    - `lsp.lua`: LSP 設定
    - `options.lua`: 基本設定
  - `nvim/lua/plugins/`: プラグイン設定（各プラグインごとにファイル分割）
  - `nvim/after/lsp/`: 言語サーバー上書き設定

- **yazi**: TUI ファイルマネージャー設定

  - `yazi/yazi.toml`: 基本設定（Neovim 統合設定含む）
  - `yazi/keymap.toml`: キーバインド設定
  - `yazi/theme.toml`: カラースキーム設定
  - `yazi/init.lua`: yazi 起動時にプラグインを初期化（bunny/full-border 等）
  - `yazi/README.md`: プラグイン導入（`ya pkg`）などのメモ

- **zellij**: ターミナルマルチプレクサ設定（設定ファイルは含まれていません）

## セットアップ

### 前提条件

以下のツールがインストールされている必要があります：

- [devbox](https://www.jetify.com/docs/devbox/devbox-global) - グローバルに CLI を管理（Nix ベース）
- [mise](https://mise.jdx.dev/getting-started.html) - ランタイム/一部 CLI を管理
- [wezterm](https://wezfurlong.org/wezterm/) - ターミナルエミュレータ
- [nvim](https://neovim.io/) - エディタ（devbox で導入）
- [sheldon](https://github.com/rossmacarthur/sheldon) - zsh プラグインマネージャー（devbox で導入）
- [yazi](https://github.com/sxyazi/yazi) - TUI ファイルマネージャー（devbox で導入）
- [zellij](https://zellij.dev/) - ターミナルマルチプレクサ（オプション）

### パッケージマネージャー方針（mise 統一）

`brew` と `mise` の混在を避けるため、原則として **ランタイムは `mise`**、CLI は **mise（aqua バックエンド優先）→ 必要に応じて devbox（global）** に寄せ、`brew` は **GUI/OS 統合が強いもの**に限定します。

- 方針（ADR）: `docs/adr/000001-package-manager-unification-mise-vs-devbox.md`
- 移行手順: `docs/mise-migration.md`
- mise に入っていないツールの管理: `docs/devbox-setup.md`（devbox/Nix）
- brew の棚卸し/整理: `docs/brew-audit.md`

#### ツール一覧を dotfiles で管理する

- **mise**: `mise/config.toml` を `~/.config/mise/config.toml` に symlink（`setup.sh` が対応）
  - 反映: `mise trust ~/src/github.com/Fukuemon/dotfiles/mise/config.toml` → `mise install`（dotfiles の配置に合わせてパスを調整）
- **devbox global**: `devbox/global-packages.txt` を唯一の真実として管理
  - 反映: `bash ./scripts/devbox-global-sync.sh`
  - 追加オプション: `STRICT=1`（宣言外検出）, `STRICT=1 APPLY_REMOVE=1`（宣言外削除）, `NO_BACKUP=1`（バックアップ無効）

### 自動セットアップ

`setup.sh` スクリプトを実行して自動的にセットアップできます：

```bash
./setup.sh
```

このスクリプトは以下を実行します：

1. 必要なディレクトリの作成
2. シンボリックリンクの作成
3. sheldon のインストール確認と初期化
4. lazy.nvim の自動インストール確認

オプション:

```bash
# mise のツールを自動導入
MISE_INSTALL=1 ./setup.sh

# devbox global を宣言ファイルに同期
DEVBOX_GLOBAL_SYNC=1 ./setup.sh
```

### 手動セットアップ

#### 1. リポジトリのクローン

```bash
git clone https://github.com/Fukuemon/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

#### 2. zsh 設定のセットアップ

```bash
# mise のインストール（公式手順）
curl https://mise.run | sh

# devbox のインストール（公式手順）
curl -fsSL https://get.jetify.com/devbox | bash

# 新しいシェルを開いて反映
exec zsh -l

# sheldon を含む CLI を devbox global で導入（どのディレクトリでも使える）
devbox global add neovim sheldon yazi git

# シンボリックリンクを作成
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/sheldon.toml ~/.config/sheldon/plugins.toml

# sheldonでプラグインをインストール
sheldon lock --update
```

#### 3. nvim 設定のセットアップ

```bash
# 設定ディレクトリを作成
mkdir -p ~/.config/nvim

# シンボリックリンクを作成
ln -sf ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/dotfiles/nvim/lua ~/.config/nvim/lua

# nvimを起動するとlazy.nvimが自動的にインストールされます
nvim
```

#### 4. yazi 設定のセットアップ

```bash
# 設定ディレクトリを作成
mkdir -p ~/.config/yazi

# シンボリックリンクを作成
ln -sf ~/dotfiles/yazi/yazi.toml ~/.config/yazi/yazi.toml
ln -sf ~/dotfiles/yazi/keymap.toml ~/.config/yazi/keymap.toml
ln -sf ~/dotfiles/yazi/theme.toml ~/.config/yazi/theme.toml
```

## 使用方法

### zsh プラグインの管理

プラグインの追加・削除は `zsh/sheldon.toml` を編集し、以下のコマンドで更新します：

```bash
sheldon lock --update
```

### nvim プラグインの管理

プラグインの追加・削除は `nvim/init.lua` を編集します。lazy.nvim が自動的にプラグインをインストール・更新します。

プラグインの手動更新：

```bash
nvim
# nvim内で :Lazy update を実行
```

### yazi ファイルマネージャー

Yazi は高速な TUI ファイルマネージャーです。以下のコマンドで起動できます：

```bash
yazi
```

#### Neovim との統合

**Neovim から Yazi を開く:**

以下のキーバインドで Yazi を開けます：

- `<leader>-` または `<leader>fy`: 現在のファイルのディレクトリで Yazi を開く
- `<leader>cw`: Neovim の作業ディレクトリで Yazi を開く
- `<c-up>`: 最後の Yazi セッションを再開

Yazi はフローティングウィンドウとして表示され、ファイルを選択すると Neovim で開けます。

**Yazi から Neovim でファイルを開く:**

以下の方法で Neovim でファイルを開けます：

- `e`: 選択したファイルを Neovim で編集（エディタで開く）
- `E`: 複数ファイルを選択して Neovim で編集
- `<Enter>`: Neovim で編集して開く
- `o`: インタラクティブに開く方法を選択

`yazi.toml` の `[opener]` セクションで、テキストファイルは自動的に Neovim で開くように設定されています。

#### 基本的な操作

- `h`: 親ディレクトリに移動
- `l`: ディレクトリに入る / ファイルを開く
- `j`/`k`: 上下に移動
- `v`: ビジュアルモード（複数選択）
- `c`: コピー
- `x`: カット
- `p`: ペースト
- `d`: 削除
- `e`: Neovim で編集
- `E`: 複数ファイルを Neovim で編集
- `o`: インタラクティブに開く
- `q`: 終了

#### プラグイン管理

Yazi のプラグインは **`ya pkg`** で導入します。詳細は `yazi/README.md` を参照してください。

詳細は [Yazi 公式ドキュメント](https://github.com/sxyazi/yazi) と [プラグイン公式ドキュメント](https://yazi-rs.github.io/docs/plugins) を参照してください。

## プラグイン一覧

### zsh (sheldon)

- `zsh-users/zsh-autosuggestions` - コマンド履歴の自動補完
- `zsh-users/zsh-syntax-highlighting` - シンタックスハイライト
- `agkozak/zsh-z` - ディレクトリジャンプ
- `junegunn/fzf` - ファジーファインダー
- `romkatv/powerlevel10k` - テーマ

### nvim (lazy.nvim)

- `ntk148v/vim-horizon` - カラースキーム
- `preservim/nerdtree` - ファイルツリー
- `junegunn/fzf` - ファジーファインダー
- `nvim-treesitter/nvim-treesitter` - シンタックスハイライト
- `williamboman/mason.nvim` - LSP インストーラー
- `neovim/nvim-lspconfig` - LSP 設定
- `saghen/blink.cmp` - 補完（blink.cmp）
- `nvim-lualine/lualine.nvim` - ステータスライン
- `lewis6991/gitsigns.nvim` - Git gutter
- `mikavilpas/yazi.nvim` - Yazi ファイルマネージャー統合

## ライセンス

MIT
