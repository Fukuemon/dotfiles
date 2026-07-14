# dotfiles

macOS の開発環境設定。**chezmoi** で `~` へ配置し、ツールは **mise**（aqua バックエンド）と **devbox global**（Nix）で管理します。

## セットアップ

```bash
ghq get Fukuemon/dotfiles
cd "$(ghq root)/github.com/Fukuemon/dotfiles"
./setup.sh          # DRY_RUN=1 ./setup.sh で内容だけ確認できます
```

`setup.sh` は mise → CLI 群 → devbox global → `chezmoi apply` → sheldon / atuin の順にブートストラップします。

## 構成

```
.chezmoiroot              → "home"（chezmoi のソースルートを home/ に固定）
home/                     ← chezmoi が管理する。~ に配置されるものだけを置く
  .chezmoi.toml.tmpl      chezmoi 自身の設定（sourceDir, mode=symlink）を生成
  .chezmoiignore          リポジトリには置くが ~ には配らないもの
  dot_zshrc               → ~/.zshrc
  dot_p10k.zsh            → ~/.p10k.zsh
  dot_gitconfig           → ~/.gitconfig
  dot_aerospace.toml      → ~/.aerospace.toml
  dot_config/
    zsh/                  → ~/.config/zsh/  （.zshrc から切り出した設定群）
    sheldon/plugins.toml  → ~/.config/sheldon/plugins.toml
    mise/config.toml      → ~/.config/mise/config.toml
    atuin/config.toml     → ~/.config/atuin/config.toml
    nvim/                 → ~/.config/nvim/
    yazi/                 → ~/.config/yazi/
    ghostty/              → ~/.config/ghostty/
    zellij/               → ~/.config/zellij/
devbox/global-packages.txt  devbox global の宣言（唯一の真実）
scripts/                    devbox 同期スクリプト
docs/                       ADR・移行メモ
```

`home/` の外（`docs/`, `scripts/`, `setup.sh`, `README.md`）は `.chezmoiroot` によって chezmoi の管理対象から外れます。

### なぜ `devbox/` は `home/` の外にあるのか

`home/` は「**`~` に配置されるファイル**」だけを置く場所だからです。

`devbox/global-packages.txt` は `~` に置かれるファイルではなく、`scripts/devbox-global-sync.sh` が読む
**宣言ファイル**です（`devbox global add` の入力）。`mise` の `config.toml` が `home/` にあるのは、
それが実際に `~/.config/mise/config.toml` として存在し mise 自身が読むファイルだからで、扱いが違います。

devbox の実際の状態は `~/.local/share/devbox/global/default/devbox.json` にありますが、これは
`devbox global add` のたびに devbox が書き換える生成物で、同じ場所の `devbox.lock` は Nix のハッシュを
含むためマシン固有です。chezmoi で管理するとツールと取り合いになるので、あえて管理下に置いていません。

### chezmoi の運用

**`mode = "symlink"` を使っています。** `~/.zshrc` は実体のコピーではなく、リポジトリの
`home/dot_zshrc` への symlink です。つまり:

- リポジトリのファイルを直接編集すれば**そのまま反映されます**（`chezmoi apply` は不要）
- `chezmoi apply` が必要なのは **管理するファイルが増減したとき**だけです

```bash
chezmoi diff        # ~ とリポジトリの差分
chezmoi apply       # リポジトリの内容を ~ に反映
chezmoi add ~/.foo  # 新しい設定ファイルを管理下に入れる
chezmoi managed     # 管理対象の一覧
```

## パッケージ管理の方針

ランタイムと CLI は **mise（aqua バックエンド優先）**、mise で扱いづらいものだけ **devbox global（Nix）** に寄せ、`brew` は GUI / OS 統合が強いものに限定します。

| | 管理するもの | 反映方法 |
|---|---|---|
| **mise** | ランタイム、ほとんどの CLI（chezmoi, atuin, fzf, fd, bat, delta, gh, ripgrep, zellij, git-wt …） | `mise install` |
| **devbox global** | mise/aqua に無いもの（sheldon, eza, yazi, neovim, zoxide …） | `bash ./scripts/devbox-global-sync.sh` |
| **brew** | GUI アプリ（cask）と OS 統合が強いもの | `brew install` |

- 方針(ADR): `docs/adr/000001-package-manager-unification-mise-vs-devbox.md`
- devbox: `docs/devbox-setup.md` / brew の棚卸し: `docs/brew-audit.md`

