# Dotfiles

Personal Linux dotfiles for a minimal, keyboard-driven environment built around
Sway, Zsh, Neovim, and Kitty.

## Stack

| Category | Tools |
|---|---|
| OS | Debian Linux |
| Window manager | Sway |
| Status bar | Waybar |
| Notifications | mako |
| Display profiles | kanshi |
| Terminal | Kitty |
| Shell | Zsh + Oh My Zsh |
| Editor | Neovim + lazy.nvim |
| Terminal multiplexer | tmux |
| Launcher | Fuzzel |
| File manager | Yazi |
| PDF viewer | Zathura |
| Image viewer | imv |
| Browser | Firefox ESR |
| Media player | mpv |
| Music player | cmus |
| Audio | PipeWire + WirePlumber + Wiremix |
| Network | NetworkManager + wlctl |
| Bluetooth | BlueZ + bluetui |
| Clipboard | wl-clipboard + cliphist |
| Brightness | brightnessctl |
| Theme | Muted Campbell (Catppuccin-derived accents) |

## What is tracked

The repository is a bare Git repository at `~/.cfg`, with `$HOME` as the work
tree. No symlinks are used; files are managed in place.

| Area | Paths |
|---|---|
| Shell | `.zshrc`, `.zprofile`, `.gitconfig` |
| Terminal | `.tmux.conf`, `.config/kitty/` |
| Window manager | `.config/sway/`, `.config/waybar/`, `.config/kanshi/` |
| Desktop | `.config/mako/`, `.config/fuzzel/`, `.config/mimeapps.list`, `.config/user-dirs.dirs` |
| GTK | `.gtkrc-2.0`, `.config/gtk-3.0/settings.ini`, `.config/gtk-4.0/settings.ini`, `.config/xsettingsd/xsettingsd.conf` |
| Editor | `.config/nvim/` |
| CLI tools | `.config/btop/`, `.config/broot/`, `.config/tealdeer/`, `.config/yazi/`, `.config/zellij/` |
| Documents | `.config/pandoc/`, `.config/zathura/` |
| Services | `.config/NetworkManager/dispatcher.d/90-netpref` |
| Scripts | `.local/bin/clipmenu`, `.local/bin/download-batch`, `.local/bin/netpref` |
| Setup | `install.sh`, `packages/debian.txt`, `README.md` |

## Sway shortcuts

`Mod` = Super / Windows key.

| Shortcut | Action |
|---|---|
| `Mod + Enter` | Open terminal |
| `Mod + D` | Application launcher |
| `Mod + W` | Open Firefox |
| `Mod + E` | Open Yazi |
| `Mod + M` | Open cmus |
| `Mod + T` | Open Telegram |
| `Mod + X` | Run a command |
| `Mod + /` | Help menu |
| `Mod + C` | Clipboard history |
| `Mod + Print` | Screenshot a region to clipboard |
| `Mod + Shift + Q` | Close window |
| `Mod + Shift + C` | Reload configuration |
| `Mod + Shift + E` | Exit Sway |
| `Mod + H/J/K/L` | Focus window |
| `Mod + Shift + H/J/K/L` | Move window |
| `Mod + Ctrl + H/J/K/L` | Resize window |
| `Mod + 1–9` | Switch workspace |
| `Mod + Shift + 1–9` | Move window to workspace |
| `Mod + B` | Split vertically |
| `Mod + V` | Split horizontally |
| `Mod + F` | Toggle fullscreen |
| `Mod + Shift + Space` | Toggle floating |
| `Mod + Esc` | Lock screen |
| `Mod + Shift + N` | Network manager (wlctl) |
| `Mod + Shift + B` | Bluetooth manager (bluetui) |
| `Mod + Shift + A` | Audio mixer (wiremix) |
| `Mod + Shift + P` | Power menu |

### Hardware controls

| Shortcut | Action |
|---|---|
| `Mod + F1` | Toggle audio mute |
| `Mod + F2` / `F3` | Volume down / up |
| `Mod + F4` | Toggle microphone mute |
| `Mod + F5` / `F6` | Brightness down / up |
| `Mod + F7` / `F8` / `F9` | cmus previous / play-pause / next |

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

Mouse support and Vim-style copy mode are enabled. Plugins are managed by TPM.

## Kitty

| Shortcut | Action |
|---|---|
| `Ctrl + Shift + H` | Open terminal scrollback in Neovim |

