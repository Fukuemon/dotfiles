# キーバインド
#
# ウィジェットの実装は ~/.config/zsh/functions/ に 1 関数 1 ファイルで置いてあり、
# 05-autoload.zsh が autoload 宣言している。ここでは ZLE への登録と割り当てだけ。
#
# 前提: fzf / atuin の init より後に source されること。
#       （fzf は ^R を fzf-history-widget に、atuin は ^R を atuin-search に割り当てる。
#         後から init した方が勝つので、順序が変わると Ctrl-R の挙動が変わる）
#
# Ctrl-R は atuin が握るのでここでは触らない。

# --- cdr（最近使ったディレクトリ）を有効化。fzf-cdr が使う ---
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 100
zstyle ':chpwd:*' recent-dirs-default yes

# --- ウィジェット登録 ---
zle -N fzf-src   # functions/fzf-src : ghq のリポジトリへ移動
zle -N fzf-cdr   # functions/fzf-cdr : 最近使ったディレクトリへ移動

bindkey '^]' fzf-src
bindkey '^u' fzf-cdr
