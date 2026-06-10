# Niri Hermes Control Center

A small, hackable **Niri + Wofi + Hermes Agent** desktop control center for Wayland/Niri users who like fast keyboard workflows, glassy panels, scratch terminals, and AI-agent integration.

Built on a CachyOS + Niri + Rio setup, but the scripts are intentionally plain Bash.

## Features

- `ALT+SPACE` Niri Control Center via Wofi
- Hermes Agent submenu:
  - open interactive `hermes`
  - ask one-shot prompts with `hermes chat -q`
  - send focused Niri window state to Hermes
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
export NIRI_HERMES_CMD=/path/to/hermes
export NIRI_HERMES_TERMINAL=rio
```

## Screenshot

Screenshots are not committed by default. Drop your own into `assets/` if you want to show off your rice.

## Safety notes

- The installer only copies scripts to `~/.local/bin` and prints next steps.
- It does not automatically edit your Niri config.
- Power menu asks for confirmation before logout, suspend, reboot, or shutdown.
- No secrets are stored by these scripts.

## Development

Run syntax checks:

```bash
bash -n scripts/* install.sh
```

Smoke test after install:

```bash
~/.local/bin/niri-control-center --self-test
```

## License

MIT
