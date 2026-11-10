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
