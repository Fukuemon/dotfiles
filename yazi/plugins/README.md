# Yazi プラグイン

このディレクトリには Yazi のプラグイン（Lua スクリプト）を配置します。

## プラグインの追加方法

1. プラグインの Lua ファイルをこのディレクトリに配置します
2. `yazi/init.lua` でプラグインを読み込みます

## プラグインの例

### カスタムコマンドプラグイン

```lua
-- plugins/my-plugin.lua
yazi:plugin_register("my-plugin", {
  -- プラグインの実装
})
```

### プラグインの読み込み

`yazi/init.lua` で以下のように読み込みます：

```lua
-- プラグインを読み込み
require("plugins.my-plugin")
```

## 参考リンク

- [Yazi プラグイン公式ドキュメント](https://yazi-rs.github.io/docs/plugins)
- [Yazi プラグイン例](https://github.com/sxyazi/yazi/tree/main/plugins)