## Quick setup on Debian

These dotfiles configure a keyboard-driven desktop based on Sway. The installer
installs the packages listed in `packages/debian.txt`, checks out tracked files
into their normal locations under your home directory, and prepares the shell,
tmux, Neovim, and fonts.

The package list targets Debian testing/sid; some package names differ on older
Debian releases.

Install Git and curl first:

```sh
sudo apt-get update
sudo apt-get install git curl ca-certificates
```

Download and run the installer:

```sh
curl -fsSL https://raw.githubusercontent.com/f0x1en/dotfiles/main/install.sh -o /tmp/dotfiles-install.sh
sh /tmp/dotfiles-install.sh
```

The installer is safe to re-run. Existing conflicting configuration files are
backed up under `~/.dotfiles-backup-TIMESTAMP` before checkout.

### What the installer does

1. Clones `f0x1en/dotfiles` as a bare repository at `~/.cfg`.
2. Installs `packages/debian.txt` with `apt-get`.
3. Backs up conflicting files, then checks out the repository into `$HOME`.
4. Sets Zsh as the login shell.
5. Installs Oh My Zsh if it is missing.
6. Installs TPM and the configured tmux plugins.
7. Installs JetBrainsMono Nerd Font into `~/.local/share/fonts`.
8. Creates `~/.config/aria2/aria2.conf` with a random RPC secret.
9. Installs Neovim plugins with `lazy.nvim`.
10. Installs `wiremix`, `bluetui`, and `wlctl` with Cargo when Cargo is available.

The installer does not run `apt autoremove`, configure API keys or credentials,
or install third-party applications that are not in Debian.

## Manual setup and optional tools

Some tools used by the configuration are not packaged in Debian:

```sh
# Rust-based Wayland tools used by Sway keybindings
cargo install wiremix bluetui wlctl

# Optional personal tools referenced by shell helpers and configs
# zellij, uv, opencode, reels, omniroute, tele, tgcli, hermes
```

Other manual steps:

- Install Oh My Zsh if you did not use the installer:
  `git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh`
- Install TPM:
  `git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
  then press `Prefix + I` inside tmux.
- Run `nvim` once and use `:Lazy sync` if plugins were not installed.
- Log out and select Sway at the login screen.

## Secrets and local overrides

These files are intentionally not tracked:

| Path | Purpose |
|---|---|
| `.zshrc.local` | API keys and machine-specific shell overrides |
| `.config/gh/hosts.yml` | GitHub CLI credentials |
| `.config/aria2/aria2.conf` | aria2 RPC secret |
| `.config/opencode/auth.json` | OpenCode credentials |

`.gitignore` also excludes SSH/GPG keys, password stores, keyrings, browser
profiles, KDE/Plasma state, shell history, personal directories, and other
machine-local data.

Start with the example file:

```sh
cp ~/.zshrc.local.example ~/.zshrc.local
$EDITOR ~/.zshrc.local
```

`~/.zshrc` sources `~/.zshrc.local` at the end if it exists.

## Dotfiles workflow

Managed using a bare Git repository and the `config` alias defined in `.zshrc`.

```sh
config status
config add <file>
config add -f <ignored-file>
config diff --cached
config commit -m "feat: describe change"
config push
```

Because `$HOME` is the work tree, never use `config add -A`. Add explicit paths
only; `config add -f` is only for files intentionally tracked despite
`.gitignore`.

If untracked files are noisy, they are hidden with:

```sh
config config status.showUntrackedFiles no
```

For Bash or a non-interactive shell, use the full command:

```sh
git --git-dir="$HOME/.cfg" --work-tree="$HOME" status
```

## Notes

- `.gitconfig` routes GitHub and gist traffic through a local SOCKS5 proxy at
  `127.0.0.1:10808` and uses `gh` as the credential helper. Adjust or remove
  those entries if your network setup differs.
- The `reels` and `opencode` shell helpers also assume the local proxy at
  `127.0.0.1:10808`.
- Keybindings and monitor profiles are specific to this Sway configuration.
- Display profiles are managed by kanshi in `.config/kanshi/config`.
- Yazi uses Kitty's graphics protocol for image previews.
- GTK, cursor, and icon theme names must be installed separately if you want the
  exact desktop appearance.
- Review the configuration before using it on another machine.
