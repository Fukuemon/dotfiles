#!/usr/bin/env bash
#
# dotfiles セットアップ（chezmoi ブートストラップ）
#
# 設定ファイルの配置そのものは chezmoi が行う。このスクリプトは
# 「chezmoi を動かせる状態」まで持っていくのが役割。
#
#   1. mise を用意する
#   2. mise で chezmoi と CLI 群を入れる
#   3. devbox global を宣言ファイルに同期する（sheldon / eza / yazi など）
#   4. chezmoi init + apply（~ に symlink が張られる）
#   5. sheldon のプラグイン取得、atuin への履歴取り込み
#
# 使い方:
#   ./setup.sh              通常のセットアップ
#   DRY_RUN=1 ./setup.sh    何をするかだけ表示する

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
error()   { echo "${RED}エラー: $1${NC}" >&2; exit 1; }
success() { echo "${GREEN}✓ $1${NC}"; }
info()    { echo "${YELLOW}ℹ $1${NC}"; }
step()    { echo; echo "--- $1 ---"; }

DRY_RUN="${DRY_RUN:-0}"
run() {
  if [ "$DRY_RUN" = "1" ]; then
    echo "  [DRY_RUN] $*"
  else
    "$@"
  fi
}

MISE_BIN="$HOME/.local/bin/mise"

# --- 1. mise -----------------------------------------------------------------
ensure_mise() {
  step "mise"

  if command -v mise &>/dev/null; then
    MISE_BIN="$(command -v mise)"
    success "mise は導入済み: $MISE_BIN"
    return
  fi
  if [ -x "$MISE_BIN" ]; then
    success "mise は導入済み: $MISE_BIN"
    return
  fi

  command -v curl &>/dev/null || error "mise の導入に curl が必要です"
  info "mise を導入します（curl https://mise.run | sh）"
  run sh -c 'curl -fsSL https://mise.run | sh'
  [ "$DRY_RUN" = "1" ] || [ -x "$MISE_BIN" ] || error "mise の導入に失敗しました"
  success "mise を導入しました"
}

# --- 2. mise のツール --------------------------------------------------------
install_mise_tools() {
  step "mise のツール（chezmoi / atuin / fzf / fd / bat / delta / ランタイム）"

  # config.toml はまだ ~ に配置されていない可能性があるので、リポジトリのものを直接使う。
  local cfg="$DOTFILES_DIR/home/dot_config/mise/config.toml"
  [ -f "$cfg" ] || error "mise の設定が見つかりません: $cfg"

  run "$MISE_BIN" trust "$cfg"
  info "mise install を実行します（初回は時間がかかります）"
  run env MISE_GLOBAL_CONFIG_FILE="$cfg" "$MISE_BIN" install
  success "mise のツールを導入しました"
}

# --- 3. devbox global --------------------------------------------------------
sync_devbox_global() {
  step "devbox global（sheldon / eza / yazi / nvim など）"

  if ! command -v devbox &>/dev/null; then
    info "devbox が見つかりません。導入方法は docs/devbox-setup.md を参照してください"
    info "（sheldon がここに入っているため、未導入だと zsh のプラグインが動きません）"
    return
  fi

  run bash "$DOTFILES_DIR/scripts/devbox-global-sync.sh"
  success "devbox global を同期しました"
}

# --- 4. chezmoi --------------------------------------------------------------
apply_chezmoi() {
  step "chezmoi（~ への配置）"

  local chezmoi_bin
  if command -v chezmoi &>/dev/null; then
    chezmoi_bin="$(command -v chezmoi)"
  elif [ "$DRY_RUN" = "1" ]; then
    chezmoi_bin="chezmoi"
  else
    chezmoi_bin="$("$MISE_BIN" which chezmoi 2>/dev/null)" \
      || error "chezmoi が見つかりません。mise install が失敗している可能性があります"
  fi

  # このリポジトリ自身をソースディレクトリとして登録する。
  # 実際の設定値は home/.chezmoi.toml.tmpl が生成する（mode = "symlink" など）。
  info "chezmoi のソースを $DOTFILES_DIR に設定します"
  run "$chezmoi_bin" init --source="$DOTFILES_DIR"

  info "適用される差分:"
  [ "$DRY_RUN" = "1" ] || "$chezmoi_bin" status || true

  run "$chezmoi_bin" apply
  success "chezmoi apply が完了しました（~ の設定は symlink としてリポジトリを指します）"
}

# --- 5. シェル周りの後処理 ---------------------------------------------------
setup_shell() {
  step "zsh プラグイン / 履歴"

  if command -v sheldon &>/dev/null; then
    run sheldon lock --update
    success "sheldon のプラグインを取得しました"
  else
    info "sheldon が PATH にありません（devbox global の導入後にもう一度 ./setup.sh してください）"
  fi

  # atuin へ既存の zsh 履歴を取り込む（冪等。二重登録はされない）
  if command -v atuin &>/dev/null && [ -f "$HOME/.zsh_history" ]; then
    run env HISTFILE="$HOME/.zsh_history" atuin import zsh
    success "既存の zsh 履歴を atuin に取り込みました"
  fi

  # 生成済みのキャッシュを捨てて、次回のシェル起動で作り直させる
  run rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
}

main() {
  echo "=========================================="
  echo " dotfiles セットアップ"
  [ "$DRY_RUN" = "1" ] && echo " （DRY_RUN: 実際には何も変更しません）"
  echo "=========================================="

  ensure_mise
  install_mise_tools
  sync_devbox_global
  apply_chezmoi
  setup_shell

  echo
  echo "=========================================="
  success "セットアップ完了"
  echo "=========================================="
  cat <<'EOS'

次のステップ:
  1. 新しいターミナルを開く（または exec zsh）
  2. nvim を起動して lazy.nvim の導入を確認する

日々の運用:
  chezmoi diff     ~ とリポジトリの差分を見る
  chezmoi apply    リポジトリの内容を ~ に反映する
  chezmoi add ~/X  新しい設定ファイルを管理下に入れる

  ※ mode = "symlink" のため、~ の設定はリポジトリへの symlink です。
    リポジトリのファイルを編集すればそのまま反映されます（apply 不要）。
    apply が要るのは「管理するファイルが増減したとき」だけです。
EOS
}

main "$@"
