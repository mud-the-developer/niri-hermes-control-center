#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_dir/scripts/niri-control-center"

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

run_reduce() {
  NIRI_CONTROL_TEST=1 NIRI_CONTROL_LANGUAGE=ko "$script" --reduce-choice "$1"
}

run_state() {
  NIRI_CONTROL_TEST=1 NIRI_CONTROL_LANGUAGE=ko "$script" --state "$1" "$2"
}

printf '1..8\n'

out="$(NIRI_CONTROL_TEST=1 NIRI_CONTROL_LANGUAGE=ko "$script" --prompt)"
assert_eq 'Niri Command · 네이티브 액션, 앱, 에이전트' "$out" 'ko prompt'
printf 'ok 1 - localized prompt is pure\n'

out="$(NIRI_CONTROL_TEST=1 NIRI_CONTROL_LANGUAGE=en "$script" --prompt)"
assert_eq 'Niri Command · native actions, apps, agents' "$out" 'en prompt'
printf 'ok 2 - english prompt is pure\n'

out="$(run_reduce '󰀻  App · 앱 실행 / 검색')"
assert_eq $'effect\tlaunch_app' "$out" 'launch app reducer'
printf 'ok 3 - reducer maps app launcher\n'

out="$(run_reduce '󰚩  AI · Hermes Agent')"
assert_eq $'effect\tspawn_script\tniri-hermes-menu' "$out" 'Hermes reducer'
printf 'ok 4 - reducer maps Hermes submenu\n'

out="$(run_reduce '󰈈  Niri · 오버뷰 켜기/끄기')"
assert_eq $'effect\tniri_action\tNiri · 오버뷰 켜기/끄기\ttoggle-overview' "$out" 'overview reducer'
printf 'ok 5 - reducer maps Niri action\n'

out="$(run_reduce 'firefox')"
assert_eq $'effect\tlaunch_app_search\tfirefox' "$out" 'free text reducer'
printf 'ok 6 - reducer maps unknown text to app search\n'

out="$(run_state menu '󰅶  Control · 언어 설정')"
assert_eq $'state\tlanguage_menu' "$out" 'language state transition'
printf 'ok 7 - state machine enters language menu\n'

out="$(run_state language_menu '한국어')"
assert_eq $'effect\twrite_language\tko' "$out" 'language write reducer'
printf 'ok 8 - language menu reduces to write_language effect\n'
