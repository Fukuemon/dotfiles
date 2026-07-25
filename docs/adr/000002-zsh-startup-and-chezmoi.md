# 000002-zsh の起動順序の修正と chezmoi への移行

## コンテキスト

### 1. sheldon が「たまに」読み込まれない

`.zshrc` の 9 行目で `eval "$(sheldon source)"` を実行していたが、`sheldon` の実体は
devbox global（Nix プロファイル）配下にある。

```
~/.local/share/devbox/global/default/.devbox/nix/profile/default/bin/sheldon
```

ここに PATH を通す `devbox global shellenv` の実行は 41 行あとの 46 行目だった。つまり
**PATH が確定する前に sheldon を呼んでいた**。

- **新規ログインシェル**（ターミナルを新しく開く）… PATH は `/etc/paths` 由来のみ。`sheldon` は
  見つからず、`$(sheldon source)` は空文字列に評価される。`eval ""` はエラーにならないため
  **何も起きないまま**、プラグイン（補完・ハイライト・テーマ）が丸ごと無効になる。
- **ネストしたシェル**（zellij のペイン、シェルからの `zsh`）… 親から PATH を継承するので動く。

この「片方では動く」性質が、原因の特定を遅らせていた。

再現:

```console
$ env -i HOME=$HOME PATH="$(getconf PATH)" zsh -c 'command -v sheldon'
（何も出ない = 見つからない）
```

### 2. 起動が遅い（640ms）

実測すると、毎回同じシェルコードを吐くだけのコマンドに時間を使っていた。

| 処理 | コスト |
|---|---|
| `conda config --set auto_activate_base false` | **603ms** |
| `devbox global shellenv --init-hook` | **214ms** |
| `compinit`（フルスキャン） | 352ms |
| `mise activate zsh` | 48ms |
| `uv generate-shell-completion zsh` | 41ms |
| `sheldon source` | 38ms |

特に `conda config --set` は設定を `~/.condarc` に**永続化する**コマンドで、シェルを起動する
たびに実行する意味がまったく無かった。

また `compinit` のキャッシュ判定が壊れていた:

```zsh
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
```

`ZDOTDIR` は未設定なので、これは `/.zcompdump` を見ている。結果として常に
`compinit -C`（検証スキップ）に落ち、ダンプが更新されなくなっていた。

### 3. zellij のペインの中で zellij を起動しようとしていた

`.zshrc` の末尾に、ターミナルを開いたときだけ zellij を起動する処理があった。

```zsh
if [ "${SHLVL:-0}" -eq 1 ]; then
  command -v zellij >/dev/null && zellij
fi
```

しかし **zellij のペイン内のシェルは `SHLVL=1` で起動する**。zellij のサーバはデーモンとして
動くため、そこから spawn されるペインのシェルは元のシェルの `SHLVL` を継承しない。実測:

```console
（zellij のペイン内）
ZELLIJ=0  SHLVL=1
```

つまりペイン内でもこの条件が真になり、**zellij の中でさらに zellij を起動しようとして
`.zshrc` の最終行で詰まっていた**。

これ自体は以前からあったバグだが、`zsh-defer` を導入したことで症状が顕在化した。zsh-defer は
zle が idle になった（＝プロンプトが出た）タイミングで積んだタスクを実行するが、`.zshrc` の
最後で zellij がブロックするとそこに到達しない。結果として **zellij の中では
シンタックスハイライトと autosuggestions がロードされない**ことになる。

zellij はペイン内のシェルに `ZELLIJ=0` を設定するので、こちらを条件にするのが正しい。

### 4. 設定の管理方法が破綻しかけていた

- `setup.sh` の `main()` は 6 関数中 4 つがコメントアウトされ、実質 nvim と aerospace しか
  セットアップしなくなっていた。
- `~/.p10k.zsh`（1739 行）と `~/.gitconfig` が **dotfiles 管理外**だった。
- `~/.config/zellij/config.kdl` はリポジトリ側と乖離していた（実際に使われている
  `pane_frames false` がリポジトリに反映されていない）。
