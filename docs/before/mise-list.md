              _                                        __

\_**\_ \_** (\_)**\_\_\_** **\_ \_\_** \_**_ / /_** \***\*\_\*\***
/ ** `** \/ / **_/ _ \_\_\_\_**/ \_ \/ ** \_\_\_\_**/ ** \/ / ** `/ **_/ _ \
 / / / / / / (** ) **/\_\_\_**/ **/ / / /\_\_\_**/ /_/ / / /_/ / /**/ **/
/_/ /_/ /_/_/\_**\_/\_**/ \_**/_/ /_/ / .\_**/\_/\__,_/\_**/\_**/
/\_/ by @jdx
2025.10.7 macos-arm64 (2025-10-10)
mise WARN mise version 2025.12.13 available
mise WARN To update, run mise self-update
❯ mise ls
Tool Version Source Requested
node 25.1.0 ~/.config/mise/config.toml latest
pnpm 10.21.0
python 3.12.12
python 3.14.0 ~/.config/mise/config.toml latest
terraform 1.13.3 ~/.config/mise/config.toml latest
terraform-docs 0.20.0 ~/.config/mise/config.toml latest
tflint 0.59.1 ~/.config/mise/config.toml latest
tfsec 1.28.14 ~/.config/mise/config.toml latest
uv 0.9.2 ~/.config/mise/config.toml latest
❯ mise current
node 25.1.0
python 3.14.0
terraform 1.13.3
terraform-docs 0.20.0
tflint 0.59.1
tfsec 1.28.14
uv 0.9.2

❯ exec zsh -l
❯ mise current
node 25.1.0
python 3.14.0
terraform 1.13.3
terraform-docs 0.20.0
tflint 0.59.1
tfsec 1.28.14
uv 0.9.2
❯ which -a node python3 terraform
/Users/fuku079/.local/share/mise/installs/node/25.1.0/bin/node
/opt/homebrew/bin/python3
/Users/fuku079/.local/share/mise/installs/python/3.14.0/bin/python3
/usr/local/bin/python3
/usr/bin/python3
/opt/homebrew/bin/terraform
/Users/fuku079/.local/share/mise/installs/terraform/1.13.3/terraform

❯ mise which nvim
mise ERROR nvim is not a mise bin. Perhaps you need to install it first.
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
❯ mise ls-remote nvim
mise ERROR nvim not found in mise tool registry
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
❯ mise which sheldon
mise ERROR sheldon is not a mise bin. Perhaps you need to install it first.
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
❯ mise which yazi
mise ERROR yazi is not a mise bin. Perhaps you need to install it first.
mise ERROR Run with --verbose or MISE_VERBOSE=1 for more information
❯ mise which python
/Users/fuku079/.local/share/mise/installs/python/3.14.0/bin/python
❯ mise which terraform
/Users/fuku079/.local/share/mise/installs/terraform/1.13.3/terraform