> **eza が devbox 側にあるのはなぜ？**
> eza は macOS 向けバイナリを GitHub Releases に公開しておらず、aqua 経由で導入できないためです。

**「野良インストール」を作らないこと。** `go install` や `cargo install` で入れたものは
どこにも宣言が残らず、新しいマシンで再現できません。実際 `git-wt`（`.zshrc` が `eval` している）
と `zellij` がこの状態で、`git-wt` が無いと `git wt` が壊れます。CLI を足すときは必ず
`home/dot_config/mise/config.toml` か `devbox/global-packages.txt` に宣言してください。

## zsh

### ファイル構成

`home/dot_zshrc` には**順序が意味を持つものだけ**を置いています。順序に依存しない設定は
`home/dot_config/zsh/` に切り出してあり、`.zshrc` が番号順にまとめて読み込みます。

| ファイル | 内容 |
|---|---|
| `05-autoload.zsh` | `functions/` 配下を autoload 宣言する |
| `10-options.zsh` | 履歴 / `setopt` |
| `20-completion.zsh` | fzf-tab の `zstyle` |
| `30-keybindings.zsh` | ZLE への登録とキー割り当て |
| `40-aliases.zsh` | エイリアス |

（`scripts/` ではなくここに置くのは、`scripts/` が `home/` の外＝`~` に配置されないためです。
`.zshrc` から安定したパスで読めるように、`~/.config/zsh/` に配る必要があります）

### 関数は 1 関数 1 ファイル（autoload）

自作関数は `home/dot_config/zsh/functions/` に **ファイル名＝関数名** で 1 つずつ置きます。

```
functions/ghq-new           GitHub にリポジトリを作って ghq で取得し cd する
functions/fzf-src           Ctrl-] : ghq のリポジトリへ移動（ZLE ウィジェット）
functions/fzf-cdr           Ctrl-U : 最近使ったディレクトリへ移動（ZLE ウィジェット）
functions/zsh-cache-clear   初期化キャッシュを捨てて zsh を入れ直す
```

このディレクトリは `fpath` に入っていて、`05-autoload.zsh` が中身を `autoload -Uz` します。
**関数を追加したいときはファイルを 1 つ置くだけ**で、`.zshrc` も `05-autoload.zsh` も編集不要です。

autoload なので**実際に呼ばれるまで読み込まれません**。関数をいくつ増やしてもシェルの起動時間は
変わりません。ZLE ウィジェットにするものだけ、`30-keybindings.zsh` で `zle -N` と `bindkey` を書きます。

### 読み込み順（重要）

`home/dot_zshrc` は以下の順序に依存しています。**並べ替えると壊れます。**

1. p10k instant prompt
2. PATH / 環境変数
3. **devbox / mise の有効化** ← ここで `sheldon` が PATH に載る
4. **compinit** ← `fzf-tab` の前に補完システムを初期化しておく必要がある
5. **sheldon source**（プラグイン本体）
6. **各ツールの init** ← fzf は `fzf-tab`(5) より後、atuin は fzf より後（どちらも `Ctrl-R` / `Tab` を奪い合う）
7. **`~/.config/zsh/*.zsh`** ← キーバインドが fzf / atuin に依存するため 6 の後

過去に 5 が 3 より前にあったため、**新規ログインシェルでは `sheldon` が PATH に無く、プラグインが丸ごと無効になっていました**（ネストしたシェルでは親から PATH を継承するので動いてしまい、「たまに効かない」症状になっていた）。

### zellij は自動起動しない

`.zshrc` から zellij を自動起動することはやめました。使いたいときに `zj` で起動します。

**zellij のペインは長命な zsh プロセスで、起動時に一度だけ `.zshrc` を読み、あとは読み直しません。**
セッションはターミナルを閉じても生き続けるため、自動起動していると「開きっぱなしの zellij の中だけ
古い `.zshrc` のまま」という状態が恒常的に起きます。自動起動をやめると、シェルの状態が常に
「今の `.zshrc` そのもの」になります。

zellij の中で `.zshrc` の変更を反映したいときは、そのペインで `exec zsh` してください。

| コマンド | 動作 |
|---|---|
| `zj` | zellij を起動（毎回新しいセッション） |
| `zja` | `main` セッションに再接続（無ければ作成）。作業状態を残したいとき |

