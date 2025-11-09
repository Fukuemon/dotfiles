# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z fzf zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':chpwd:*' recent-dirs-max 20
zstyle ':chpwd:*' recent-dirs-default yes
zstyle ':completion:*:*:cdr:*:*' menu selection

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#

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

eval "$(/Users/$USER/.local/bin/mise activate zsh)"
##### Google Cloud SDK
# SDK の PATH/補完（存在する時だけ読み込み）
[[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]] && . "$HOME/google-cloud-sdk/path.zsh.inc"
[[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

export CLOUDSDK_PYTHON="$(command -v python3)"

##### uv（インストール後の補完が欲しい人向け：任意）
eval "$(uv generate-shell-completion zsh)"

if [ -f "$HOME/.pyenv/versions/miniforge3-23.3.1-1/etc/profile.d/conda.sh" ]; then
  . "$HOME/.pyenv/versions/miniforge3-23.3.1-1/etc/profile.d/conda.sh"
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
alias ohmyzsh="vim ~/.oh-my-zsh"

##### bun 補完
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

##### Hyper
alias cpoke="~/scripts/hyper/choose_pokemon.sh"

#### tmux（ログインシェルの最初だけ起動）
if [ "${SHLVL:-0}" -eq 1 ]; then
 command -v tmux >/dev/null && tmux
fi

##### powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh