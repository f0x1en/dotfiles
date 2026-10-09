# Dotfiles

Personal Linux dotfiles for a minimal, keyboard-driven environment built around Sway, Zsh, Neovim, and Kitty.

## Stack

| Category | Tools |
|---|---|
| OS | Debian Linux |
| Window manager | Sway |
| Terminal | Kitty |
| Shell | Zsh + Oh My Zsh |
| Editor | Neovim + lazy.nvim |
| Terminal multiplexer | tmux |
| Launcher | Fuzzel |
| File manager | Yazi |
| PDF viewer | Zathura |
| Image viewer | imv-wayland |
| Audio | PipeWire, WirePlumber, Wiremix |
| Network | NetworkManager, wlctl |
| Bluetooth | BlueZ, bluetui |
| Clipboard | wl-clipboard, cliphist |
| Displays | kanshi |
| Brightness | brightnessctl |
| Theme | Catppuccin Mocha |

## Sway shortcuts

`Mod` = Super / Windows key.

| Shortcut | Action |
|---|---|
| `Mod + Enter` | Open terminal |
| `Mod + D` | Application launcher |
| `Mod + Shift + Q` | Close window |
| `Mod + Shift + C` | Reload configuration |
| `Mod + Shift + E` | Exit Sway |
| `Mod + H/J/K/L` | Focus window |
| `Mod + Shift + H/J/K/L` | Move window |
| `Mod + 1–9` | Switch workspace |
| `Mod + Shift + 1–9` | Move window to workspace |
| `Mod + B` | Horizontal split |
| `Mod + V` | Vertical split |
| `Mod + F` | Toggle fullscreen |
| `Mod + Shift + Space` | Toggle floating |
| `Mod + Esc` | Lock screen |
| `Mod + N` | Network manager |
| `Mod + Shift + B` | Bluetooth manager |
| `Mod + Shift + A` | Audio mixer |
| `Mod + Shift + P` | Power menu |

### Hardware controls

| Shortcut | Action |
|---|---|
| `Mod + F1` | Toggle audio mute |
| `Mod + F2` / `F3` | Volume down / up |
| `Mod + F4` | Toggle microphone mute |
| `Mod + F5` / `F6` | Brightness down / up |

The network, Bluetooth, and audio tools run in floating Kitty windows.

## tmux shortcuts

Prefix: `Ctrl + Space`

| Shortcut | Action |
|---|---|
| `Prefix + [` | Enter copy mode |
| `v` | Begin selection |
| `y` | Copy selection to system clipboard |
| `Prefix + r` | Reload tmux configuration |
| `Alt + H/J/K/L` | Navigate panes |
| `Alt + Shift + H/J/K/L` | Resize panes |

Mouse support and Vim-style copy mode are enabled.

## Kitty

| Shortcut | Action |
|---|---|
| `Ctrl + Shift + H` | Open terminal scrollback in Neovim |

## Dependencies

Install the relevant packages for your distribution.

**Desktop**
- `sway`, `swaylock`, `kanshi`
- `kitty`, `fuzzel`
- `wl-clipboard`, `cliphist`
- `brightnessctl`

**Shell and development**
- `zsh`, `git`, `tmux`
- `neovim`
- Oh My Zsh
- lazy.nvim and configured Neovim plugins
- TPM and configured tmux plugins

**Applications**
- `yazi`, `zathura`, `imv`
- `pipewire`, `wireplumber`
- `networkmanager`
- `bluez`

**Additional tools**
- `wlctl`
- `bluetui`
- `wiremix`

Some tools and plugins require installation outside the system package manager. This repository contains configurations, not a complete automated installer.

## Configuration

- `.zshrc` — Shell setup and keybindings
- `.tmux.conf` — tmux behavior and pane navigation
- `.config/sway/` — Window management and scripts
- `.config/kitty/` — Terminal configuration
- `.config/nvim/` — Neovim configuration
- `.config/fuzzel/` — Application launcher
- `.config/yazi/` — File manager
- `.config/zathura/` — PDF viewer
- `.config/wiremix/` — Audio mixer

## Dotfiles workflow

Managed using a bare Git repository and the `config` alias.

```sh
config status
config add <file>
config diff --cached
config commit -m "feat: describe change"
config push
```

Configurations are managed in place in `$HOME`; no symlinks are required.

## Notes

- Keybindings are specific to this Sway configuration.
- Display profiles are managed by kanshi.
- Yazi uses Kitty's graphics protocol for image previews.
- Review the configurations before using them on another system.
