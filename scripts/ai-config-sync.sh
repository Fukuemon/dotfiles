#!/bin/bash
#
# AI コーディング CLI（Claude Code / Codex CLI / Cursor）の設定を chezmoi に取り込み直します。
#
# 使い方:
#   bash ./scripts/ai-config-sync.sh
#   DRY_RUN=1 bash ./scripts/ai-config-sync.sh
#
# NOTE:
# - これらの設定は CLI 自身やツール（rtk init / plugin の導入 / /config）が書き換えるため、
#   symlink ではなく「~ の実体を取り込み直す」運用にしています。
#   ~ 側で設定を変えたら本スクリプトを実行し、差分を commit してください。
# - `chezmoi add --template` は絶対パスをそのまま持ち込むので、取り込み後に
#   $HOME を {{ .chezmoi.homeDir }} へ書き戻します（他マシンでも解決できるように）。
# - 秘密情報・セッション状態は管理しません（下記 EXCLUDED を参照）。

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="${DOTFILES_DIR}/home"

# 実体をそのまま取り込むもの（マシン固有のパスを含まない）
PLAIN_FILES=(
  "${HOME}/.claude/CLAUDE.md"
  "${HOME}/.claude/RTK.md"
  "${HOME}/.codex/RTK.md"
  "${HOME}/.cursor/mcp.json"
)

# $HOME を含むためテンプレート化して取り込むもの
TEMPLATE_FILES=(
  "${HOME}/.claude/settings.json"
  "${HOME}/.codex/AGENTS.md"
  "${HOME}/.codex/hooks.json"
  "${HOME}/.cursor/hooks.json"
)

# 取り込み後に $HOME を書き戻す対象（chezmoi のソースパス）
TEMPLATE_SOURCES=(
  "${SOURCE_DIR}/dot_claude/private_settings.json.tmpl"
  "${SOURCE_DIR}/dot_codex/private_AGENTS.md.tmpl"
  "${SOURCE_DIR}/dot_codex/hooks.json.tmpl"
  "${SOURCE_DIR}/dot_cursor/private_hooks.json.tmpl"
)

# 管理しないもの（意図的に除外。増やす前に理由を書くこと）
# - ~/.codex/auth.json, ~/.claude/.credentials.json : 認証情報
# - ~/.codex/config.toml                            : projects.<絶対パス> の信頼リスト＝マシン状態
# - ~/.claude/projects, sessions, history.jsonl 等  : セッション履歴
# - ~/.claude/plugins, ~/.cursor/extensions         : ツールが管理する実体（サイズも大きい）
# - *.bak / *.pre-rtk*                              : ツールが作るバックアップ

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

  for f in "${TEMPLATE_FILES[@]}"; do
    [ -e "$f" ] || {
      echo "skip (無し): $f"
      continue
    }
    if [ "${DRY_RUN:-0}" = "1" ]; then
      echo "[DRY_RUN] chezmoi add --template $f"
    else
      chezmoi add --template "$f"
      echo "added (template): $f"
    fi
  done

  [ "${DRY_RUN:-0}" = "1" ] && {
    echo "[DRY_RUN] $HOME → {{ .chezmoi.homeDir }} の書き戻しは省略"
    exit 0
  }

  for src in "${TEMPLATE_SOURCES[@]}"; do
    [ -f "$src" ] || continue
    HOME_DIR="$HOME" python3 - "$src" <<'PY'
import os
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
home = os.environ["HOME_DIR"]
text = path.read_text(encoding="utf-8")
count = text.count(home)
if count:
    path.write_text(text.replace(home, "{{ .chezmoi.homeDir }}"), encoding="utf-8")
print(f"{count:4d} 置換  {path}")
PY
  done

  echo
  echo "取り込み完了。差分を確認して commit してください:"
  echo "  chezmoi diff   # 空になるのが正常（~ とリポジトリが一致）"
  echo "  git -C ${DOTFILES_DIR} status"
}

main "$@"
