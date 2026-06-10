#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_dir/scripts/niri-hermes-menu"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  [[ "$actual" == "$expected" ]] || fail "$label: expected [$expected], got [$actual]"
}

reduce() {
  NIRI_CONTROL_TEST=1 "$script" --reduce-choice "$1"
}

printf '1..8\n'

out="$(NIRI_CONTROL_TEST=1 "$script" --prompt)"
assert_eq 'AI Native · Hermes / Codex / Niri context' "$out" 'Hermes prompt'
printf 'ok 1 - prompt is pure\n'

out="$(reduce '󰚩  AI · Open interactive Hermes TUI  · PTY native terminal')"
assert_eq $'effect\tinteractive_hermes' "$out" 'interactive reducer'
printf 'ok 2 - interactive Hermes maps to effect\n'

out="$(reduce '󰭹  AI · Ask Hermes one-shot  · Wofi native input')"
assert_eq $'state\task_hermes_prompt' "$out" 'ask state'
printf 'ok 3 - ask Hermes enters prompt state\n'

out="$(reduce '󰈈  Niri+AI · Explain focused window state')"
assert_eq $'effect\tfocused_window_hermes' "$out" 'focused window reducer'
printf 'ok 4 - focused window maps to effect\n'

out="$(reduce '󰣐  AI · Run Codex exec  · notify on finish')"
assert_eq $'state\tcodex_prompt' "$out" 'codex state'
printf 'ok 5 - Codex enters task prompt state\n'

out="$(reduce '󰑐  Hermes · Status')"
assert_eq $'effect\thermes_cli\tHermes Status\tstatus\t--all' "$out" 'status reducer'
printf 'ok 6 - status maps to Hermes CLI effect\n'

out="$(reduce '󰒲  Hermes · Doctor')"
assert_eq $'effect\thermes_cli\tHermes Doctor\tdoctor' "$out" 'doctor reducer'
printf 'ok 7 - doctor maps to Hermes CLI effect\n'

out="$(reduce '󰘳  Hermes · Skills')"
assert_eq $'effect\thermes_cli\tHermes Skills\tskills\tlist' "$out" 'skills reducer'
printf 'ok 8 - skills maps to Hermes CLI effect\n'
