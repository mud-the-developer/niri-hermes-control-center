#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_dir/scripts/niri-control-center"

if ! command -v niri >/dev/null 2>&1; then
  printf 'skip: niri not installed in this environment\n'
  exit 0
fi

help_text="$(niri msg action --help)"
failures=0
checked=0

while IFS= read -r item; do
  transition="$(NIRI_CONTROL_TEST=1 NIRI_CONTROL_LANGUAGE=ko "$script" --reduce-choice "$item")"
  [[ "$transition" == effect$'\t'niri_action$'\t'* ]] || continue
  action="$(cut -f4 <<< "$transition")"
  checked=$((checked + 1))
  if ! grep -qx "  $action" <<< "$help_text"; then
    printf 'missing niri action: %s (%s)\n' "$action" "$item" >&2
    failures=$((failures + 1))
  fi
done < <(NIRI_CONTROL_TEST=1 NIRI_CONTROL_LANGUAGE=ko "$script" --menu-items)

printf 'checked_niri_actions=%s\n' "$checked"
[[ "$checked" -gt 0 ]] || { printf 'no niri actions checked\n' >&2; exit 1; }
[[ "$failures" -eq 0 ]]
