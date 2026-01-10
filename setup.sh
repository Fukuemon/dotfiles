#!/bin/bash

# dotfiles セットアップスクリプト

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "=========================================="
echo "dotfiles セットアップを開始します"
echo "=========================================="
echo ""

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# エラーハンドリング関数
error() {
  echo -e "${RED}エラー: $1${NC}" >&2
  exit 1
}

success() {
  echo -e "${GREEN}✓ $1${NC}"
}

info() {
  echo -e "${YELLOW}ℹ $1${NC}"
}

MISE_BIN="${HOME}/.local/bin/mise"

ensure_mise() {
  if command -v mise &>/dev/null; then
    success "mise は既にインストールされています"
    return 0
  fi

  if [ -x "$MISE_BIN" ]; then
    success "mise は既にインストールされています（$MISE_BIN）"
    return 0
  fi

  if ! command -v curl &>/dev/null; then
    error "mise のインストールに curl が必要です。curl をインストールしてから再実行してください"
  fi

  info "mise が見つかりません。公式手順でインストールします（curl https://mise.run | sh）"
  curl https://mise.run | sh

  if [ ! -x "$MISE_BIN" ]; then
    error "mise のインストールに失敗しました。${MISE_BIN} が見つかりません"
  fi

  success "mise をインストールしました: $MISE_BIN"
}

mise_cmd() {
  if command -v mise &>/dev/null; then
    mise "$@"
  else
    "$MISE_BIN" "$@"
  fi
}

install_tool_if_missing() {
  local cmd="$1"
  local spec="$2"
  local label="$3"

  if command -v "$cmd" &>/dev/null; then
    success "$label は既にインストールされています"
    return 0
  fi

  info "$label がインストールされていません。mise でインストールします: $spec"
  mise_cmd use --global "$spec" || error "$label の mise インストールに失敗しました: $spec"
  success "$label をインストールしました"
}

# シンボリックリンクを作成する関数
create_symlink() {
  local source="$1"
  local target="$2"
  local target_dir=$(dirname "$target")

  # ターゲットディレクトリが存在しない場合は作成
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
    info "ディレクトリを作成しました: $target_dir"
  fi

  # 既存のファイル/リンクをバックアップ
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ]; then
      # 既存のシンボリックリンクを削除
      rm "$target"
      info "既存のシンボリックリンクを削除しました: $target"
    else
      # 既存のファイルをバックアップ
      mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
      info "既存のファイルをバックアップしました: $target"
    fi
  fi

  # シンボリックリンクを作成
  ln -sf "$source" "$target"
  success "シンボリックリンクを作成しました: $target -> $source"
}

# zsh設定のセットアップ
setup_zsh() {
  echo ""
  echo "--- zsh設定のセットアップ ---"

  ensure_mise

  create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/zsh/sheldon.toml" "$HOME/.config/sheldon/plugins.toml"

  # sheldonでプラグインをインストール
  if command -v sheldon &>/dev/null; then
    info "sheldonでプラグインをインストールしています..."
    sheldon lock --update || info "sheldon lock --update でエラーが発生しましたが、続行します"
  else
    info "sheldon が見つかりません。devbox での導入を推奨します: docs/devbox-setup.md"
  fi
  success "zsh設定のセットアップが完了しました"
}

# mise 設定（ツール一覧）のセットアップ
setup_mise() {
  echo ""
  echo "--- mise設定のセットアップ ---"

  ensure_mise

  if [ -f "$DOTFILES_DIR/mise/config.toml" ]; then
    create_symlink "$DOTFILES_DIR/mise/config.toml" "$HOME/.config/mise/config.toml"
    success "mise の config.toml を dotfiles 管理にしました"
  else
    info "dotfiles 側に mise/config.toml が見つかりません（スキップ）"
    return 0
  fi

  # mise の trust（セキュリティ機構）
  # dotfiles 配下の config.toml を参照するため、初回は trust が必要になることがあります。
  if [ "${MISE_TRUST:-0}" = "1" ]; then
    info "mise trust を実行します（dotfiles の mise/config.toml を信頼します）"
    mise_cmd trust "$DOTFILES_DIR/mise/config.toml" || info "mise trust でエラーが発生しました。必要なら手動で: mise trust $DOTFILES_DIR/mise/config.toml"
  else
    info "mise の trust はスキップします（必要なら: mise trust $DOTFILES_DIR/mise/config.toml  または MISE_TRUST=1 ./setup.sh）"
  fi

  if [ "${MISE_INSTALL:-0}" = "1" ]; then
    info "mise install を実行します（時間がかかる場合があります）"
    mise_cmd install || info "mise install でエラーが発生しましたが、続行します"
  else
    info "ツール導入は手動で実行してください: mise install（または MISE_INSTALL=1 ./setup.sh）"
  fi

  success "mise設定のセットアップが完了しました"
}