**自動起動を復活させるなら、判定に `SHLVL` を使ってはいけません。** zellij のサーバはデーモンとして
動くため、ペイン内のシェルは `SHLVL` を継承せず **`SHLVL=1` で起動します**。かつて条件を
`SHLVL -eq 1` にしていたので、zellij のペインの中でさらに zellij を起動しようとして `.zshrc` の
最終行で詰まり、プロンプトが idle にならず zsh-defer に積んだハイライトやサジェストが
ロードされませんでした。ペイン内には `ZELLIJ=0` が設定されるので、こちらを見ます。

```zsh
if [[ -z $ZELLIJ ]] && [[ -o login ]] && (( $+commands[zellij] )); then
  zellij attach --create main
fi
```

詳細は `docs/adr/000002-zsh-startup-and-chezmoi.md`。

### プラグイン（sheldon）

定義順がそのまま source 順です。`home/dot_config/sheldon/plugins.toml` の冒頭のコメントに制約を書いてあります。

| プラグイン | 役割 |
|---|---|
| `romkatv/zsh-defer` | 遅延ロード基盤（最初に読む） |
| `romkatv/powerlevel10k` | プロンプトテーマ |
| `Aloxaf/fzf-tab` | Tab 補完を fzf のインタラクティブ選択に置換 |
| `zsh-users/zsh-autosuggestions` | 履歴からの自動サジェスト（遅延） |
| `zsh-users/zsh-syntax-highlighting` | シンタックスハイライト（**必ず最後**・遅延） |

```bash
sheldon lock --update   # プラグインの取得・更新
zsh-cache-clear         # 初期化キャッシュを捨てて zsh を再起動
```

### キーバインド

| キー | 動作 |
|---|---|
| `Ctrl-R` | **atuin** — SQLite ベースの全文履歴検索（Enter は行に載せるだけで実行しない） |
| `Tab` | **fzf-tab** — 補完候補を fzf で選択（`**` + `Tab` は fzf 本来のパス補完） |
| `Ctrl-]` | ghq のリポジトリへ移動 |
| `Ctrl-U` | 最近使ったディレクトリ（cdr）へ移動 |
| `Ctrl-T` / `Alt-C` | fzf のファイル / ディレクトリ選択 |
| `z <部分名>` | **zoxide** — よく使うディレクトリへジャンプ（`zi` で対話選択） |
| `git wt <branch>` | **git-wt** — worktree を切り替えて cd（`git` をラップするシェル関数） |

### 起動時間

初期化コマンドの出力（`mise activate` / `sheldon source` など）を `~/.cache/zsh/` にキャッシュし、
`compinit` のダンプ判定を修正し、`devbox global shellenv`（214ms）の呼び出しを廃止した結果:

```
旧: 640ms  →  新: 120ms   （プラグインは増えている）
```

キャッシュはスタンプファイルの mtime で自動的に無効化されます。手動で捨てるには `zsh-cache-clear`。

> **キャッシュしてよいのは「引数だけで出力が決まる純粋なコマンド」だけです。**
> 実行時の環境を読んで出力に埋め込むコマンドをキャッシュすると、生成時にたまたま存在した
> 環境変数が以後すべてのシェルに焼き付きます。
>
> `devbox global shellenv` がまさにそれで、nix の PATH を足すだけでなく **現在の環境を
> 丸ごと export し直す**（`ZDOTDIR` / `TERM` / cwd 含む 28 変数）コマンドでした。これを
> キャッシュした結果、古い `ZDOTDIR` が全シェルに焼き付き、**zellij のペインなど子シェルが
> 存在しない `$ZDOTDIR/.zshrc` を探して `.zshrc` を一切読まなくなる**事故が起きました。
> 現在は devbox を呼ばず、nix プロファイルの `bin` と数個の変数を `.zshrc` で直接設定しています。

## nvim

LazyVim ベース。`~/.config/nvim` は `home/dot_config/nvim/` への symlink なので、リポジトリを直接編集できます。

```bash
nvim        # 起動時に lazy.nvim がプラグインを導入
# :Lazy update で更新
```

## yazi

TUI ファイルマネージャー。プラグインは `ya pkg` で管理し、`~/.config/yazi/plugins/` は
**chezmoi の管理対象外**にしてあります（`ya pkg` の deploy と衝突するため）。
導入済みプラグインは `home/dot_config/yazi/package.toml` で追跡しています。

詳細は `home/dot_config/yazi/README.md`。

## その他

- **ghostty** — ターミナルエミュレータ（背景画像つき）
- **zellij** — ターミナルマルチプレクサ。ログインシェルの最初の 1 枚だけ自動起動
- **aerospace** — タイル型ウィンドウマネージャ

## ライセンス

MIT