- `~/.gitconfig` の認証ヘルパーに mise のインストール先絶対パスが埋まっていた:
  `!/Users/.../aqua-cli-cli/2.83.2/gh_2.83.2_macOS_arm64/bin/gh` — gh が更新されると
  このパスは消えるので、いずれ認証が壊れる時限爆弾になっていた。

## 決定

### 読み込み順を固定する

`.zshrc` を以下の順序に再構成し、各段の制約をコメントとして書き込んだ。

1. p10k instant prompt
2. PATH / 環境変数
3. **devbox / mise の有効化** ← ここで sheldon・fzf・atuin が PATH に載る
4. **compinit** ← fzf-tab の前に補完システムを初期化する必要がある
5. **sheldon source**（プラグイン）
6. **各ツールの init** ← fzf は fzf-tab より後でなければならない（後述）
7. キーバインド・エイリアス

さらに、二度と黙って失敗しないよう `sheldon` が見つからない場合は警告を出す。

```zsh
if (( $+commands[sheldon] )); then
  _zcache sheldon "$XDG_CONFIG_HOME/sheldon/plugins.toml" sheldon source
else
  print -u2 "⚠ sheldon が PATH にありません。プラグインは無効です。"
fi
```

**fzf は fzf-tab より後に init する**という制約は非自明なので特記する。fzf のシェル統合は
Tab に `fzf-completion` を割り当てる際、既存の Tab バインドを `fzf_default_completion` として
退避し、`**` トリガーが無いときはそこへフォールバックする。fzf-tab より先に init すると
退避先が素の `expand-or-complete` になり、**fzf-tab が黙って無効化される**。

### zellij の自動起動そのものをやめる

まず判定を `ZELLIJ` 環境変数（ペイン内では `ZELLIJ=0`）に直したが、それでも問題が残った。

**zellij のペインは長命な zsh プロセスで、起動時に一度だけ `.zshrc` を読み、以後読み直さない。**
zellij のセッションはターミナルを閉じても生き残るため、自動起動していると
「開きっぱなしの zellij の中だけ古い `.zshrc` のまま」という状態が恒常的に発生する。
実際、`.zshrc` を修正した直後にも、14:14 に起動したペインが 14:17 更新の `.zshrc` を
読んでいない、という形でこれが表面化した。

これは zellij のバグではなく、ターミナルマルチプレクサの性質そのものである。だが
「シェルの設定を触るたびに、開いている zellij の中だけ挙動が違う」のは事故のもとなので、
**自動起動をやめて `zj` で手動起動する**ことにした。こうすればシェルの状態は常に
「今の `.zshrc` そのもの」になり、挙動が予測しやすい。作業状態を残したいときのために
`zja`（`zellij attach --create main`）を用意してある。

自動起動を復活させる場合は、`SHLVL` ではなく `ZELLIJ` を見ること（理由は上記）。

### .zshrc を「順序が意味を持つもの」だけに絞る

履歴・補完・キーバインド・エイリアス・関数を `~/.config/zsh/*.zsh`（リポジトリ上は
`home/dot_config/zsh/`）に切り出し、`.zshrc` からは番号順に読み込む。`.zshrc` に残すのは
順序制約のある初期化だけにして、「どこを触ると壊れるか」を一目で分かるようにする。

`scripts/` ではなく `home/dot_config/zsh/` に置いたのは、`scripts/` が `home/` の外にあり
`~` に配置されないため。`.zshrc` から安定したパスで読むには `~` 配下にある必要がある。

### 初期化コマンドの出力をキャッシュする（ただし純粋なものだけ）

`_zcache <名前> <スタンプファイル> <コマンド...>` を導入し、出力を `~/.cache/zsh/` に保存する。
スタンプファイルが キャッシュより新しければ再生成する。mise 管理のツールは実体パスに
バージョンが含まれるため、更新されるとパスが変わり mtime が新しくなって自動的に再生成される。

**キャッシュしてよいのは「引数だけで出力が決まる純粋なコマンド」に限る。**
`mise activate` / `sheldon source` / `fzf --zsh` / `atuin init` / `zoxide init` /
`uv generate-shell-completion` はいずれも純粋なのでキャッシュしている。

`compinit` は `${ZDOTDIR}` を使わない正しい判定に直し、ダンプを `zcompile` する。

### `devbox global shellenv` は呼ばない

