# Dotfiles / system config

Start config sessions here: `cd ~/.config && claude --add-dir ~`.
Global rules in `~/.claude/CLAUDE.md` still apply.

## Repo
- Bare git repo at `~/.cfg`, work tree `$HOME`. In Bash:
  `git --git-dir="$HOME/.cfg" --work-tree="$HOME" <cmd>`.
- What is tracked and the palette: `~/README.md` ("What is tracked", "Palette").
- `.gitignore` is `*`: stage tracked files with `add -u <path>` (plain `add` warns
  and exits 1), new files with `add -f <file>`. Do not add `!*/`: it makes git read
  nested `.gitignore` files that re-include files (notes, wordlists).
- Stage explicit paths only. Never commit secrets: no `~/.ssh`, `~/.zshrc.local`,
  `~/.omniroute`, tokens, passwords. Check the staged diff before each commit.

## Network proxy
- Mixed (HTTP + SOCKS) proxy at `127.0.0.1:10808`; every client uses it (10809 is HTTP-only, unused). Served by
  Bushuray (xray TUI client, replaced v2rayN 2026-11-25): user service `bushuray`
  (`$HOME/.local/opt/bushuray`, GitHub release v0.2.3, not apt), TUI `bushuray`,
  config `$HOME/.config/bushuray/config.json`, data `$HOME/.local/share/bushuray`.
  Never stop it from a Claude session without a detached rollback: Claude's own traffic uses it.
- Fallback: `proxy v2rayn` runs v2rayN's old xray core + last config from
  `$HOME/.local/share/proxy-fallback` (unit `proxy-fallback`, conflicts with `bushuray`;
  config.json holds server credentials, not tracked). `proxy-watch` (only while
  NetworkManager is connected) restarts Bushuray after 3 failed checks, switches to v2rayN after
  3 more and notifies, then retries Bushuray every 10 min. A manual `proxy v2rayn` is never undone.
  `proxy retry` does one try by hand; `proxy bushuray` forces it; `proxy` checks both ports.
- Use it when a direct
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
- The user wants rmpc defaults kept. Only small tweaks: 2 tabs (Queue, Directories;
  search is `F` = `music find`), `S`, `F` and `C-t` keys. No custom TUI. rmpc has no per-tab keys.
- Song deleted by mistake: it is in `~/.local/share/Trash` and its `.trashinfo` has the original path.
- The old mpv TUI was removed. It is still in git history before commit `59ffff2`.
