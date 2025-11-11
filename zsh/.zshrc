# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# sheldon プラグインマネージャーの初期化
eval "$(sheldon source)"

# zsh補完システムの初期化
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

##### === PATH の基本方針 ===
# - Homebrew と ~/.local/bin（uv/mise）を優先
# - PATH の重複は自動除去
typeset -U path PATH

##### 基本ツール（先に環境変数）
export VOLTA_HOME="$HOME/.volta"
export BUN_INSTALL="$HOME/.bun"

##### PATH（優先順で並べる）
path=(
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $HOME/.local/bin             
  $HOME/.cargo/bin              
  $BUN_INSTALL/bin             
  $HOME/.console-ninja/.bin
  /opt/homebrew/opt/postgresql@15/bin
  $HOME/go/bin
  $HOME/google-cloud-sdk/bin
  $path                        
)

eval "$(/Users/$USER/.local/bin/mise activate zsh)" 2>/dev/null
##### Google Cloud SDK
# SDK の PATH/補完（存在する時だけ読み込み）
[[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && . "$HOME/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

export CLOUDSDK_PYTHON="$(command -v python3)"

##### uv（インストール後の補完が欲しい人向け：任意）
if command -v uv &> /dev/null; then
  eval "$(uv generate-shell-completion zsh)" 2>/dev/null
fi

if [ -f "$HOME/.pyenv/versions/miniforge3-23.3.1-1/etc/profile.d/conda.sh" ]; then
  . "$HOME/.pyenv/versions/miniforge3-23.3.1-1/etc/profile.d/conda.sh" 2>/dev/null
  conda config --set auto_activate_base false >/dev/null 2>&1
fi

##### ---- peco / ghq ユーティリティ ----
# 履歴検索（Ctrl-r）
function peco-history-selection() {
  BUFFER=$(history -n 1 | tac | awk '!a[$0]++' | peco)
  CURSOR=$#BUFFER
  zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

# ghq リポジトリ移動（Ctrl-]）
function peco-src () {
  local selected_dir
  selected_dir=$(ghq list -p | peco --prompt="repositories >" --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

# cdr 経由のディレクトリ移動（Ctrl-u）
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 20
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':completion:*:*:cdr:*:*' menu selection

function peco-get-destination-from-cdr() {
  cdr -l | sed -e 's/^[[:digit:]]*[[:blank:]]*//' | peco --query "$LBUFFER"
}
function peco-cdr() {
  local destination
  destination="$(peco-get-destination-from-cdr)"
  if [ -n "$destination" ]; then
    BUFFER="cd $destination"
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N peco-cdr
bindkey '^u' peco-cdr

# ghq-new: GitHub で public repo 作成→ ghq 取得
function ghq-new() {
  local REPONAME=$1
  local GITHUB_HOST="github.com"
  if [ -z "$REPONAME" ]; then
    echo 'Repository name must be specified.'; return 1
  fi
  if [ -z "$GITHUB_PRIVATE_TOKEN" ]; then
    echo "GITHUB_PRIVATE_TOKEN is not set. export して再実行してください。"; return 1
  fi
  local USER_INFO GITHUB_USERNAME REPO_RESPONSE REPO_URL
  USER_INFO=$(curl -s --header "Authorization: token $GITHUB_PRIVATE_TOKEN" "https://api.github.com/user")
  GITHUB_USERNAME=$(echo "$USER_INFO" | jq -r '.login')
  if [ "$GITHUB_USERNAME" = "null" ] || [ -z "$GITHUB_USERNAME" ]; then
    echo "Failed to get GitHub username. token を確認してください。"; return 1
  fi
  echo "Creating repository '$REPONAME' for user '$GITHUB_USERNAME'..."
  REPO_RESPONSE=$(curl -s --header "Authorization: token $GITHUB_PRIVATE_TOKEN" \
                      --header "Content-Type: application/json" \
                      --data "{\"name\":\"$REPONAME\",\"private\":false}" \
                      "https://api.github.com/user/repos")
  REPO_URL=$(echo "$REPO_RESPONSE" | jq -r '.clone_url // empty')
  if [ -z "$REPO_URL" ]; then
    echo "Failed to create repository. Error:"
    echo "$REPO_RESPONSE" | jq -r '.message // "Unknown error"'
    return 1
  fi
  echo "Repository created successfully: $REPO_URL"
  ghq get "$GITHUB_HOST/$GITHUB_USERNAME/$REPONAME"
  cd "$(ghq root)/$GITHUB_HOST/$GITHUB_USERNAME/$REPONAME" || return
  echo "Repository '$REPONAME' is ready at: $(pwd)"
}

##### 便利エイリアス
alias -g lb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'
alias de='docker exec -it $(docker ps | peco | awk "NR==2{print \$1}") /bin/bash'

##### NeoVim
alias vi="nvim"
alias vim="nvim"
alias view="nvim -R"
alias zshconfig="vim ~/.zshrc"

##### Hyper
alias cpoke="~/scripts/hyper/choose_pokemon.sh"

##### wezterm背景画像切り替え
change-bg() {
  local script_path
  # シンボリックリンク経由でアクセス可能な場合
  if [ -f "$HOME/.config/wezterm/background/change_bg.sh" ]; then
    script_path="$HOME/.config/wezterm/background/change_bg.sh"
  # dotfilesが標準的な場所にある場合
  elif [ -f "$HOME/dotfiles/wezterm/background/change_bg.sh" ]; then
    script_path="$HOME/dotfiles/wezterm/background/change_bg.sh"
  # .zshrcから相対パスで探す場合
  else
    local zshrc_path
    if [ -L "$HOME/.zshrc" ]; then
      zshrc_path=$(readlink -f "$HOME/.zshrc" 2>/dev/null)
    else
      zshrc_path="$HOME/.zshrc"
    fi
    if [ -n "$zshrc_path" ] && [ -f "$(dirname "$zshrc_path")/../wezterm/background/change_bg.sh" ]; then
      script_path="$(dirname "$zshrc_path")/../wezterm/background/change_bg.sh"
    fi
  fi
  
  if [ -n "$script_path" ] && [ -f "$script_path" ]; then
    "$script_path" "$@"
  else
    echo "エラー: change_bg.sh が見つかりませんでした"
    return 1
  fi
}

#### zellij（ログインシェルの最初だけ起動）
if [ "${SHLVL:-0}" -eq 1 ]; then
 command -v zellij >/dev/null && zellij
fi
alias zj="zellij"

##### powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
