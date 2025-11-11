#!/bin/bash

# wezterm背景画像切り替えスクリプト
# background/ディレクトリ内の画像ファイルを選択して背景画像を切り替える

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/wezterm"
# 背景画像ディレクトリ: まず~/.config/wezterm/background/を確認、なければスクリプトと同じディレクトリ
if [ -d "$CONFIG_DIR/background" ]; then
    BACKGROUND_DIR="$CONFIG_DIR/background"
else
    BACKGROUND_DIR="$SCRIPT_DIR"
fi
BACKGROUND_LUA="$CONFIG_DIR/background.lua"
# background.luaはsetup.shでコピーされたファイルなので、直接更新
TARGET_FILE="$BACKGROUND_LUA"

# 画像ファイルの拡張子
IMAGE_EXTENSIONS=("png" "jpg" "jpeg" "gif" "webp")

# background/ディレクトリ内の画像ファイルを取得
get_image_files() {
    local files=()
    for ext in "${IMAGE_EXTENSIONS[@]}"; do
        while IFS= read -r -d '' file; do
            files+=("$file")
        done < <(find "$BACKGROUND_DIR" -maxdepth 1 -type f -iname "*.${ext}" -print0 2>/dev/null)
    done
    printf '%s\n' "${files[@]}"
}

# 画像ファイル一覧を取得
IMAGE_FILES=($(get_image_files))

if [ ${#IMAGE_FILES[@]} -eq 0 ]; then
    echo "エラー: 背景画像ファイルが見つかりませんでした。"
    echo "確認したディレクトリ: $BACKGROUND_DIR"
    echo "対応形式: ${IMAGE_EXTENSIONS[*]}"
    echo ""
    echo "ヒント: $CONFIG_DIR/background/ に画像ファイルを配置してください。"
    exit 1
fi

# 画像ファイルを番号付きで表示
echo "利用可能な背景画像:"
echo "-------------------"
for i in "${!IMAGE_FILES[@]}"; do
    filename=$(basename "${IMAGE_FILES[$i]}")
    echo "$((i + 1)). $filename"
done
echo "-------------------"

# ユーザー入力を受け取る
read -p "選択する画像の番号を入力してください (1-${#IMAGE_FILES[@]}): " selection

# 入力検証
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#IMAGE_FILES[@]} ]; then
    echo "エラー: 無効な番号が入力されました。"
    exit 1
fi

# 選択された画像ファイル
SELECTED_FILE="${IMAGE_FILES[$((selection - 1))]}"
SELECTED_FILENAME=$(basename "$SELECTED_FILE")

# 実際のwezterm設定ディレクトリに画像をコピー（存在しない場合は作成）
if [ ! -d "$CONFIG_DIR/background" ]; then
    mkdir -p "$CONFIG_DIR/background"
fi

# 画像をコピー
cp "$SELECTED_FILE" "$CONFIG_DIR/background/$SELECTED_FILENAME"

# background.luaファイルのパスを更新
# ユーザー名を動的に取得
USERNAME=$(whoami)
BACKGROUND_IMAGE_PATH="$CONFIG_DIR/background/$SELECTED_FILENAME"

# background.luaを更新
if [ -f "$TARGET_FILE" ]; then
    # 一時ファイルを作成
    TEMP_FILE=$(mktemp)
    
    # background_imageの行を置き換え（エスケープ処理）
    ESCAPED_PATH=$(echo "$BACKGROUND_IMAGE_PATH" | sed 's/[\/&]/\\&/g')
    sed "s|local background_image = \".*\"|local background_image = \"$ESCAPED_PATH\"|" "$TARGET_FILE" > "$TEMP_FILE"
    
    # ファイルを置き換え
    mv "$TEMP_FILE" "$TARGET_FILE"
    echo "✓ 設定ファイルを更新しました: $BACKGROUND_LUA"
    
    echo "✓ 背景画像を '$SELECTED_FILENAME' に変更しました。"
    echo "✓ 画像パス: $BACKGROUND_IMAGE_PATH"
    echo "✓ 設定ファイル: $BACKGROUND_LUA"
    echo ""
    echo "weztermの設定を再読み込みしてください:"
    echo "  - Cmd+Shift+R を押す"
    echo "  - または wezterm を再起動"
    echo ""
    echo "設定ファイルの内容を確認:"
    grep "local background_image" "$BACKGROUND_LUA" || echo "  (確認できませんでした)"
else
    echo "エラー: background.lua が見つかりませんでした: $BACKGROUND_LUA"
    exit 1
fi

