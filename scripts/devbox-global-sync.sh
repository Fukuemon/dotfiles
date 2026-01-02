#!/bin/bash
#
# devbox global のパッケージを dotfiles の宣言（devbox/global-packages.txt）に同期します。
#
# 使い方:
#   bash ./scripts/devbox-global-sync.sh
#   DRY_RUN=1 bash ./scripts/devbox-global-sync.sh
#   STRICT=1 bash ./scripts/devbox-global-sync.sh
#   STRICT=1 APPLY_REMOVE=1 bash ./scripts/devbox-global-sync.sh
#   NO_BACKUP=1 bash ./scripts/devbox-global-sync.sh
#
# NOTE:
# - devbox の内部状態ファイルを直接管理せず、「宣言ファイル→devbox global add」で寄せる方針です。

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="${DOTFILES_DIR}/devbox/global-packages.txt"
BACKUP_DIR="${DOTFILES_DIR}/devbox/backups"

now_ts() {
  date "+%Y%m%d_%H%M%S"
}

require_or_dryrun_devbox() {
  if command -v devbox >/dev/null 2>&1; then
    return 0
  fi
  if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "[DRY_RUN] devbox が見つかりませんが、コマンド生成だけ行います"
    return 0
  fi
  echo "devbox が見つかりません。先に devbox をインストールしてください。" >&2
  exit 1
}

backup_devbox_global_list() {
  [ "${NO_BACKUP:-0}" = "1" ] && return 0
  command -v devbox >/dev/null 2>&1 || return 0

  mkdir -p "${BACKUP_DIR}"
  local outfile="${BACKUP_DIR}/devbox-global-$(now_ts).txt"
  devbox global list > "${outfile}"
  echo "バックアップを保存しました: ${outfile}"
}

read_manifest_packages() {
  # stdout に 1 行 1 パッケージで出力（bash 3.2 互換のため mapfile は使わない）
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    [[ "${line}" =~ ^[[:space:]]*# ]] && continue
    printf "%s\n" "${line}"
  done < "${MANIFEST}"
}

installed_global_packages() {
  command -v devbox >/dev/null 2>&1 || return 0
  # 例: "* neovim@latest - 0.11.5" -> "neovim"
  devbox global list | sed -n 's/^\* \([^@[:space:]]\+\)@.*$/\1/p'
}

try_remove_global_packages() {
  local -a pkgs=("$@")
  [ "${#pkgs[@]}" -eq 0 ] && return 0

  # devbox のサブコマンド名の差異に備えて2パターン試す
  if devbox global remove "${pkgs[@]}" >/dev/null 2>&1; then
    devbox global remove "${pkgs[@]}"
    return 0
  fi
  if devbox global rm "${pkgs[@]}" >/dev/null 2>&1; then
    devbox global rm "${pkgs[@]}"
    return 0
  fi

  echo "devbox global の削除コマンドが見つからない/失敗しました。" >&2
  echo "試行: 'devbox global remove' と 'devbox global rm'" >&2
  return 1
}

require_or_dryrun_devbox

if [ ! -f "${MANIFEST}" ]; then
  echo "manifest が見つかりません: ${MANIFEST}" >&2
  exit 1
fi

packages=()
while IFS= read -r pkg; do
  packages+=("${pkg}")
done < <(read_manifest_packages)

if [ "${#packages[@]}" -eq 0 ]; then
  echo "追加するパッケージがありません（${MANIFEST} が空です）" >&2
  exit 0
fi

if [ "${DRY_RUN:-0}" = "1" ]; then
  echo "[DRY_RUN] バックアップ先: ${BACKUP_DIR}/devbox-global-$(now_ts).txt"
  echo "[DRY_RUN] devbox global add ${packages[*]}"
  if [ "${STRICT:-0}" = "1" ]; then
    echo "[DRY_RUN] STRICT=1: 宣言外パッケージ検出/（任意で）削除を行います"
    echo "[DRY_RUN] STRICT=1 APPLY_REMOVE=1: 宣言外パッケージの削除を試みます"
  fi
  exit 0
fi

backup_devbox_global_list

echo "devbox global に追加します（既に入っている場合はそのまま）:"
printf -- "- %s\n" "${packages[@]}"
devbox global add "${packages[@]}"

if [ "${STRICT:-0}" = "1" ]; then
  echo ""
  echo "STRICT モード: 宣言（${MANIFEST}）にない global パッケージを検出します"

  tmp_installed="$(mktemp -t devbox_installed.XXXXXX)"
  tmp_declared="$(mktemp -t devbox_declared.XXXXXX)"
  tmp_extra="$(mktemp -t devbox_extra.XXXXXX)"
  cleanup() {
    rm -f "${tmp_installed}" "${tmp_declared}" "${tmp_extra}"
  }
  trap cleanup EXIT

  installed_global_packages | sort -u > "${tmp_installed}"
  printf "%s\n" "${packages[@]}" | sort -u > "${tmp_declared}"
  comm -23 "${tmp_installed}" "${tmp_declared}" > "${tmp_extra}"

  extra=()
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    extra+=("${line}")
  done < "${tmp_extra}"

  if [ "${#extra[@]}" -eq 0 ]; then
    echo "宣言外パッケージはありません（OK）"
  else
    echo "宣言外パッケージ（削除対象候補）:"
    printf -- "- %s\n" "${extra[@]}"

    if [ "${APPLY_REMOVE:-0}" = "1" ]; then
      echo ""
      echo "APPLY_REMOVE=1: 宣言外パッケージの削除を試みます（危険）"
      try_remove_global_packages "${extra[@]}"
    else
      echo ""
      echo "削除は行いません（必要なら STRICT=1 APPLY_REMOVE=1 で実行してください）"
    fi
  fi
fi

echo "完了: 次回以降は zsh 起動時に devbox global が有効化されます（.zshrc の shellenv）"


