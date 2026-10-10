#!/bin/bash
#
# AI コーディング CLI（Claude Code / Codex CLI / Cursor）の設定を chezmoi に取り込み直します。
#
# 使い方:
#   bash ./scripts/ai-config-sync.sh
#   DRY_RUN=1 bash ./scripts/ai-config-sync.sh
#
# NOTE:
# - これらの設定は CLI 自身やツール（plugin の導入 / /config）が書き換えるため、
#   symlink ではなく「~ の実体を取り込み直す」運用にしています。
#   ~ 側で設定を変えたら本スクリプトを実行し、差分を commit してください。
# - ~/.claude/settings.json は取り込みません。home/dot_claude/modify_private_settings.json が
#   宣言したキーだけを書き換えるので、キーを変えるときはそのファイルを直接編集します。
# - 秘密情報・セッション状態は管理しません（下記 EXCLUDED を参照）。

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 実体をそのまま取り込むもの（マシン固有のパスを含まない）
PLAIN_FILES=(
  "${HOME}/.claude/CLAUDE.md"
  "${HOME}/.cursor/mcp.json"
)

# 管理しないもの（意図的に除外。増やす前に理由を書くこと）
# - ~/.codex/auth.json, ~/.claude/.credentials.json : 認証情報
# - ~/.codex/config.toml                            : projects.<絶対パス> の信頼リスト＝マシン状態
# - ~/.claude/projects, sessions, history.jsonl 等  : セッション履歴
# - ~/.claude/plugins, ~/.cursor/extensions         : ツールが管理する実体（サイズも大きい）
# - *.bak / *.pre-rtk*                              : ツールが作るバックアップ
# - ~/.codex/hooks.json, ~/.cursor/hooks.json       : Orca と rtk が自分のフックを書き込む

main() {
  command -v chezmoi >/dev/null 2>&1 || {
    echo "chezmoi が見つかりません。" >&2
    exit 1
  }

  for f in "${PLAIN_FILES[@]}"; do
    [ -e "$f" ] || {
      echo "skip (無し): $f"
      continue
    }
    if [ "${DRY_RUN:-0}" = "1" ]; then
      echo "[DRY_RUN] chezmoi add $f"
    else
      chezmoi add "$f"
      echo "added: $f"
    fi
  done

  echo
  echo "取り込み完了。差分を確認して commit してください:"
  echo "  chezmoi diff   # 空になるのが正常（~ とリポジトリが一致）"
  echo "  git -C ${DOTFILES_DIR} status"
}

main "$@"
