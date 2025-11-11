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
  - `zsh/.zshrc`: zsh設定ファイル（sheldon使用）
  - `zsh/sheldon.toml`: sheldonプラグイン設定

- **nvim**: NeoVim設定
  - `nvim/init.lua`: エントリーポイント
  - `nvim/lua/config/`: 設定ファイル
    - `lazy.lua`: lazy.nvim設定
    - `lsp.lua`: LSP設定
    - `options.lua`: 基本設定
  - `nvim/lua/plugins/`: プラグイン設定（各プラグインごとにファイル分割）
  - `nvim/after/lsp/`: 言語サーバー上書き設定

- **zellij**: ターミナルマルチプレクサ設定（設定ファイルは含まれていません）

## セットアップ

### 前提条件

以下のツールがインストールされている必要があります：

- [sheldon](https://github.com/rossmacarthur/sheldon) - zshプラグインマネージャー
- [wezterm](https://wezfurlong.org/wezterm/) - ターミナルエミュレータ
- [nvim](https://neovim.io/) - エディタ
- [zellij](https://zellij.dev/) - ターミナルマルチプレクサ（オプション）

### 自動セットアップ

`setup.sh` スクリプトを実行して自動的にセットアップできます：

```bash
./setup.sh
```

このスクリプトは以下を実行します：

1. 必要なディレクトリの作成
2. シンボリックリンクの作成
3. sheldonのインストール確認と初期化
4. lazy.nvimの自動インストール確認

### 手動セットアップ

#### 1. リポジトリのクローン

```bash
git clone https://github.com/Fukuemon/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

#### 2. wezterm設定のセットアップ

```bash
# 設定ディレクトリを作成
mkdir -p ~/.config/wezterm

# シンボリックリンクを作成
ln -sf ~/dotfiles/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
ln -sf ~/dotfiles/wezterm/keybinds.lua ~/.config/wezterm/keybinds.lua
ln -sf ~/dotfiles/wezterm/background.lua ~/.config/wezterm/background.lua

# 背景画像ディレクトリを作成
mkdir -p ~/.config/wezterm/background
```

#### 3. zsh設定のセットアップ

```bash
# sheldonのインストール（Homebrewの場合）
brew install sheldon

# シンボリックリンクを作成
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/sheldon.toml ~/.config/sheldon/plugins.toml

# sheldonでプラグインをインストール
sheldon lock --update
```

#### 4. nvim設定のセットアップ

```bash
# 設定ディレクトリを作成
mkdir -p ~/.config/nvim

# シンボリックリンクを作成
ln -sf ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -sf ~/dotfiles/nvim/lua ~/.config/nvim/lua

# nvimを起動するとlazy.nvimが自動的にインストールされます
nvim
```

## 使用方法

### wezterm背景画像の切り替え

`wezterm/background/` ディレクトリに画像ファイルを配置し、以下のコマンドで背景画像を切り替えられます：

```bash
~/dotfiles/wezterm/background/change_bg.sh
```

または、シンボリックリンクを作成している場合：

```bash
~/.config/wezterm/background/change_bg.sh
```

### zshプラグインの管理

プラグインの追加・削除は `zsh/sheldon.toml` を編集し、以下のコマンドで更新します：

```bash
sheldon lock --update
```

### nvimプラグインの管理

プラグインの追加・削除は `nvim/init.lua` を編集します。lazy.nvimが自動的にプラグインをインストール・更新します。

プラグインの手動更新：

```bash
nvim
# nvim内で :Lazy update を実行
```

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
- `williamboman/mason.nvim` - LSPインストーラー
- `neovim/nvim-lspconfig` - LSP設定
- `saghen/blink.cmp` - 補完（blink.cmp）
- `nvim-lualine/lualine.nvim` - ステータスライン
- `lewis6991/gitsigns.nvim` - git gutter

## ライセンス

MIT