当初、最も重かった `devbox global shellenv`（214ms）も `_zcache` の対象にした。**これが重大な
事故を起こした。**

このコマンドは「nix プロファイルを PATH に足すシェルコードを吐く」ものではなく、
**実行時の環境を丸ごと export し直す**ものだった。出力には PATH だけでなく
`ZDOTDIR` / `TERM` / cwd（`DEVBOX_WD`）まで、計 28 個の変数のスナップショットが含まれる。

たまたま `ZDOTDIR` を設定した状態でキャッシュを生成してしまった結果、

```zsh
export ZDOTDIR="/Users/fuku079/src/github.com/Fukuemon/dotfiles/zsh";  # ← 移行前の古いパス
```

がキャッシュに焼き付き、**以後すべてのシェルに export された**。zsh は `.zshrc` を
`$ZDOTDIR/.zshrc` から読むため、`ZDOTDIR` を継承した子シェル（zellij のペインなど）は
存在しないパスを見にいき、**`.zshrc` を一切読まなくなった**。

外側のログインシェルだけは動いていた。`.zshrc` のパスが解決されるのは `ZDOTDIR` が
export される前だからで、これが「zellij の中だけ何も読まれない」という分かりにくい症状に
なっていた。

キャッシュを外しても問題は残る。このコマンドは **PATH をリテラルな絶対値で上書きする**ので、
`.zshrc` の `path=()` を編集しても黙って無視されうる。

したがって **`devbox global shellenv` は呼ばないことにした。** 必要なのは

- nix プロファイルの `bin` を PATH に載せること
- nix 製バイナリが TLS 証明書と `share/` を見つけられるようにする数個の変数
  （`NIX_SSL_CERT_FILE` / `NIX_PROFILES` / `XDG_DATA_DIRS`）

だけなので、`.zshrc` に直接書く。`devbox global add/remove` をしてもプロファイルの中身が
入れ替わるだけで、このコードは変更不要（`devbox` コマンド自体が無くても動く）。
devbox global に `init_hook` は設定していないので、失われる機能もない。

結果: **640ms → 120ms**（プラグインはむしろ増えている）。

### 設定管理を chezmoi に移す

`setup.sh` による symlink 手書きをやめ、chezmoi に寄せる。ただし
**`mode = "symlink"`** を使い、`~/.zshrc` を実体のコピーではなくリポジトリへの symlink として
配置する。これまでの「リポジトリを編集すれば即反映」という編集フローを壊さないため。

`.chezmoiroot` に `home` を置き、`home/` 以下だけを chezmoi のソースにする。これで
`docs/` `scripts/` `setup.sh` `README.md` を管理対象から自然に除外できる。

管理外だった `~/.p10k.zsh` `~/.gitconfig` `~/.config/yazi/package.toml` を取り込み、zellij は
実際に使われている側をリポジトリに反映した。`.gitconfig` の gh 絶対パスは
`!gh auth git-credential` に直した。

### ツールの入れ替え

| | 旧 | 新 | 理由 |
|---|---|---|---|
| 履歴検索 (Ctrl-R) | `history \| tac \| awk \| peco` | **atuin** | SQLite に実行ディレクトリ・終了コード込みで記録。パイプ芸が不要になる |
| Tab 補完 | zsh 標準 | **fzf-tab** | 候補を fzf で選択。プレビュー付き |
| ディレクトリジャンプ | `zsh-z` | **zoxide** | zoxide は導入済みなのに init されておらず、zsh-z と重複していた |
| ファインダ | peco + fzf | **fzf** に一本化 | 両方入れておく理由が無い |
| `ls` / `find` / diff | — | **eza** / **fd** / **delta** | fzf のプレビューにも使う |

sheldon の `fzf` プラグイン（`github = "junegunn/fzf"`）は**削除**した。これはリポジトリを
clone するだけで、シェル統合スクリプトは `shell/` 配下にあるため sheldon からは source されず、
何もしていなかった。現在は `eval "$(fzf --zsh)"` を使う。

### conda を捨てる

Python 環境は uv に統一する。miniforge に残っていた旧プロジェクトの env 4 つ
（`API_Gourmet2` / `auto_receipt` / `bottle-book` / `ultralytics-env`）を削除し、
`conda clean --all` でパッケージキャッシュも破棄した（miniforge: 4.3GB → 252MB）。

