# Dotfiles / system config

Start config sessions here: `cd ~/.config && claude --add-dir ~`.
Global rules in `~/.claude/CLAUDE.md` still apply.

## Repo
- Bare git repo at `~/.cfg`, work tree `$HOME`. In Bash:
  `git --git-dir="$HOME/.cfg" --work-tree="$HOME" <cmd>`.
- What is tracked and the palette: `~/README.md` ("What is tracked", "Palette").
- Stage explicit paths only. Never commit secrets: no `~/.ssh`, `~/.zshrc.local`,
  `~/.omniroute`, tokens, passwords. Check the staged diff before each commit.

## Network proxy
- Mixed (HTTP + SOCKS) proxy at `127.0.0.1:10808`. Use it when a direct
  download hangs or fails: `curl -x http://127.0.0.1:10808 --max-time 120 ...`,
  or `http_proxy=... https_proxy=...` for other tools. Always set a timeout.
  Tell the user when the proxy was used.
- apt uses it by default through `/etc/apt/apt.conf.d/95proxy` (not tracked).
  Toggle with the `.zshrc` aliases `apt-proxy-off` / `apt-proxy-on`
  (they rename the file to and from `95proxy.off`).
  One-off direct run: `sudo apt -o Acquire::http::Proxy=false -o Acquire::https::Proxy=false <cmd>`.

## Shell and sudo gotchas
- sudo needs a password and neither the Bash tool nor the user's `!` prefix has a TTY.
  Use a zenity askpass so the user types it in a popup:
  `SUDO_ASKPASS=<script running: zenity --password> sudo -A <cmd>`.
- Background jobs (`cmd &`) die when the Bash tool call ends. To start a GUI app,
  use `swaymsg exec <cmd>`.
- Bash runs zsh: `g() {...}` breaks if `g` is an alias, and `$VAR` with spaces needs `$=VAR`.
- Output may be condensed by rtk. When a git diff comes back empty, re-run it with
  `/usr/bin/git ... --no-pager diff --no-color | cat`.

## Music (mpd + rmpc), set up 2026-11-22
- mpd runs as a user service (`~/.config/mpd/mpd.conf`, state in `~/.local/state/mpd/`,
  `127.0.0.1:6600`). The system `mpd.service`/`mpd.socket` are disabled on purpose.
- User units: `mpd`, `mpDris2` (MPRIS for playerctl), `music-watch` (pauses on headphone loss).
- UI: rmpc v0.11.0, a GitHub release binary in `~/.local/bin` (not apt). install.sh pins it with sha256.
  Config `~/.config/rmpc/config.ron`, theme `themes/campbell.ron` (README palette).
- `mod+m` runs `~/.config/sway/scripts/music-toggle` (kitty titled `music`, scratchpad).
  `mod+F7/F8/F9` call `mpc`. `mod+F10` runs `music shuffle`.
- `~/.local/bin/music` holds the extras: `find` (fuzzel box over all tags + filename, rmpc `F`), `shuffle` (reorders the songs after the current one,
  spreading each folder out), `delete` (fuzzel confirm, then `gio trash`), `watch`.
- The user wants rmpc defaults kept. Only small tweaks: 3 tabs (Queue, Directories,
  Search), 2 search fields, `S` and `C-t` keys. No custom TUI. rmpc has no per-tab keys.
- Song deleted by mistake: it is in `~/.local/share/Trash` and its `.trashinfo` has the original path.
- The old mpv TUI was removed. It is still in git history before commit `59ffff2`.
