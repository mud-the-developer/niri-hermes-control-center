# Niri Hermes Control Center

A small, hackable **Niri + Wofi + Hermes Agent** desktop control center for Wayland/Niri users who like fast keyboard workflows, glassy panels, scratch terminals, and AI-agent integration.

Built on a CachyOS + Niri + Rio setup, but the scripts are intentionally plain Bash.

## Features

- `ALT+SPACE` Niri Control Center via Wofi
- Dedicated emerald/cyan glassmorphism Wofi theme installed under `~/.config/niri-control-center/`
- Raycast-inspired but Niri-native command vocabulary: `Niri ·`, `Wayland ·`, `AI ·`, `System ·`, `App ·` actions
- Existing app launching from the Control Center via `App · Launch / search app` (`wofi --show drun`)
- Spotlight-style app search: type an app name directly in `ALT+SPACE`; unknown text opens `wofi --show drun --search <text>`
- Localized Control Center labels with `auto`, `ko`, and `en` language modes
- Hermes Agent submenu:
  - open interactive `hermes --tui chat` in a real terminal/PTY
  - ask Niri-native one-shot prompts with Wofi + `hermes chat -q`
  - send focused Niri window state to Hermes
  - run `codex exec` tasks from Wofi
  - send Niri notifications when Hermes/Codex tasks complete or fail
  - open `hermes status`, `doctor`, `sessions`, `skills`
- Floating scratch terminal (`MOD+SHIFT+ENTER`) with a dedicated app-id
- Focused-window HUD (`MOD+I`)
- Power/session menu with confirmation for destructive actions
- Wallpaper fade transition helper using `awww`
- Niri snippets for blur, overview polish, Waybar/Wofi glass, terminal glass, floating/tiling keybinds

## Requirements

Required:

- `niri`
- `wofi`
- `bash`
- `notify-send` from `libnotify` recommended

Recommended:

- `rio` terminal
- `hermes` CLI for the Hermes submenu
- `awww` for wallpaper transitions
- `waybar` if you use the included layer-rule snippet

## Install

```bash
git clone https://github.com/mud-the-developer/niri-hermes-control-center.git
cd niri-hermes-control-center
./install.sh
```

Then paste snippets into your Niri config:

- `config/keybinds.kdl` goes inside `binds { ... }`
- `config/effects.kdl` goes at top-level in `~/.config/niri/config.kdl`

Validate and reload:

```bash
niri validate -c ~/.config/niri/config.kdl
niri msg action load-config-file
```

## Keybinds

Suggested bindings:

```text
ALT+SPACE          Niri Control Center
MOD+SHIFT+ENTER    Scratch terminal
MOD+I              Focused Window HUD
MOD+ALT+P          Power / Session Menu
MOD+CTRL+W         Wallpaper Transition
MOD+/              Niri hotkey overlay

MOD+GRAVE          Switch focus floating/tiling
MOD+SHIFT+T        Move window to floating
MOD+CTRL+T         Move window to tiling
MOD+ALT+F          Focus floating layer
MOD+ALT+T          Focus tiling layer
```

## Hermes integration

The Hermes submenu is intentionally shell-based and transparent. It calls:

```bash
hermes
hermes chat -q "..."
hermes status
hermes doctor
hermes sessions list
hermes skills list
```

You can override commands:

```bash
# Useful when Niri's startup environment does not include Hermes' venv in PATH.
export NIRI_HERMES_CMD=/home/you/.hermes/hermes-agent/venv/bin/hermes

# Result windows / one-shot output terminal.
export NIRI_HERMES_TERMINAL=rio

# Interactive Hermes terminal. Hermes TUI needs a real terminal/PTY; Alacritty is the default fallback if installed.
export NIRI_HERMES_INTERACTIVE_TERMINAL=alacritty
```

Why this split exists: Niri can spawn menus and commands natively, but a full interactive Hermes TUI still needs a PTY. The "native one-shot" action avoids an interactive terminal by using Wofi for input and `hermes chat -q` for execution.

## Screenshot

Screenshots are not committed by default. Drop your own into `assets/` if you want to show off your rice.

## Safety notes

- The installer only copies scripts to `~/.local/bin` and prints next steps.
- It does not automatically edit your Niri config.
- Power menu asks for confirmation before logout, suspend, reboot, or shutdown.
- No secrets are stored by these scripts.

## Theme, language, and app search

The installer copies a dedicated Control Center Wofi theme to:

```text
~/.config/niri-control-center/wofi-glass.css
~/.config/niri-control-center/wofi-glass.conf
```

The scripts use this theme automatically. To override it without editing the scripts:

```bash
export NIRI_CONTROL_WOFI_STYLE=/path/to/style.css
export NIRI_CONTROL_WOFI_CONF=/path/to/wofi.conf
```

The Control Center follows the system language by default and can also be pinned manually:

```bash
mkdir -p ~/.config/niri-control-center
printf 'language=auto\n' > ~/.config/niri-control-center/config  # follow LANG/LC_MESSAGES
printf 'language=ko\n'   > ~/.config/niri-control-center/config  # 한국어
printf 'language=en\n'   > ~/.config/niri-control-center/config  # English
```

You can also change this from `ALT+SPACE` → `Language` / `언어 설정`.

For app launching, either choose `Launch app` or type an app name directly in `ALT+SPACE`. If the text does not match a Control Center action, the app launcher opens with that text pre-filled:

```bash
wofi --show drun --search firefox
```

## Completion notifications

The included `niri-agent-run` wrapper sends Niri desktop notifications when long-running commands finish:

```bash
niri-agent-run --title "Hermes" hermes chat -q "Summarize this repo"
niri-agent-run --title "Codex" codex exec "Fix the failing tests"
```

Optional sound:

```bash
NIRI_AGENT_NOTIFY_SOUND=1 niri-agent-run --title "Codex" codex exec "Implement feature X"
# or per-run:
niri-agent-run --sound --title "Build" -- make test
```

The Hermes menu uses this wrapper for one-shot Hermes, focused-window analysis, screenshot workflow help, Codex exec, and interactive Hermes exit notifications.

## Development

The Control Center and Hermes submenu are structured as small shell state machines:

- **state machine**: menu states such as `menu`, `language_menu`, `ask_hermes_prompt`, `codex_prompt`
- **pure reducers**: `choice -> state/effect` functions exposed through headless flags such as `--reduce-choice`
- **effect runners**: the only layer that actually calls `wofi`, `niri msg action`, terminals, notifications, Hermes, or Codex

This keeps the interactive desktop behavior testable without clicking through Wofi.

Run all local checks:

```bash
tests/run-all.bash
```

Individual checks:

```bash
bash -n scripts/* install.sh tests/*.bash
tests/control-center-reducer.bash
tests/hermes-menu-reducer.bash
tests/niri-action-names.bash
```

Smoke test after install:

```bash
./install.sh
~/.local/bin/niri-control-center --self-test
```

Useful headless inspection commands:

```bash
NIRI_CONTROL_LANGUAGE=ko scripts/niri-control-center --prompt
NIRI_CONTROL_LANGUAGE=ko scripts/niri-control-center --menu-items
NIRI_CONTROL_LANGUAGE=ko scripts/niri-control-center --reduce-choice '󰈈  Niri · 오버뷰 켜기/끄기'
scripts/niri-hermes-menu --reduce-choice '󰑐  Hermes · Status'
```

## License

MIT
