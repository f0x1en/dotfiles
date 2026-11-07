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
| On-screen indicators | wob (volume, mic, brightness) |
| Idle / lock | swayidle + swaylock |
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
| Audio | PipeWire + WirePlumber + Wiremix |
| Network | NetworkManager + wlctl |
| Bluetooth | BlueZ + bluetui |
| Clipboard | wl-clipboard + cliphist |
| Brightness | brightnessctl |
| Theme | Muted Campbell (see Palette below) |

## What is tracked

The repository is a bare Git repository at `~/.cfg`, with `$HOME` as the work
tree. No symlinks are used; files are managed in place.

| Area | Paths |
|---|---|
| Shell | `.zshrc`, `.zprofile`, `.gitconfig` |
| Terminal | `.tmux.conf`, `.config/kitty/` |
| Window manager | `.config/sway/`, `.config/waybar/`, `.config/kanshi/`, `.config/swaylock/`, `.config/wob/` |
| Desktop | `.config/mako/`, `.config/fuzzel/`, `.config/mimeapps.list`, `.config/user-dirs.dirs` |
| GTK | `.gtkrc-2.0`, `.config/gtk-3.0/settings.ini`, `.config/gtk-4.0/settings.ini` |
| Editor | `.config/nvim/` |
| CLI tools | `.config/btop/`, `.config/broot/`, `.config/tealdeer/`, `.config/yazi/` |
| Documents | `.config/pandoc/`, `.config/zathura/` |
| Services | `.config/NetworkManager/dispatcher.d/90-netpref` |
| Scripts | `.local/bin/clipmenu`, `.local/bin/download-batch`, `.local/bin/netpref` |
| Setup | `install.sh`, `packages/debian.txt`, `README.md` |

## Palette

Campbell-style: true neutral grays plus three accents that are far apart in hue,
so nothing is hard to tell apart. No blue or purple in the UI.

| Role | Color |
|---|---|
| Background | `#0C0C0C` |
| Panel | `#161616` |
| Selection | `#333333` |
| Border | `#2A2A2A` |
| Focus border | `#707070` |
| Dim text / icons | `#6B6B6B` |
| Text | `#B8B8B8` |
| Strong text | `#D4D4D4` |
| **Red**: error, urgent, muted | `#CC5F5A` |
| **Green**: success | `#7BAA62` |
| **Amber**: warning, highlights, links | `#D1A34D` |

Each accent always means the same thing in every app. nvim syntax uses only
four colors: red keywords, green strings, amber functions, strong-gray types
and numbers. Blue, purple and cyan exist only as quiet terminal slots in
`.config/kitty/themes/campbell.conf` for programs like `ls`; the UI never uses them.

Used by kitty, nvim, Sway, Waybar, mako, fuzzel, wob, swaylock, GTK, tmux, btop,
fzf and zathura. The values are repeated by hand in each config.

GTK uses Adwaita-dark recolored by `.config/gtk-3.0/gtk.css` and
`.config/gtk-4.0/gtk.css`, with Papirus-Dark icons and the Adwaita cursor.
`.config/sway/scripts/gtk-theme` sets the matching gsettings at login.

## Sway shortcuts

`Mod` = Super / Windows key by default. If your keyboard ignores it, run `.config/sway/scripts/set-mod` (it also runs by itself at first Sway start) and press the key you want; it is saved in `~/.config/sway/mod` (not tracked).

| Shortcut | Action |
|---|---|
| `Mod + Enter` | Open terminal |
| `Mod + D` | Application launcher |
| `Mod + W` | Open Firefox |
| `Mod + E` | Open Yazi |
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

Volume, mic and brightness changes show a bar on screen (wob): blue for volume,
green for mic, yellow for brightness, red when muted. Waybar also shows the
current volume, mic state, brightness and keyboard layout.

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

The package list targets Debian testing/sid. On Debian 13 (trixie) `yazi` and
`scrcpy` are not packaged: the installer skips unknown packages with a warning,
and fetches `yazi` from its GitHub release. Install `scrcpy` by hand if needed.
`cargo` is 1.85 there, so a `cargo install` tool that needs a newer Rust only
warns.

On a minimal install (no desktop, e.g. a VM) the installer pulls in the whole
Sway stack and `sddm`, which then owns the login screen. A normal user needs
`sudo` first (`su -`, then `apt-get install sudo git curl ca-certificates` and
`usermod -aG sudo USER`, then log in again). Do not run the installer as root:
it would configure `/root`. In VMware enable 3D acceleration, or start Sway with
`WLR_RENDERER=pixman`; add `open-vm-tools` for clipboard and resize.

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

