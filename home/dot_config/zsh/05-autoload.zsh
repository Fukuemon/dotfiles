# ~/.config/zsh/functions/ の各ファイルを autoload する
#
# 【1 関数 1 ファイル】ファイル名がそのまま関数名になる。
#   リポジトリ上の実体: home/dot_config/zsh/functions/<関数名>
#
# autoload なので「実際に呼ばれるまで読み込まれない」。関数をいくつ増やしても
# シェルの起動時間は変わらない。関数を追加したいときは、そのディレクトリに
# ファイルを 1 つ置くだけでよい（ここを編集する必要はない）。
#
# ★ 30-keybindings.zsh より前に読む必要がある。
#   `zle -N fzf-src` は fzf-src が autoload 宣言済みであることを前提にするため。
#
# なお fpath への追加は .zshrc 側（compinit より前）で行っている。

for _fn in "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh/functions/*(N:t); do
  autoload -Uz "$_fn"
done
unset _fn
