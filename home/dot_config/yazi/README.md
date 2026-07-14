# Yazi plugins

このディレクトリは **「Yazi プラグイン用のメモ」**として使います（プラグイン本体は同梱しません）。

Minerva 記事（Finder 置き換え）で紹介されているプラグイン/拡張に寄せた設定を `yazi/keymap.toml` に反映しています。  
参考: [`https://minerva.mamansoft.net/2025-09-14-yazi-tui-file-manager-finder-replacement`](https://minerva.mamansoft.net/2025-09-14-yazi-tui-file-manager-finder-replacement)

## 導入の考え方

- **ビルトイン拡張（導入不要）**: `fzf.lua`, `zoxide.lua`
- **外部プラグイン（導入が必要）**: `smart-enter`, `toggle-pane`, `bunny`, `full-border`, `system-clipboard` など

## `ya pkg` で管理する

`ya` は Yazi 同梱の CLI で、プラグイン管理は `ya pkg` を使います。  
公式: [`https://yazi-rs.github.io/docs/cli`](https://yazi-rs.github.io/docs/cli)

### 以前の dotfiles 構成から移行する場合（重要）

過去に `~/.config/yazi/plugins` を dotfiles へ **シンボリックリンク**していると、`ya pkg` の deploy が `File exists (os error 17)` で失敗します。  
その場合は **リンクを外して実体ディレクトリに戻してください**。

```bash
rm ~/.config/yazi/init.lua 2>/dev/null || true
rm ~/.config/yazi/plugins 2>/dev/null || true
mkdir -p ~/.config/yazi/plugins
```

### 追加 / 一覧 / 更新 / 削除

```bash
# 追加（例: smart-enter）
ya pkg add yazi-rs/plugins:smart-enter

# 一覧
ya pkg list

# まとめて更新
ya pkg upgrade

# 削除（例: smart-enter）
ya pkg delete yazi-rs/plugins:smart-enter
```

> `owner/repo` 形式（例: `ya pkg add owner/my-plugin`）で GitHub の `owner/my-plugin.yazi` から導入することもできます。

## この記事の操作感に寄せるために必要なもの

- **`<Enter>`**: `smart-enter`（ディレクトリなら入る / ファイルなら開く）
- **`<C-p>`**: `toggle-pane.yazi`（プレビュー最大化）
- **`e`**: `bunny.yazi`（ブックマークメニュー）
- **`zf` / `zi`**: `fzf.lua` / `zoxide.lua`（ビルトイン）

### 最小セット（このリポジトリのキーマップに必要）

```bash
ya pkg add yazi-rs/plugins:smart-enter
```

### 追加で入れると記事に近づくもの（任意）

- **toggle-pane**: `<C-p>`（プレビュー最大化）
- **system-clipboard**: `<C-c>`（クリップボードコピー）
- **full-border**: UI を枠線で強化
- **bunny**: `e`（ブックマークメニュー）

> `toggle-pane` / `system-clipboard` / `full-border` / `bunny` はまず `yazi-rs/plugins:<name>` を試し、見つからない場合は **`owner/repo` 形式**で追加します（例: `ya pkg add owner/my-plugin`）。  
> どちらも `ya pkg` での管理です。  
> 参考: Minerva 記事（Finder 置き換え） [`https://minerva.mamansoft.net/2025-09-14-yazi-tui-file-manager-finder-replacement`](https://minerva.mamansoft.net/2025-09-14-yazi-tui-file-manager-finder-replacement)

## まとめて入れる（おすすめ）

まずは以下を順に試すのが早いです（全部 `ya pkg`）:

```bash
ya pkg add yazi-rs/plugins:smart-enter
ya pkg add yazi-rs/plugins:toggle-pane
ya pkg add yazi-rs/plugins:system-clipboard
ya pkg add yazi-rs/plugins:full-border
ya pkg add stelcodes/bunny
```

## ブックマーク（bunny）の設定（dotfiles で共有）

公式/Minerva の流儀に合わせて、**ブックマーク（hops）は `yazi/init.lua` に定義**します。  
`bunny.yazi` は `init.lua` で `require("bunny"):setup({ hops = ... })` を呼ぶ想定です（README 準拠）。

- `yazi/init.lua`: hops（ブックマーク）/ `full-border` / `zoxide(update_db)` / `smart-enter(open_multi)` をまとめて `setup()` します

参照:

- Minerva 記事: [`https://minerva.mamansoft.net/2025-09-14-yazi-tui-file-manager-finder-replacement`](https://minerva.mamansoft.net/2025-09-14-yazi-tui-file-manager-finder-replacement)
- bunny.yazi: [`https://github.com/stelcodes/bunny.yazi`](https://github.com/stelcodes/bunny.yazi)
