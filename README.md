# dotfiles

macOS の開発環境設定。

|            |                                                                                                                                 |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 配置       | [chezmoi](https://www.chezmoi.io/)（`mode = "symlink"`）                                                                        |
| パッケージ | [mise](https://mise.jdx.dev/)（aqua バックエンド）/ [devbox global](https://www.jetify.com/devbox)（Nix）/ Homebrew（GUI のみ） |
| シェル     | zsh + [sheldon](https://github.com/rossmacarthur/sheldon) + Powerlevel10k                                                       |
| 端末       | Ghostty / zellij / yazi / Neovim（LazyVim）                                                                                     |

## セットアップ

```bash
ghq get Fukuemon/dotfiles
cd "$(ghq root)/github.com/Fukuemon/dotfiles"
./setup.sh
```

`DRY_RUN=1 ./setup.sh` で実行内容だけ確認できる。

`setup.sh` の処理順:

1. mise を導入する
2. mise で chezmoi と CLI 群を導入する
3. devbox global を `devbox/global-packages.txt` に同期する
4. `chezmoi apply` で `~` に配置する
5. sheldon のプラグイン取得と atuin への履歴取り込みを行う

## リポジトリ構成

```
.chezmoiroot                    "home" — chezmoi のソースルートを home/ に固定する
home/                           chezmoi の管理対象。~ に配置されるものだけを置く
├── .chezmoi.toml.tmpl          chezmoi 自身の設定（sourceDir / mode）を生成する
├── .chezmoiignore              リポジトリには置くが ~ には配らないもの
├── .chezmoiremove              管理をやめたファイルを ~ から削除する宣言
├── dot_zshrc                   → ~/.zshrc
├── dot_zprofile                → ~/.zprofile
├── dot_p10k.zsh                → ~/.p10k.zsh
├── dot_gitconfig               → ~/.gitconfig（末尾で ~/.gitconfig.local を include）
├── dot_gitignore               → ~/.gitignore（core.excludesfile）
├── dot_aerospace.toml          → ~/.aerospace.toml
├── dot_claude/                 → ~/.claude/（CLAUDE.md / RTK.md / settings.json）
├── dot_codex/                  → ~/.codex/（AGENTS.md / RTK.md / hooks.json）
├── dot_cursor/                 → ~/.cursor/（hooks.json / mcp.json）
└── dot_config/                 → ~/.config/
    ├── zsh/                      .zshrc から切り出した設定と自作関数
    ├── sheldon/plugins.toml      zsh プラグイン
    ├── mise/config.toml          ランタイムと CLI の宣言
    ├── atuin/config.toml         履歴検索
    ├── nvim/                     LazyVim
    ├── yazi/                     ファイルマネージャ
    ├── lazygit/config.yml        git の TUI（delta をページャに使う）
    ├── ghostty/                  ターミナル
    └── zellij/                   マルチプレクサ

devbox/global-packages.txt      devbox global の宣言（唯一の真実）
scripts/devbox-global-sync.sh   上記を devbox に反映する
scripts/ai-config-sync.sh       AI CLI の設定を ~ から取り込み直す
docs/                           ADR と運用メモ
setup.sh                        ブートストラップ
```

`home/` の外にあるもの（`docs/` `scripts/` `setup.sh` `README.md`）は `.chezmoiroot` によって chezmoi の管理対象から外れる。

### マシンごとに違う設定

このリポジトリは public なので、公開したくない値（identity・ホスト名・クラウドのリソース名など）はコミットしない。マシン固有の設定は `.gitignore` したローカルファイルに閉じ込め、共有設定の側には「あれば読む」だけを書く。

| ローカルファイル（gitignore）      | 配置先                       | 読まれ方                                        |
| ---------------------------------- | ---------------------------- | ----------------------------------------------- |
| `home/dot_gitconfig.local`         | `~/.gitconfig.local`         | `~/.gitconfig` 末尾の `[include]`（最後 = 上書き可） |
| `home/dot_config/zsh/90-local.zsh` | `~/.config/zsh/90-local.zsh` | `.zshrc` が番号順に source する（90 番 = 最後）  |
| `home/dot_config/yazi/local.lua`   | `~/.config/yazi/local.lua`   | `init.lua` が `dofile` で読み hops に追記する     |

`.gitignore` されたファイルにも chezmoi は symlink を張る（chezmoi は git を見ない）。**管理下に置きながら push はされない**。どれも無くても壊れない（git は無い include を無視し、zsh の glob は `(N-.)`、yazi は `pcall`）。

端末固有のメモは `docs/local/`（gitignore）に置く。

## 日常運用

### 設定を変更する

`mode = "symlink"` のため、`~/.zshrc` は実体のコピーではなくリポジトリへの symlink になっている。

- **リポジトリのファイルを編集すれば即座に反映される。`chezmoi apply` は不要。**
- `chezmoi apply` が必要なのは、管理するファイルが増減したときだけ。

```bash
chezmoi diff          # ~ とリポジトリの差分を見る
chezmoi apply         # リポジトリの内容を ~ に反映する
chezmoi add ~/.foo    # 新しい設定ファイルを管理下に入れる
chezmoi managed       # 管理対象を一覧する
```

エイリアス: `cm` `cmd`（diff）`cma`（apply）`cme`（edit）`cmcd`（ソースへ cd）

### ツールを追加する

| 追加先                             | 対象                                   | 反映                                   |
| ---------------------------------- | -------------------------------------- | -------------------------------------- |
| `home/dot_config/mise/config.toml` | ランタイムと大半の CLI                 | `mise install`                         |
| `devbox/global-packages.txt`       | mise/aqua に無いもの                   | `bash ./scripts/devbox-global-sync.sh` |
| Homebrew                           | GUI アプリ（cask）と OS 統合が強いもの | `brew install`                         |

### AI CLI の設定（Claude Code / Codex CLI / Cursor）

symlink ではなく **`~` の実体を取り込み直す**運用。設定は CLI 自身やツール（`rtk init` / plugin 導入 / `/config`）が書き換えるため、リポジトリを編集しても上書きされる前提で扱う。

```bash
bash ./scripts/ai-config-sync.sh   # ~ の設定を取り込み直す（$HOME はテンプレート化される）
chezmoi diff                       # 空になるのが正常
```

| 管理する                                        | 管理しない（理由）                                                      |
| ----------------------------------------------- | ----------------------------------------------------------------------- |
| `~/.claude/settings.json`（hook / permissions） | `~/.codex/auth.json`・`~/.claude/.credentials.json` — 認証情報          |
| `~/.claude/CLAUDE.md`・`RTK.md`                 | `~/.codex/config.toml` — `projects.<絶対パス>` の信頼リスト＝マシン状態 |
| `~/.codex/AGENTS.md`・`RTK.md`・`hooks.json`    | `projects/` `sessions/` `history.jsonl` — セッション履歴                |
| `~/.cursor/hooks.json`・`mcp.json`              | `plugins/` `extensions/` — ツールが管理する実体（サイズも大きい）       |

新しいマシンでは `mise install` で `rtk` が入り、`chezmoi apply` で上記の設定が配置される。RTK の hook は設定ごと配られるので `rtk init` の再実行は不要（作り直したいときだけ `rtk init -g` / `--codex` / `--agent cursor`）。

> **注意**: `chezmoi apply` は既存ファイルを**バックアップせず上書きする**（別 destination で実測）。`.bak` を作るのは `rtk init` だけで、chezmoi は退避を残さない。すでに Claude Code / Cursor を使っていて独自の設定があるマシンで初めて適用するときは、先に差分を確認する。
>
> ```bash
> chezmoi diff                  # 何が変わるかを見る
> chezmoi apply --dry-run -v    # 実際に書き込む内容を確認する
> chezmoi apply --interactive   # ファイルごとに y/n で判断する
> ```

### プラグイン・履歴

```bash
sheldon lock --update   # zsh プラグインを取得・更新する
nvim                    # 起動時に lazy.nvim がプラグインを導入する（:Lazy update で更新）
ya pkg upgrade          # yazi のプラグインを更新する
zsh-cache-clear         # zsh の初期化キャッシュを捨てて起動し直す
```

## 規約

破ると壊れるもの、または再現性を失うもの。理由は [ADR 000002](docs/adr/000002-zsh-startup-and-chezmoi.md) を参照。

### 野良インストールを作らない

`go install` や `cargo install` で入れたものはどこにも宣言が残らず、新しいマシンで再現できない。CLI を足すときは必ず `mise/config.toml` か `devbox/global-packages.txt` に宣言する。

### `.zshrc` の読み込み順を変えない

```
1. p10k instant prompt        先頭固定。標準出力を出す処理より前
2. PATH / 環境変数
3. PATH の掃除                 mise より前（mise が PATH を保存して cd のたびに組み直すため）
4. devbox / mise の有効化      ここで sheldon が PATH に載る
5. compinit                   fzf-tab より前
6. sheldon source             プラグイン本体
7. 各ツールの init             fzf は fzf-tab(6) より後、atuin は fzf より後
8. ~/.config/zsh/*.zsh        キーバインドが 7 に依存する
```

`sheldon` は devbox global 配下にあるため、4 より前に呼ぶと PATH 上に存在せず、プラグインが丸ごと無効になる（`eval ""` はエラーにならないので気付けない）。

### 環境をスナップショットするコマンドをキャッシュしない

`~/.cache/zsh/` にキャッシュしてよいのは、引数だけで出力が決まる純粋なコマンドだけ。実行時の環境を読んで出力に埋め込むコマンド（`devbox global shellenv` など）をキャッシュすると、生成時の環境変数が以後すべてのシェルに焼き付く。

### zellij の判定に `SHLVL` を使わない

zellij のサーバはデーモンとして動くため、ペイン内のシェルは `SHLVL` を継承せず **`SHLVL=1` で起動する**。ペイン内かどうかは `ZELLIJ`（ペインでは `ZELLIJ=0`）で判定する。

## zsh

### 構成

`dot_zshrc` には順序が意味を持つものだけを置く。順序に依存しない設定は `dot_config/zsh/` に切り出し、`.zshrc` が番号順に読み込む。

| ファイル             | 内容                                  |
| -------------------- | ------------------------------------- |
| `05-autoload.zsh`    | `functions/` 配下を autoload 宣言する |
| `10-options.zsh`     | 履歴と `setopt`                       |
| `20-completion.zsh`  | fzf-tab の `zstyle`                   |
| `30-keybindings.zsh` | ZLE への登録とキー割り当て            |
| `40-aliases.zsh`     | エイリアス                            |
| `90-local.zsh`       | マシン固有（`.gitignore`。無くてもよい） |

`scripts/` ではなくここに置くのは、`scripts/` が `home/` の外にあり `~` へ配置されないため。`.zshrc` から安定したパスで読むには `~/.config/zsh/` に配る必要がある。

### 自作関数

`dot_config/zsh/functions/` に **ファイル名 = 関数名** で 1 つずつ置く。

| 関数              | 内容                                                 |
| ----------------- | ---------------------------------------------------- |
| `ghq-new`         | GitHub にリポジトリを作成し、ghq で取得して cd する  |
| `fzf-src`         | ghq のリポジトリへ移動する（ZLE ウィジェット）       |
| `fzf-cdr`         | 最近使ったディレクトリへ移動する（ZLE ウィジェット） |
| `md-table`        | クリップボードの TSV を Markdown テーブルに変換する   |
| `zsh-cache-clear` | 初期化キャッシュを捨てて zsh を入れ直す              |

このディレクトリは `fpath` に入っており、`05-autoload.zsh` が `autoload -Uz` する。**関数を追加するときはファイルを 1 つ置くだけでよい**（`.zshrc` も loader も編集不要）。autoload なので呼ばれるまで読み込まれず、関数を増やしても起動時間は変わらない。

ZLE ウィジェットにするものだけ、`30-keybindings.zsh` で `zle -N` と `bindkey` を書く。

### プラグイン

`dot_config/sheldon/plugins.toml` の**定義順がそのまま source 順**になる。

| プラグイン                          | 役割                                            |
| ----------------------------------- | ----------------------------------------------- |
| `romkatv/zsh-defer`                 | 遅延ロード基盤（最初に読む）                    |
| `romkatv/powerlevel10k`             | プロンプトテーマ                                |
| `Aloxaf/fzf-tab`                    | Tab 補完を fzf のインタラクティブ選択に置換する |
| `zsh-users/zsh-autosuggestions`     | 履歴からの自動サジェスト（遅延）                |
| `zsh-users/zsh-syntax-highlighting` | シンタックスハイライト（**必ず最後**・遅延）    |

### キーバインド

| キー               | 動作                                                                    |
| ------------------ | ----------------------------------------------------------------------- |
| `Ctrl-R`           | atuin — 全文履歴検索。Enter は行に載せるだけで実行しない                |
| `Tab`              | fzf-tab — 補完候補を fzf で選択する。`**` + `Tab` は fzf 本来のパス補完 |
| `Ctrl-]`           | ghq のリポジトリへ移動する                                              |
| `Ctrl-U`           | 最近使ったディレクトリ（cdr）へ移動する                                 |
| `Ctrl-T` / `Alt-C` | fzf でファイル / ディレクトリを選ぶ                                     |
| `z <部分名>`       | zoxide — よく使うディレクトリへジャンプする（`zi` で対話選択）          |
| `git wt <branch>`  | git-wt — worktree を切り替えて cd する                                  |

### 起動時間

**120ms**（移行前は 640ms）。

`mise activate` や `sheldon source` の出力を `~/.cache/zsh/` にキャッシュしている。キャッシュはスタンプファイルの mtime で自動的に無効化される。手動で捨てるには `zsh-cache-clear`。

## ターミナル / エディタ

### zellij

**自動起動はしない。** 使うときに手動で起動する。

| コマンド | 動作                                                                  |
| -------- | --------------------------------------------------------------------- |
| `zj`     | 起動する（毎回新しいセッション）                                      |
| `zja`    | `main` セッションに再接続する（無ければ作成）。作業状態を残したいとき |

zellij のペインは長命な zsh プロセスで、起動時に一度だけ `.zshrc` を読み、あとは読み直さない。開いているペインに `.zshrc` の変更を反映するには `exec zsh` する。

### yazi

プラグインは `ya pkg` で管理する。`~/.config/yazi/plugins/` は **chezmoi の管理対象外**（`ya pkg` の deploy と衝突するため）。導入済みプラグインは `dot_config/yazi/package.toml` で追跡する。

詳細は [yazi の README](home/dot_config/yazi/README.md)。

### その他

- **ghostty** — ターミナルエミュレータ
- **nvim** — LazyVim ベース
- **aerospace** — タイル型ウィンドウマネージャ

## ドキュメント

|                                                                             |                                               |
| --------------------------------------------------------------------------- | --------------------------------------------- |
| [ADR 000001](docs/adr/000001-package-manager-unification-mise-vs-devbox.md) | パッケージ管理を mise / devbox に統一した理由 |
| [ADR 000002](docs/adr/000002-zsh-startup-and-chezmoi.md)                    | zsh の起動順序の修正と chezmoi への移行       |
| [devbox-setup.md](docs/devbox-setup.md)                                     | devbox global の導入と運用                    |
| [mise-migration.md](docs/mise-migration.md)                                 | brew から mise への移行手順                   |
| [brew-audit.md](docs/brew-audit.md)                                         | Homebrew の棚卸し                             |

## ライセンス

MIT
