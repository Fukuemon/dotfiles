# 補完 / fzf-tab の設定
#
# 前提: compinit 済みで、sheldon が fzf-tab を読み込んだ後に source されること。

# fzf-tab は zsh 標準の補完メニューと排他。menu を切らないと動かない。
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # 大文字小文字を区別しない
zstyle ':completion:*:descriptions' format '[%d]'          # fzf-tab のグループ表示に必要

zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
zstyle ':fzf-tab:*' switch-group '<' '>'                   # グループ切り替え

if (( $+commands[eza] )); then
  # cd / z の補完候補にディレクトリの中身をプレビュー
  zstyle ':fzf-tab:complete:(cd|z|__zoxide_z):*' fzf-preview \
    'eza -1 --color=always --icons --group-directories-first $realpath'
fi

if (( $+commands[bat] )); then
  zstyle ':fzf-tab:complete:(nvim|vi|vim|cat|bat|less):*' fzf-preview \
    '[[ -d $realpath ]] && eza -1 --color=always --icons $realpath || bat --color=always --style=numbers --line-range=:200 $realpath'
fi
