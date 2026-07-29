# エイリアス

if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
fi

alias vi="nvim"
alias vim="nvim"
alias view="nvim -R"

# zellij は .zshrc から自動起動しない（理由は .zshrc の 11 を参照）。使うときだけ手動で。
alias zj="zellij"
alias zja="zellij attach --create main"   # 作業状態を残したいとき用の固定セッション

# chezmoi（dotfiles 管理）
alias cm="chezmoi"
alias cma="chezmoi apply"
alias cmd="chezmoi diff"
alias cme="chezmoi edit"
alias cmcd='cd "$(chezmoi source-path)"'
alias zshconfig='cd "$(chezmoi source-path)" && nvim dot_zshrc'

# git ブランチを fzf で選択して展開するグローバルエイリアス（例: git switch lb）
alias -g lb='$(git branch --format="%(refname:short)" | fzf --prompt="branch> ")'

# git / docker の TUI（どちらも mise 管理）
# 設定は ~/.config/lazygit/config.yml（lazygit は XDG のこのパスを既定で読むので
# LG_CONFIG_FILE を export する必要はない）
alias lg="lazygit"
alias ld="lazydocker"

# docker コンテナを fzf で選んで exec
alias de='docker exec -it $(docker ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}" | fzf --prompt="container> " | cut -f1) /bin/bash'

# tree: ノイズになるディレクトリを既定で除外する（-N は非 ASCII をエスケープしない）
alias tree='tree -a -I ".DS_Store|.git|node_modules|vendor/bundle" -N'

# 削除したエイリアス:
# - cpoke : ~/scripts/hyper/choose_pokemon.sh を呼ぶもので、中身は ~/.hyper.js の
#           `pokemon: [...]` を書き換えるスクリプトだった。Hyper（ターミナル）は
#           ghostty へ移行して cask を削除したため、動かなくなったので外した。
