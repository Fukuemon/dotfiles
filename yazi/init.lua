-- Yazi初期化スクリプト
-- Ref: https://minerva.mamansoft.net/2025-09-14-yazi-tui-file-manager-finder-replacement
-- Ref: https://yazi-rs.github.io/docs/plugins

-- プラグインディレクトリのパスを設定
local plugin_dir = os.getenv("HOME") .. "/.config/yazi/plugins"

-- プラグインの読み込み
-- カスタムプラグインを追加する場合は、このディレクトリに配置して読み込みます
-- 例: require("plugins.my-plugin")

-- Neovimとの統合ヘルパー関数
local function open_in_nvim(paths)
	local cmd = "nvim"
	for _, path in ipairs(paths) do
		cmd = cmd .. " " .. vim.fn.shellescape(path)
	end
	os.execute(cmd)
end

-- プラグイン登録の例（必要に応じてコメントアウトを解除）
-- yazi:plugin_register("nvim-helper", {
-- 	open = open_in_nvim,
-- })

