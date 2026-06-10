#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="${NIRI_CONTROL_BIN_DIR:-$HOME/.local/bin}"
config_dir="${NIRI_CONTROL_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/niri-control-center}"
mkdir -p "$bin_dir" "$config_dir"

for script in "$repo_dir"/scripts/*; do
  install -m 0755 "$script" "$bin_dir/$(basename "$script")"
done

install -m 0644 "$repo_dir/config/wofi-glass.css" "$config_dir/wofi-glass.css"
install -m 0644 "$repo_dir/config/wofi-glass.conf" "$config_dir/wofi-glass.conf"

cat <<EOF
Installed scripts to: $bin_dir
Installed Control Center theme to: $config_dir

Next steps:
1. Add keybind snippets from:
   $repo_dir/config/keybinds.kdl
   into ~/.config/niri/config.kdl inside binds { ... }

2. Optionally add visual effect snippets from:
   $repo_dir/config/effects.kdl
   into ~/.config/niri/config.kdl at top-level.

3. Validate and reload:
   niri validate -c ~/.config/niri/config.kdl
   niri msg action load-config-file

4. Smoke test:
   $bin_dir/niri-control-center --self-test
EOF