`.zshrc` からは conda の初期化を完全に取り除いた。以前はここで毎回 `conda.sh` を source し、
さらに `conda config --set auto_activate_base false` を実行していた。後者は単体で 603ms かかる
うえ、設定は `~/.condarc` に永続化されるのでシェル起動のたびに走らせる意味がまったく無かった。

なお pyenv 自体はもともと `.zshrc` で init しておらず、conda 以外では使われていない。

### 関数は 1 関数 1 ファイルの autoload にする

`ghq-new` のような関数を `.zshrc` に直書きすると、ファイルが伸びるうえに個別にメンテしづらい。
`~/.config/zsh/functions/<関数名>`（リポジトリ上は `home/dot_config/zsh/functions/`）に
1 ファイル 1 関数で置き、そのディレクトリを `fpath` に足して `autoload -Uz` する。

- 関数を追加するときは**ファイルを 1 つ置くだけ**。`.zshrc` も loader も編集不要
- autoload なので**呼ばれるまで読み込まれない**。関数を増やしても起動時間は変わらない
- ZLE ウィジェットにするものだけ `30-keybindings.zsh` で `zle -N` / `bindkey` する
  （`zle -N` は autoload 宣言済みであることを前提にするので、loader を先に読む必要がある）

### zellij を mise 管理下に入れる

zellij は `cargo install` で入れた `~/.cargo/bin/zellij`（0.43.1）にあり、mise にも devbox にも
**宣言されていなかった**。新しいマシンで再現できない状態だったので `aqua:zellij-org/zellij` として
mise に移した。

## 考慮した選択肢

### 設定管理

| | メリット | デメリット |
|---|---|---|
| **symlink 方式を維持** | 変更が最小。編集が即反映 | `setup.sh` の手書き symlink が腐りやすい（実際に腐っていた）。複数マシン・秘密情報に弱い |
| **chezmoi (copy モード)** | テンプレート・暗号化・マシン差分が使える | 編集フローが変わる（`chezmoi edit` → `apply`）。編集の即時反映が失われる |
| **chezmoi (symlink モード)** ← 採用 | 上記の管理機能を得つつ、編集の即時反映を維持できる | テンプレート／暗号化を使うファイルだけは copy になるため、混在すると挙動が一様でない |

将来テンプレートや暗号化が必要になったら、そのファイルだけ copy 扱いになる。混在は許容する。

### sheldon の入手元

sheldon を devbox から mise（`aqua:rossmacarthur/sheldon`）へ移す案もあった。しかし
**順序さえ正しければ devbox のままで問題ない**うえ、devbox は `/usr/local/bin/devbox` に
あってログインシェルの PATH に最初から載っているため、起点としては十分に堅い。移動しない。

## 影響

### メリット

- 新規ログインシェルでもプラグインが確実に読み込まれる（症状の根絶）
- 起動が 640ms → 130ms
- 履歴が 1000 件（macOS の `/etc/zshrc` が `SAVEHIST=1000` を設定していた）から 100000 件へ。
  さらに atuin により実行ディレクトリ・終了コードつきで検索できる
- `~/.p10k.zsh` `~/.gitconfig` を含め、設定が漏れなくバージョン管理下に入った
- gh 更新で git 認証が壊れる時限爆弾を除去した

### デメリット

- chezmoi という依存が増える（ただし mise で管理されるので導入は自動）
- `chezmoi add` を忘れると新しい設定が管理外のままになる（`chezmoi managed` で確認できる）

### リスク

- **`.zshrc` の順序を崩すと静かに壊れる。** 特に「fzf を fzf-tab より先に init すると
  fzf-tab が無効化される」は気づきにくい。`.zshrc` と `plugins.toml` の冒頭に制約を明記した。
- **キャッシュの陳腐化。** スタンプファイルの mtime で無効化しているが、想定外の更新経路が
  あれば古いまま残りうる。`zsh-cache-clear` で捨てられるようにした。
- atuin の `enter_accept = false` にしている（選択しても即実行しない）。既定は `true` なので、
  設定ファイルを消すと挙動が変わる。