# devbox global の同期（オプション）
setup_devbox_global() {
  echo ""
  echo "--- devbox global のセットアップ（オプション） ---"

  if ! command -v devbox &>/dev/null; then
    info "devbox が見つかりません。必要なら docs/devbox-setup.md を参照してください"
    return 0
  fi

  if [ "${DEVBOX_GLOBAL_SYNC:-0}" = "1" ]; then
    if [ -f "$DOTFILES_DIR/scripts/devbox-global-sync.sh" ]; then
      info "devbox global を dotfiles の宣言に同期します"
      bash "$DOTFILES_DIR/scripts/devbox-global-sync.sh" || info "devbox global sync でエラーが発生しましたが、続行します"
      success "devbox global の同期が完了しました"
    else
      info "scripts/devbox-global-sync.sh が見つかりません（スキップ）"
    fi
  else
    info "devbox global の同期はスキップします（必要なら DEVBOX_GLOBAL_SYNC=1 ./setup.sh）"
    info "または手動で: bash ./scripts/devbox-global-sync.sh"
  fi
}

# nvim設定のセットアップ
setup_nvim() {
  echo ""
  echo "--- nvim設定のセットアップ ---"

  ensure_mise

  create_symlink "$DOTFILES_DIR/nvim/init.lua" "$HOME/.config/nvim/init.lua"

  # luaディレクトリのシンボリックリンク
  if [ -d "$DOTFILES_DIR/nvim/lua" ]; then
    create_symlink "$DOTFILES_DIR/nvim/lua" "$HOME/.config/nvim/lua"
  fi

  info "nvimを起動するとlazy.nvimが自動的にインストールされます"
  success "nvim設定のセットアップが完了しました"
}

# yazi設定のセットアップ
setup_yazi() {
  echo ""
  echo "--- yazi設定のセットアップ ---"

  ensure_mise

  # 設定ディレクトリが存在しない場合は作成
  if [ ! -d "$HOME/.config/yazi" ]; then
    mkdir -p "$HOME/.config/yazi"
    success "yazi設定ディレクトリを作成しました"
  fi

  # 以前の構成の掃除:
  # - plugins を dotfiles に symlink していると ya pkg の deploy が失敗するため削除
  if [ -L "$HOME/.config/yazi/plugins" ]; then
    rm "$HOME/.config/yazi/plugins"
  fi
  mkdir -p "$HOME/.config/yazi/plugins"

  # 既存のファイルをバックアップしてからシンボリックリンクを作成
  create_symlink "$DOTFILES_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
  create_symlink "$DOTFILES_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
  create_symlink "$DOTFILES_DIR/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
  create_symlink "$DOTFILES_DIR/yazi/init.lua" "$HOME/.config/yazi/init.lua"

  success "yazi設定のセットアップが完了しました"
}

# ghostty設定のセットアップ
setup_ghostty() {
  echo ""
  echo "--- ghostty設定のセットアップ ---"

  # ghosttyのインストール確認
  if ! command -v ghostty &>/dev/null; then
    info "ghosttyがインストールされていません"
    info "ghostty は OS 統合が強いため、このスクリプトではインストールしません（必要なら手動でインストールしてください）"
  else
    success "ghosttyは既にインストールされています"
  fi

  # 設定ディレクトリが存在しない場合は作成
  if [ ! -d "$HOME/.config/ghostty" ]; then
    mkdir -p "$HOME/.config/ghostty"
    success "ghostty設定ディレクトリを作成しました"
  fi

  # 設定ファイルのシンボリックリンクを作成
  create_symlink "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

  # backgroundディレクトリのシンボリックリンクを作成
  if [ -d "$DOTFILES_DIR/ghostty/background" ]; then
    create_symlink "$DOTFILES_DIR/ghostty/background" "$HOME/.config/ghostty/background"
  fi

  success "ghostty設定のセットアップが完了しました"
}

# zellijのインストール確認（設定ファイルは作成しない）
check_zellij() {
  echo ""
  echo "--- zellijの確認 ---"

  if command -v zellij &>/dev/null; then
    success "zellijは既にインストールされています"
  else
    info "zellijがインストールされていません（オプション）"
    info "zellij は別途インストールしてください（このリポジトリでは設定のみ管理します）"
  fi
}

# メイン処理
main() {
  # setup_mise
  # setup_zsh
  setup_nvim
  # setup_yazi
  # setup_ghostty
  # check_zellij
  # setup_devbox_global

  echo ""
  echo "=========================================="
  success "セットアップが完了しました！"
  echo "=========================================="
  echo ""
  echo "次のステップ:"
  echo "1. 新しいターミナルを開くか、以下のコマンドで設定を読み込みます:"
  echo "   source ~/.zshrc"
  echo ""
  echo "2. nvimを起動してlazy.nvimのインストールを確認します:"
  echo "   nvim"
  echo ""
}

main
