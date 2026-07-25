# 履歴とシェルオプション
#
# macOS の /etc/zshrc が HISTSIZE=2000 / SAVEHIST=1000 を設定してしまうため、
# ここで上書きしないと履歴が 1000 件で捨てられる。

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt EXTENDED_HISTORY       # 実行時刻と所要時間も記録
setopt SHARE_HISTORY          # 複数シェル間で履歴を共有
setopt HIST_IGNORE_ALL_DUPS   # 重複コマンドは古い方を捨てる
setopt HIST_IGNORE_SPACE      # 先頭が空白のコマンドは残さない
setopt HIST_REDUCE_BLANKS     # 余分な空白を詰めて記録
setopt HIST_VERIFY            # 履歴展開は即実行せず一度行を見せる

setopt AUTO_CD                # ディレクトリ名だけで cd
setopt AUTO_PUSHD             # cd 時に自動で pushd
setopt PUSHD_IGNORE_DUPS
setopt INTERACTIVE_COMMENTS   # 対話シェルでも # コメントを許可
