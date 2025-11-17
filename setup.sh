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
    
    # sheldonのインストール確認
    if ! command -v sheldon &> /dev/null; then
        info "sheldonがインストールされていません"
        if command -v brew &> /dev/null; then
            read -p "Homebrewでsheldonをインストールしますか? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                brew install sheldon
                success "sheldonをインストールしました"
            else
                error "sheldonのインストールが必要です。手動でインストールしてください: https://github.com/rossmacarthur/sheldon"
            fi
        else
            error "sheldonのインストールが必要です。手動でインストールしてください: https://github.com/rossmacarthur/sheldon"
        fi
    else
        success "sheldonは既にインストールされています"
    fi
    
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/zsh/sheldon.toml" "$HOME/.config/sheldon/plugins.toml"
    
    # sheldonでプラグインをインストール
    if command -v sheldon &> /dev/null; then
        info "sheldonでプラグインをインストールしています..."
        sheldon lock --update || info "sheldon lock --update でエラーが発生しましたが、続行します"
        success "zsh設定のセットアップが完了しました"
    fi
}

# nvim設定のセットアップ
setup_nvim() {
    echo ""
    echo "--- nvim設定のセットアップ ---"
    
    # nvimのインストール確認
    if ! command -v nvim &> /dev/null; then
        info "nvimがインストールされていません"
        if command -v brew &> /dev/null; then
            read -p "Homebrewでnvimをインストールしますか? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                brew install neovim
                success "nvimをインストールしました"
            else
                info "nvimのインストールをスキップしました"
            fi
        else
            info "nvimがインストールされていません。手動でインストールしてください"
        fi
    else
        success "nvimは既にインストールされています"
    fi
    
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
    
    # yaziのインストール確認
    if ! command -v yazi &> /dev/null; then
        info "yaziがインストールされていません"
        if command -v brew &> /dev/null; then
            read -p "Homebrewでyaziをインストールしますか? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                brew install yazi
                success "yaziをインストールしました"
            else
                info "yaziのインストールをスキップしました"
            fi
        else
            info "yaziがインストールされていません。手動でインストールしてください"
        fi
    else
        success "yaziは既にインストールされています"
    fi
    
    # 設定ディレクトリが存在しない場合は作成
    if [ ! -d "$HOME/.config/yazi" ]; then
        mkdir -p "$HOME/.config/yazi"
        success "yazi設定ディレクトリを作成しました"
    fi
    
    # 既存のファイルをバックアップしてからシンボリックリンクを作成
    create_symlink "$DOTFILES_DIR/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
    create_symlink "$DOTFILES_DIR/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
    create_symlink "$DOTFILES_DIR/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
    create_symlink "$DOTFILES_DIR/yazi/init.lua" "$HOME/.config/yazi/init.lua"
    
    # プラグインディレクトリのシンボリックリンクを作成
    if [ -d "$DOTFILES_DIR/yazi/plugins" ]; then
        create_symlink "$DOTFILES_DIR/yazi/plugins" "$HOME/.config/yazi/plugins"
    fi
    
    success "yazi設定のセットアップが完了しました"
}

# ghostty設定のセットアップ
setup_ghostty() {
    echo ""
    echo "--- ghostty設定のセットアップ ---"
    
    # ghosttyのインストール確認
    if ! command -v ghostty &> /dev/null; then
        info "ghosttyがインストールされていません"
        if command -v brew &> /dev/null; then
            read -p "Homebrewでghosttyをインストールしますか? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                brew install --cask ghostty
                success "ghosttyをインストールしました"
            else
                info "ghosttyのインストールをスキップしました"
            fi
        else
            info "ghosttyがインストールされていません。手動でインストールしてください"
        fi
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
    
    if command -v zellij &> /dev/null; then
        success "zellijは既にインストールされています"
    else
        info "zellijがインストールされていません（オプション）"
        if command -v brew &> /dev/null; then
            read -p "Homebrewでzellijをインストールしますか? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                brew install zellij
                success "zellijをインストールしました"
            fi
        fi
    fi
}

# メイン処理
main() {
    setup_zsh
    setup_nvim
    setup_yazi
    setup_ghostty
    check_zellij
    
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

