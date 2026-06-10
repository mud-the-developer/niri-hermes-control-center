#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="${NIRI_CONTROL_BIN_DIR:-$HOME/.local/bin}"
mkdir -p "$bin_dir"

for script in "$repo_dir"/scripts/*; do
  install -m 0755 "$script" "$bin_dir/$(basename "$script")"
done

cat <<EOF
Installed scripts to: $bin_dir

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
