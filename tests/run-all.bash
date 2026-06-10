#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

bash -n scripts/* install.sh tests/*.bash
tests/control-center-reducer.bash
tests/hermes-menu-reducer.bash
tests/niri-action-names.bash
