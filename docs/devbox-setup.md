# devbox セットアップ手順

| | |
|---|---|
| 目的 | mise/aqua で管理できない CLI を devbox global（Nix）で管理する |
| 状態 | 運用中 |
| 関連 | [ADR 000001](adr/000001-package-manager-unification-mise-vs-devbox.md) / [ADR 000002](adr/000002-zsh-startup-and-chezmoi.md) |

現在 devbox global で管理しているもの: `sheldon` `eza` `yazi` `neovim` `zoxide` `git` ほか
（[devbox/global-packages.txt](../devbox/global-packages.txt) が唯一の真実）。

CLI は mise の aqua バックエンドで入ることが多いので、まずは [mise-migration.md](mise-migration.md) を確認してください。

## 位置づけ（mise と devbox の分担）

- **mise**: 言語ランタイムや、mise で管理できる開発用 CLI（例: node/python/terraform/uv など）
- **devbox**: mise の tool registry にない/扱いづらい CLI を Nix で固定して提供

## 前提

- devbox は Nix ベースのツールです（Nix が必要になります）。
  - 公式ドキュメント: [`https://www.jetpack.io/devbox/docs/`](https://www.jetpack.io/devbox/docs/)

## 1) devbox のインストール（公式の curl 手順）

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

インストール後に確認:

```bash
command -v devbox
devbox version
```

> インストールスクリプト URL: [`https://get.jetify.com/devbox`](https://get.jetify.com/devbox)

## 2) devbox global を使う（推奨：どこでも使える）

devbox には `devbox global` があり、パッケージを **グローバルプロファイル**に追加できます。  
グローバルパッケージをホストシェルから使うには、nix プロファイルの `bin` を PATH に載せる必要があります（方法は後述。`devbox global shellenv` は使いません）。

- 公式ドキュメント: [`https://www.jetify.com/docs/devbox/devbox-global`](https://www.jetify.com/docs/devbox/devbox-global)

### 例: nvim / sheldon / yazi をグローバル化

```bash
devbox global add neovim sheldon yazi
```

> 補足: Neovim プラグインによっては `git` を呼ぶことがあるため、macOS の `/usr/bin/git`（xcrun 経由）を避けたい場合は `git` も global に入れておくと安定します。
> 例: `devbox global add git`

### いまのシェルだけ一時的に有効化

```bash
. <(devbox global shellenv --init-hook)
```

### zsh 起動時の有効化

> [!CAUTION]
> **`.zshrc` に `eval "$(devbox global shellenv --init-hook)"` を書いてはいけません。**
>
> `devbox global shellenv` は「nix プロファイルを PATH に足すシェルコードを吐く」コマンドではなく、
> **実行時の環境を丸ごと export し直す**コマンドです。出力には PATH だけでなく
> `ZDOTDIR` / `TERM` / cwd を含む 28 個の変数のスナップショットが入ります。
>
> - PATH をリテラルな絶対値で上書きするため、`.zshrc` の `path=()` の編集が黙って無視されうる
> - 出力をキャッシュすると、生成時にたまたま存在した環境変数が以後すべてのシェルに焼き付く
>
> 実際にこれで `ZDOTDIR` が古いパスに固定され、**zellij のペインなどの子シェルが存在しない
> `$ZDOTDIR/.zshrc` を探して `.zshrc` を一切読まなくなる**事故が起きました。
> 詳細は [ADR 000002](adr/000002-zsh-startup-and-chezmoi.md)。

`home/dot_zshrc` では devbox コマンドを呼ばず、nix プロファイルの `bin` を PATH に足し、
nix 製バイナリが必要とする数個の変数だけを直接設定しています。

```zsh
_devbox_profile="$XDG_DATA_HOME/devbox/global/default/.devbox/nix/profile/default"
if [[ -d $_devbox_profile/bin ]]; then
  path=("$_devbox_profile/bin" $path)
  export NIX_SSL_CERT_FILE="/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
  export NIX_PROFILES="/nix/var/nix/profiles/default $HOME/.nix-profile"
  export XDG_DATA_DIRS="${XDG_DATA_DIRS}:$_devbox_profile/share"
fi
```

`devbox global add` / `remove` をしてもプロファイルの中身が入れ替わるだけなので、このコードは変更不要です
（devbox コマンド自体が無くても動きます）。実行コスト 214ms も無くなります。

> このリポジトリでは **devbox global 前提**で運用し、リポジトリ直下の `devbox.json` は置かない方針です。

## dotfiles で「devbox global のツール一覧」を管理する（推奨）

devbox global は便利ですが、手元で `devbox global add ...` を積み上げるだけだと「どれを入れているか」が散逸しがちです。  
この dotfiles では、devbox global の一覧を **宣言ファイル**として管理し、必要に応じて同期する運用にします。

- **宣言ファイル**: `devbox/global-packages.txt`
- **同期スクリプト**: `scripts/devbox-global-sync.sh`

同期（追加のみ・冪等）:

```bash
bash ./scripts/devbox-global-sync.sh
```

ドライラン:

```bash
DRY_RUN=1 bash ./scripts/devbox-global-sync.sh
```

バックアップなし（通常は同期前に `devbox global list` を `devbox/backups/` に保存します）:

```bash
NO_BACKUP=1 bash ./scripts/devbox-global-sync.sh
```

strict（宣言にないパッケージを検出するだけ・削除しない）:

```bash
STRICT=1 bash ./scripts/devbox-global-sync.sh
```

strict（宣言にないパッケージを削除まで行う・危険なので opt-in）:

```bash
STRICT=1 APPLY_REMOVE=1 bash ./scripts/devbox-global-sync.sh
```

## 3) （任意）プロジェクト単位で devbox を使う

「このディレクトリにいる時だけツールを有効化したい」場合は、プロジェクト用の `devbox.json` を作って `devbox shell` で入る運用もできます。

```bash
devbox init
devbox add neovim
devbox add sheldon
devbox add yazi
devbox install
devbox shell
```

> 初回は Nix の取得/ビルドで時間がかかります。`devbox shell` が「Ensuring packages are installed」で止まって見えても、しばらく待てば進むことがあります。

## 4) brew からの移行（重複の整理）

devbox で同等ツールが動くことを確認してから、brew 側の重複を削除します。

```bash
brew uninstall neovim sheldon yazi
```

> どのバイナリが使われているかは `which -a <cmd>` で必ず確認してください。

## トラブルシューティング

### `packages in legacy format` と言われる

`devbox update` を実行して、設定とロックを更新します（`flake.lock` も更新されます）。

```bash
devbox update
```

### `nix profile upgrade` で `package not found` が出る

`devbox update` の途中で警告として出ることがあります。  
その後に `Installing the following packages...` が進み、`devbox shell` でツールが使えるなら **ひとまず OK** です。

もし最終的にインストールに失敗する場合は、対象パッケージが存在するかを確認してください:

```bash
devbox search sheldon
devbox search yazi
```

## 参考

- Devbox リポジトリ: [`https://github.com/jetify-com/devbox`](https://github.com/jetify-com/devbox)
