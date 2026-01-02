# mise への統一移行手順（brew 併用ルール付き）

このドキュメントは、`brew` と `mise` が混在している状態から、**開発用のランタイム/CLI を原則 `mise` 管理へ寄せる**ための移行手順です。  
方針の背景は ADR も参照してください: `docs/adr/000001-package-manager-unification-mise-vs-devbox.md`

## ゴール

- 言語ランタイム（例: Node/Python/Go/Ruby 等）と開発用 CLI は **原則 `mise`** に寄せる
- `brew` は **macOS 統合が強いもの（GUI アプリ/フォント/ドライバ等）**に限定する
- 「どのコマンドがどこから提供されているか」を明確にし、再現性と保守性を上げる

## 前提（このリポジトリの現状）

- `setup.sh` は **mise 前提**で、`curl https://mise.run | sh` による `mise` 導入と、mise 経由でのツール導入を行います。
- `zsh/.zshrc` には `mise activate zsh` が既に設定されています。
- `zsh/.zshrc` の PATH は現状 **`/opt/homebrew/bin` が先**に来るため、同名コマンドがある場合に **brew 版が優先**されやすいです。

## 移行全体フロー（おすすめ）

1. **棚卸し**（現状の brew/mise のインストール状況を記録）
2. **mise の導入/有効化確認**（zsh 統合含む）
3. **優先順位の確認**（`which -a` / PATH で「どれが使われているか」固定）
4. **ランタイムの移行**（まず言語系から）
5. **CLI の移行**（必要に応じて）
6. **brew の整理**（重複を解消）
7. **セットアップ手順の更新**（README/setup.sh の説明を mise 前提に寄せる）

## 1) 棚卸し（必ず最初に）

### brew 側の棚卸し

```bash
brew --version
brew list --formula
brew list --cask
```

### mise 側の棚卸し

```bash
command -v mise
mise --version
mise ls
mise current
```

> 以降の作業で迷ったら、まず「現状どのコマンドが使われているか」を `which -a` で確認します。

## 2) mise の導入/有効化確認

### mise が未導入の場合

- 本リポジトリでは **公式 Getting Started の手順（curl）**で `mise` をセットアップする方針です。

```bash
curl https://mise.run | sh
```

### zsh 連携の確認

`zsh/.zshrc` に `mise activate zsh` があること、起動時にエラーが出ないことを確認します。

```bash
exec zsh -l
mise --version
```

## 3) 「どのコマンドが使われているか」を固定する（最重要）

同名コマンドが `brew` と `mise` の両方に存在する場合、PATH の順で実行されるものが決まります。

### よく確認する例

```bash
which -a node
which -a python3
which -a nvim
which -a yazi
```

### 目標

- 「mise 管理にしたいコマンド」は **mise 側が優先**される状態にする
- `brew` は GUI/OS 統合系が中心なので、CLI を mise に寄せるほど **PATH の意図が重要**になります

> 現状の `zsh/.zshrc` だと Homebrew が先頭寄りなので、移行後は「期待と違うバイナリが動く」ことが起きやすいです。  
> 必要なら PATH の優先順を見直してください（変更は別 PR/別コミット推奨）。

## 4) ランタイムを mise へ移行する（推奨：ここから着手）

まずは **言語ランタイム**（Node/Python/Go/Ruby 等）を `mise` に寄せると、プロジェクト間の差異が減って効果が出やすいです。

例（バージョンは利用状況に合わせて決めてください）:

```bash
mise use -g node@20
mise use -g python@3.12
mise install
```

確認:

```bash
node -v
python3 --version
mise current
```

## 5) CLI を mise へ移行する（必要なものだけ）

CLI は「mise で管理できるか」「OS 統合が必要か」で扱いを分けます。

- **mise に寄せる候補**: プロジェクト/開発でバージョン差が痛いもの（例: `jq`, `rg`, `fd`, `gh` 等）
- **brew に残す候補**: cask 前提のもの、OS 統合が強いもの（例: `ghostty`）

進め方:

1. 対象コマンドが `mise` で管理可能かを確認（`mise` のレジストリ/プラグイン）
2. 管理できるなら `mise use -g <tool>@<version>` で導入
3. `which -a <tool>` で意図したものが使われているか確認

## 6) brew の整理（重複をなくす）

mise に寄せたのに brew にも残っていると混乱の元です。

1. `which -a <tool>` で重複を確認
2. **mise を優先したい**なら brew 側の同名 formula を削除（慎重に）

```bash
brew uninstall <formula>
```

> 迷ったら「まずはアンインストールせず、優先順位を固定してから」がおすすめです。

## 7) セットアップ手順（README/setup.sh）との整合

現状 `setup.sh` と README は **mise（curl 導入）前提**の記述に合わせています。  
以後、インストール手順を追加する場合は、原則として `mise` を利用してください（OS 統合が強いものは例外として `brew` を検討）。

