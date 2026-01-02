# Homebrew の整理方針（brew list が多すぎる時の進め方）

`brew list --formula` は「自分で入れたツール」だけでなく「それらの依存ライブラリ」も含まれます。  
そのため、まず **トップレベル（葉 / leaves）だけ**に絞ってから、`mise` / `devbox` / `brew` のどれで管理するかを決めるのが安全です。

## ゴール（本リポジトリの方針）

- **mise**: ランタイム/一部 CLI（node/python/terraform/uv など）
- **devbox**: mise で管理できない（またはしたくない）CLI（例: nvim/sheldon/yazi…）
- **brew**: GUI アプリ（cask）や OS 統合が強いもの（フォント/ドライバ/常駐サービス等）

## 1) まず “自分で入れたもの” を抽出する

以下は **依存を除いたトップレベル formula** を見るための定番コマンドです。

```bash
brew leaves
```

ついでに cask も控えておきます。

```bash
brew list --cask
```

> `docs/before/brew-list.md` はスナップショットとして良いので、引き続き残して OK です。

## 2) leaves を 3 分類する（おすすめの判断基準）

### A. brew に残す

- GUI アプリ（cask）
- OS 統合が強いもの（ドライバ/フォント/メニューバー常駐など）
- 常駐サービスとして使うもの（例: PostgreSQL を OS 上で管理したい等）

### B. devbox に移す

- 開発用 CLI（`fzf`, `ripgrep`, `jq`, `tmux`, `gh` など）で「バージョンを固定したい/環境差を消したい」もの
- mise の tool registry に存在しない（あなたの `nvim` のようなケース）もの

### C. 削除（または統合）

- すでに `mise` に同等品がある（例: `tfenv` → `mise` の terraform）
- 使っていない/過去の残骸
- “どれが使われてるか不明” で重複しているもの（先に `which -a` で確認してから）

## 3) 移行の安全な順序（1 個ずつ）

例：`ripgrep` を devbox に移す場合

1. devbox に追加

```bash
devbox add ripgrep
devbox install
```

1. devbox 環境で動作確認

```bash
devbox shell
rg --version
exit
```

1. brew 側を削除

```bash
brew uninstall ripgrep
```

1. `which -a rg` で意図通りになっているか確認

## 4) あなたの brew-list から見える “まず整理候補”

`docs/before/brew-list.md` を見る限り、以下は「重複/統合」の優先候補になりやすいです。

- `python@3.12`, `python@3.13`, `pyenv`（mise の python を使うなら整理候補）
- `tfenv`（mise で terraform を管理しているなら整理候補）
- `neovim`, `sheldon`, `yazi`（devbox へ寄せる候補）

逆に、cask（`wezterm`, `ghostty`, `hyper`, `pgadmin4`, `aerospace`）は brew 継続が自然です。

## 5) あなたの `brew leaves`（docs/before/brew-list.md）を分類すると

`docs/before/brew-list.md` の `brew leaves` は以下でした（依存を除いたトップレベル）:

- awscli
- bat
- cmake
- coreutils
- fzf
- gh
- ghq
- graphviz
- htop
- jq
- neovim
- peco
- perl
- php
- postgresql@15
- protobuf
- psutils
- pv
- pyenv
- qemu
- ripgrep
- sheldon
- tfenv
- the_silver_searcher
- tmux
- tmux-mem-cpu-load
- tree
- universal-ctags
- watch
- wget
- yazi
- zsh-completions

### 推奨の振り分け（まずはこの方針で OK）

- **devbox に寄せる（CLI 中心）**:
  - `neovim`, `sheldon`, `yazi`（mise で管理できないことが実測で判明）
  - `tmux`, `fzf`, `ripgrep`, `jq`, `gh`, `ghq`, `bat`, `htop`, `tree`, `wget`, `peco`, `universal-ctags`, `the_silver_searcher`, `coreutils`, `graphviz`
  - `awscli`（CLI なので devbox に寄せても OK。必要なら brew 継続でも良い）
- **brew に残す（OS 統合/重量級/サービス）**:
  - cask（`wezterm`, `ghostty`, `hyper`, `pgadmin4`, `aerospace`）はそのまま
  - formula だと `postgresql@15`, `qemu` は「使い方次第」で brew 継続が無難（特に postgresql を OS サービスとして扱う場合）
  - `zsh-completions` はシェル統合寄りなので、当面 brew 継続で OK
  - `tmux-mem-cpu-load` は tmux と強く結びつくので、まずは現状維持（必要なら後で devbox 化）
- **削除候補（mise に統合できる/重複の元）**:
  - `tfenv`（mise で terraform を管理しているなら不要になりやすい）
  - `pyenv`（mise の python を使うなら不要になりやすい）
  - `python@3.12` / `python@3.13` は leaves ではないが、重複の元なので整理候補（`which -a python3` で優先を確認してから）
  - `perl`, `php`, `protobuf`, `cmake` は「必要なときだけ」のことが多いので、用途がなければ削除候補（必要なら devbox へ移す）

### まずのおすすめ実行順（事故りにくい）

1. devbox 側に “最低限（nvim/sheldon/yazi）” を入れて動作確認（`docs/devbox-setup.md`）
2. `which -a` で「どのコマンドがどこから来てるか」を確認しながら、1 個ずつ brew を削除
3. 最後に `pyenv/tfenv/python@3.x` などの“環境基盤”を整理（影響が大きいので後回し）
