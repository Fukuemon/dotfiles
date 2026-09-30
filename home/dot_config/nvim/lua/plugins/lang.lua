-- 言語ごとの LSP / formatter / linter
--
-- LazyVim の extras は本来 `:LazyExtras` で有効化するが、その状態は lazyvim.json に
-- 書かれる（= dotfiles で管理していない）ため、ここで import として宣言しておく。
-- こうしておくと新しいマシンでも `nvim` を起動するだけで同じ構成が再現される。
--
-- 有効化した言語は ~/.config/mise/config.toml の「言語ランタイム」「クラウド / IaC」
-- あたりの宣言に合わせている。

return {
  -- === LazyVim 標準の言語 extras ===
  { import = "lazyvim.plugins.extras.lang.go" }, -- gopls / gofumpt / goimports / golangci-lint / delve
  { import = "lazyvim.plugins.extras.lang.typescript" }, -- vtsls
  { import = "lazyvim.plugins.extras.lang.python" }, -- basedpyright + ruff
  { import = "lazyvim.plugins.extras.lang.terraform" }, -- terraformls / tflint
  { import = "lazyvim.plugins.extras.lang.docker" }, -- dockerfile-ls / hadolint
  { import = "lazyvim.plugins.extras.lang.helm" }, -- helm_ls
  { import = "lazyvim.plugins.extras.lang.yaml" }, -- yamlls + SchemaStore（k8s マニフェストの補完）
  { import = "lazyvim.plugins.extras.lang.json" }, -- jsonls + SchemaStore
  { import = "lazyvim.plugins.extras.lang.toml" }, -- taplo
  { import = "lazyvim.plugins.extras.lang.sql" }, -- vim-dadbod（DB 接続は vim.g.dbs で設定）
  { import = "lazyvim.plugins.extras.lang.markdown" }, -- marksman / markdownlint-cli2
  { import = "lazyvim.plugins.extras.lang.git" }, -- gitcommit / rebase の treesitter とハイライト

  -- === フォーマッタ / リンタ ===
  { import = "lazyvim.plugins.extras.formatting.prettier" }, -- ts/js/json/yaml/md を prettier で統一
  { import = "lazyvim.plugins.extras.linting.eslint" }, -- eslint（LSP 経由、保存時に fix）

  -- === extras が無い言語を手で足す ===

  -- treesitter パーサ（extras 側で入らない分）
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "bash", "proto", "hcl", "make", "sql" } },
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- shell スクリプト（scripts/ 配下で使う）
        bashls = {
          filetypes = { "sh", "bash", "zsh" },
          settings = {
            bashIde = {
              -- zsh を含むリポジトリ全体の走査は重いので shellcheck 連携だけ使う
              globPattern = "*@(.sh|.inc|.bash|.command)",
            },
          },
        },
        -- Protocol Buffers（protoc を mise で管理しているため）
        buf_ls = {},
      },
    },
  },

  -- mason で入れる CLI（LSP 本体は LazyVim が自動で入れる）
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "shfmt", "shellcheck", "buf" } },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        proto = { "buf" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },
}