If GitHub hangs, start the proxy on `127.0.0.1:10808` and add
`-x http://127.0.0.1:10808` to the `curl` line. The installer then uses that
proxy by itself for all downloads when it answers. Use another proxy with
`DOTFILES_PROXY=http://host:port sh ...`, or turn it off with `DOTFILES_PROXY=none`.

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
10. Installs `bluetui` and `wlctl` from GitHub release binaries, and `wiremix`
    with Cargo (rustup when the system Rust is older than 1.88). Failed steps
    are listed again at the end of the run.
11. Enables the user `ssh-agent.socket`. Copy your SSH key to `~/.ssh` yourself;
    Sway asks for its passphrase at login (`ssh-add` with zenity).
12. Installs the Claude killswitch from `packages/claude-killswitch.*` into
    `/etc` (nftables rule for your uid, systemd service). It rejects direct
    traffic to Anthropic, so `claude` only works through the proxy at
    `127.0.0.1:10808` (the `claude()` function in `.zshrc`). Start that proxy
    first, or remove the rule: `sudo systemctl disable --now claude-killswitch`.

The installer does not run `apt autoremove`, configure API keys or credentials,
or install third-party applications that are not in Debian.

## Manual setup and optional tools

Some tools used by the configuration are not packaged in Debian:

```sh
# Rust-based Wayland tools used by Sway keybindings
cargo install wiremix bluetui wlctl

# Optional personal tools referenced by shell helpers and configs
# uv, opencode, reels, omniroute, tele, tgcli, hermes
```

Other manual steps:

- Install Oh My Zsh if you did not use the installer:
  `git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh`
- Install TPM:
  `git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
  then press `Prefix + I` inside tmux.
- Run `nvim` once and use `:Lazy sync` if plugins were not installed.
- Log out and select Sway at the login screen.

## Claude Code

Tracked: `.claude/CLAUDE.md`, `.claude/settings.json`, `.claude/statusline.sh`,
`.claude/hooks/`, `.claude/skills/{park,where-am-i}`, `.config/rtk/config.toml`.
Credentials, history, projects and handoff notes are never tracked (`.gitignore`
ignores everything else under `.claude/`). Third-party skills: see
`.claude/skills/THIRD-PARTY.md`.

| Piece | What it does |
|---|---|
| Concise output style | Lead with the result, no preamble or recaps (`outputStyle` in settings) |
| `/park` | Save a handoff note to `~/.claude/handoffs/` (goal, done, state, one next step) |
| `/where-am-i` | Read it back: seven fixed lines ending in one next step |
| Status line | model, directory, git branch and changes, context %, `handoff` flag |
| Notifications | Desktop alert when Claude needs you; "finished" alert only for turns over 30 s |
| Guard hook | Blocks `git add -A` / `add .` / `add -f <dir>` on the dotfiles repo; asks before force-push, `reset --hard`, `clean -f` |
| rtk hook | Condenses `git status`, `ls`, build output; `cat`, `head`, `tail`, `sed`, `git diff/show` stay exact |

`.claude/permissions-suggested.json` is a review file, not loaded by Claude Code.
Merge it into `settings.json` yourself if you want the allow/deny rules.

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

- `.gitconfig` uses `gh` as the credential helper. If you need a proxy for
  GitHub, add an `[http]` `proxy` entry yourself; none is configured.
- Keybindings and monitor profiles are specific to this Sway configuration.
- Display profiles are managed by kanshi in `.config/kanshi/config`.
- Yazi uses Kitty's graphics protocol for image previews.
- GTK, cursor, and icon theme names must be installed separately if you want the
  exact desktop appearance.
- `.config/NetworkManager/dispatcher.d/90-netpref` is not active by itself:
  NetworkManager only reads `/etc/NetworkManager/dispatcher.d/`. It also
  hardcodes the interface names `wlp0s20f3` and `enp2s0`, as does
  `.local/bin/netpref`. Edit both before using them on another machine.
- Not installed by the installer: Claude Code itself, and the `caveman`,
  `ponytail` and other third-party skills named in `.claude/CLAUDE.md`
  (see `.claude/skills/THIRD-PARTY.md`).
- Review the configuration before using it on another machine.