## dotfiles で「mise のツール一覧」を管理する（推奨）

`mise use -g ...` は `~/.config/mise/config.toml` に記録されますが、これを手元で直接編集すると dotfiles と乖離します。  
この dotfiles では、`mise/config.toml` を **唯一の真実**として管理し、`setup.sh` で `~/.config/mise/config.toml` に symlink します。

手動反映（導入）:

```bash
mise trust ~/src/github.com/Fukuemon/dotfiles/config.toml
mise install
```

セットアップ時に自動で `mise install` まで実行したい場合:

```bash
MISE_TRUST=1 MISE_INSTALL=1 ./setup.sh
```

## チェックリスト（移行完了判定）

- `mise --version` が通る
- `exec zsh -l` 後に `mise current` が期待通り
- `which -a node/python3/...` が意図通り（mise 優先 or brew 優先が明確）
- 重複していた brew formula を整理できている（必要なら）
- README/setup.sh の説明が現実の運用と矛盾していない

## あなたの現状（docs/before）からの優先移行リスト

`docs/before/mise-list.md` と `docs/before/brew-list.md` を前提に、まず効果が大きく・事故りにくい順で並べています。

### 0) 事前：mise を最新化（任意だが推奨）

`mise ls` の出力に更新警告が出ているため、先に更新してから進めるのがおすすめです。

```bash
mise self-update
```

### 1) すでに mise で管理できている（OK）

- `node`
- `pnpm`
- `python`（複数バージョンが入っているので、運用方針に合わせて整理して OK）
- `terraform` / `terraform-docs` / `tflint` / `tfsec`
- `uv`

まずはシェル起動後に「今どれが使われているか」を確認します。

```bash
exec zsh -l
mise current
which -a node python3 terraform
```

### 2) brew と重複しているので、mise に寄せてから brew を整理したいもの（優先）

`brew list --formula` に以下が含まれていました（このうち、mise で管理できないものは devbox に寄せます）:

- `python@3.12` / `python@3.13`
- `pyenv`
- `tfenv`

#### 2-1) （python/terraform 系）mise 側にあることを確認

```bash
exec zsh -l
mise which python || true
mise which terraform || true
```

#### 2-2) brew 側を削除（※削除前に “which が mise を指している” ことを確認）

```bash
brew uninstall tfenv pyenv python@3.12 python@3.13
```

> 注意: `pyenv`/`python@3.x` を消すと、既存のシェル設定やスクリプトがそれを前提にしている場合に影響が出ます。  
> 消す前に `which -a python3` と `python3 --version` が「mise の python」を指していることを確認してください。

### 2') （おすすめ）CLI は mise で “aqua バックエンド優先” に寄せる

`mise ls-remote <tool>` が失敗しても、**aqua バックエンドを明示**すればインストールできることがあります（mise は複数バックエンドを持つため）。

基本フロー（記事の内容を dotfiles 用に整理）:

1. `mise registry` で `<tool>` がどのバックエンドで提供されているか確認
2. aqua があれば **`aqua:<owner>/<repo>` を明示**して `mise use -g` で導入
3. `mise which <tool>` / `mise tool <tool>` で「どのバックエンドが使われているか」を確認

例:

```bash
mise registry | rg '^fzf\s'
mise use -g aqua:junegunn/fzf
mise which fzf
mise tool fzf
```

> 公式/補足:
>
> - mise は `[tools]` に `aqua:<owner>/<repo>` のように **バックエンドを明示**できます（aqua を優先したい時の定石）。
> - `mise use -g` は `~/.config/mise/config.toml` に記録されます（グローバル管理）。

### 2'') それでも難しい CLI は devbox で管理する（nvim/sheldon/yazi など）

aqua/mise でうまく扱えない（あるいは運用ポリシー上 devbox に寄せたい）CLI は **devbox（Nix）** に寄せます。

- 手順: `docs/devbox-setup.md`
  - `devbox global` を使えば、dotfiles 配下にいなくてもホストシェルで使える（例: `nvim` 等）。公式: `https://www.jetify.com/docs/devbox/devbox-global`

## brew の大量インストールをどう整理するか

`brew list --formula` には依存ライブラリが大量に含まれます。  
整理は `brew leaves`（トップレベル）から始めるのが安全です。

- 手順: `docs/brew-audit.md`

### 3) brew に残すのが自然なもの（cask/OS 統合）

`brew list --cask` に以下がありました:

- `aerospace`
- `ghostty`
- `hyper`
- `pgadmin4`
- `wezterm`

これらは OS 統合が強いので、引き続き `brew` 管理で OK です。

## ロールバック（困った時）

- `which -a <tool>` で「どこから来ているか」を確認
- PATH を元に戻す（zsh の設定を戻す）
- 必要なら brew で入れ直す
