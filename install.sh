#!/bin/sh
set -eu

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/f0x1en/dotfiles.git}"
CFG="${DOTFILES_GIT_DIR:-$HOME/.cfg}"
WORK_TREE="${DOTFILES_WORK_TREE:-$HOME}"

say() { printf '%s\n' "$*"; }
# Use the local proxy for every download (git, curl, cargo, rustup) when it answers.
# Override with DOTFILES_PROXY=http://host:port, or DOTFILES_PROXY=none to disable.
PROXY="${DOTFILES_PROXY:-http://127.0.0.1:10808}"
if [ "$PROXY" != none ] && command -v curl >/dev/null 2>&1 &&
    curl -sI --connect-timeout 3 -m 10 -x "$PROXY" -o /dev/null https://github.com 2>/dev/null; then
    export http_proxy="$PROXY" https_proxy="$PROXY" HTTP_PROXY="$PROXY" HTTPS_PROXY="$PROXY"
    export no_proxy=localhost,127.0.0.1,::1 NO_PROXY=localhost,127.0.0.1,::1
    printf 'Using proxy %s\n' "$PROXY"
    # sudo drops the proxy variables, so hand the proxy to apt explicitly.
    APT_OPTS="-o Acquire::http::Proxy=$PROXY -o Acquire::https::Proxy=$PROXY"
elif [ "$PROXY" != none ]; then
    printf 'warning: proxy %s did not answer; downloading directly.\n' "$PROXY" >&2
fi
APT_OPTS="${APT_OPTS:-}"

# Fail fast instead of hanging on a dead connection.
curl() { command curl --connect-timeout 20 "$@"; }

warnings=""
warn() {
    printf 'warning: %s\n' "$*" >&2
    warnings="$warnings
- $*"
}

# Run a command up to three times (GitHub downloads fail now and then).
retry() {
    n=1
    while ! "$@"; do
        [ "$n" -ge 3 ] && return 1
        n=$((n + 1))
        sleep 3
    done
}
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

if [ ! -r /etc/os-release ]; then
    die "Cannot identify the operating system."
fi

. /etc/os-release

if [ "${ID:-}" != debian ]; then
    die "This installer supports Debian only."
fi

if ! command -v git >/dev/null 2>&1; then
    die "Install git first: sudo apt-get install git"
fi

if ! command -v apt-get >/dev/null 2>&1; then
    die "apt-get is required."
fi

if [ "$(id -u)" -eq 0 ]; then
    as_root() { "$@"; }
    apt_run() { DEBIAN_FRONTEND=noninteractive apt-get $APT_OPTS "$@"; }
else
    if ! command -v sudo >/dev/null 2>&1; then
        die "Install sudo or run this script as root."
    fi
    as_root() { sudo "$@"; }
    apt_run() { sudo env DEBIAN_FRONTEND=noninteractive apt-get $APT_OPTS "$@"; }
fi

if [ ! -d "$CFG" ]; then
    say "Cloning dotfiles into $CFG..."
    git clone --bare "$REPO_URL" "$CFG"
fi

if ! git --git-dir="$CFG" rev-parse --verify HEAD >/dev/null 2>&1; then
    die "Cannot read the dotfiles repository at $CFG"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

git --git-dir="$CFG" show HEAD:packages/debian.txt >"$tmp/packages.txt" ||
    die "packages/debian.txt is missing from the repository."
git --git-dir="$CFG" ls-tree -r --name-only HEAD >"$tmp/tracked.txt"

set --
while IFS= read -r package || [ -n "$package" ]; do
    case "$package" in
        ''|\#*) continue ;;
    esac
    package=$(printf '%s' "$package" | tr -d '[:space:]')
    [ -n "$package" ] || continue
    set -- "$@" "$package"
done <"$tmp/packages.txt"

if [ "$#" -eq 0 ]; then
    die "The package manifest is empty."
fi

say "Installing Debian packages..."
apt_run update

# One unknown package aborts the whole install (e.g. yazi, scrcpy on Debian 13).
available=$(mktemp "$tmp/avail.XXXXXX")
for package in "$@"; do
    if apt-cache show "$package" >/dev/null 2>&1; then
        printf '%s\n' "$package" >>"$available"
    else
        warn "package not available, skipping: $package"
    fi
done
set --
while IFS= read -r package; do set -- "$@" "$package"; done <"$available"

apt_run install -y --no-install-recommends "$@"

backup="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
backed_up=0

backup_path() {
    src=$1
    rel=${src#"$HOME"/}
    dest="$backup/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$src" "$dest"
    backed_up=1
}

say "Checking for conflicting configuration files..."
while IFS= read -r path; do
    [ -n "$path" ] || continue

    parent=$(dirname "$path")
    while [ "$parent" != "." ]; do
        target="$HOME/$parent"
        if [ -L "$target" ] || { [ -e "$target" ] && [ ! -d "$target" ]; }; then
            say "Backing up $target"
            backup_path "$target"
            mkdir -p "$target"
        fi
        parent=$(dirname "$parent")
    done

    target="$HOME/$path"
    if [ -L "$target" ] || [ -d "$target" ]; then
        say "Backing up $target"
        backup_path "$target"
    elif [ -e "$target" ]; then
        git --git-dir="$CFG" show "HEAD:$path" >"$tmp/expected"
        if ! cmp -s "$tmp/expected" "$target"; then
            say "Backing up $target"
            backup_path "$target"
        fi
    fi
done <"$tmp/tracked.txt"

branch=$(git --git-dir="$CFG" rev-parse --abbrev-ref HEAD 2>/dev/null || printf 'main')

say "Checking out dotfiles ($branch) into $WORK_TREE..."
git --git-dir="$CFG" --work-tree="$WORK_TREE" checkout -f "$branch"
git --git-dir="$CFG" --work-tree="$WORK_TREE" config status.showUntrackedFiles no

install_shell() {
    zsh_path=$(command -v zsh || true)
    [ -n "$zsh_path" ] || return 0

    login_shell=$(getent passwd "$(id -un)" | cut -d: -f7)
    if [ "$login_shell" != "$zsh_path" ]; then
        say "Setting zsh as the login shell..."
        as_root chsh -s "$zsh_path" "$(id -un)" ||
            warn "Could not change the login shell. Run: chsh -s $zsh_path"
    fi
}

install_omz() {
    [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ] && return 0
    say "Installing Oh My Zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    retry git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" ||
        warn "Could not install Oh My Zsh. Run: git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh"
}

install_tpm() {
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        say "Installing tmux plugin manager..."
        git clone --depth=1 https://github.com/tmux-plugins/tpm \
            "$HOME/.tmux/plugins/tpm" || {
            warn "Could not install tmux plugin manager."
            return 0
        }
    fi

    command -v tmux >/dev/null 2>&1 || return 0

    say "Installing tmux plugins..."
    if command -v timeout >/dev/null 2>&1; then
        timeout 120 "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 ||
            warn "tmux plugin installation failed. Open tmux and press prefix + I."
    else
        "$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 ||
            warn "tmux plugin installation failed. Open tmux and press prefix + I."
    fi
}

install_fonts() {
    font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"

    if [ ! -f "$font_dir/JetBrainsMonoNerdFont-Regular.ttf" ]; then
        say "Installing JetBrainsMono Nerd Font..."
        archive="$tmp/JetBrainsMono.zip"
        if retry curl -fsSL \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
            -o "$archive"; then
            unzip -oq "$archive" -d "$font_dir" ||
                warn "Could not extract the JetBrainsMono Nerd Font archive."
        else
            warn "Could not download JetBrainsMono Nerd Font."
        fi
    fi

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$font_dir" >/dev/null 2>&1 || true
    fi
}

install_aria2_config() {
    conf="$HOME/.config/aria2/aria2.conf"
    example="$HOME/.config/aria2/aria2.conf.example"

    [ -f "$conf" ] && return 0
    [ -f "$example" ] || return 0

    say "Creating aria2 configuration..."
    secret=$(od -An -N24 -tx1 /dev/urandom | tr -d ' \n')
    sed -e "s|__HOME__|$HOME|g" \
        -e "s|__RPC_SECRET__|$secret|g" "$example" >"$conf"
    chmod 600 "$conf"
}

install_neovim_plugins() {
    command -v nvim >/dev/null 2>&1 || return 0

    say "Installing Neovim plugins..."
    if command -v timeout >/dev/null 2>&1; then
        timeout 300 nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 ||
            warn "Neovim plugin installation failed. Run :Lazy sync inside nvim."
    else
        nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 ||
            warn "Neovim plugin installation failed. Run :Lazy sync inside nvim."
    fi
}

install_release_bin() {
    # install_release_bin NAME URL: static musl binary into ~/.local/bin
    command -v "$1" >/dev/null 2>&1 && return 0
    say "Installing $1 from the GitHub release..."
    mkdir -p "$HOME/.local/bin"
    if retry curl -fsSL "$2" -o "$tmp/$1.bin"; then
        install -m 755 "$tmp/$1.bin" "$HOME/.local/bin/$1"
    else
        warn "Could not install $1 (Mod+Shift+B/N need bluetui/wlctl)."
    fi
}

install_tui_tools() {
    case "$(uname -m)" in
        x86_64) arch=x86_64 ;;
        aarch64) arch=aarch64 ;;
        *) arch="" ;;
    esac
    if [ -n "$arch" ]; then
        install_release_bin bluetui \
            "https://github.com/pythops/bluetui/releases/latest/download/bluetui-$arch-linux-musl"
        install_release_bin wlctl \
            "https://github.com/aashish-thapa/wlctl/releases/latest/download/wlctl-$arch-unknown-linux-musl"
    fi
}

install_wiremix() {
    # No release binary and no Debian package. Needs Rust >= 1.88; Debian 13 has 1.85,
    # so use rustup when the system cargo is older.
    command -v wiremix >/dev/null 2>&1 && return 0
    export PATH="$HOME/.cargo/bin:$PATH"
    need="1.88"
    have=$(cargo --version 2>/dev/null | sed -n 's/^cargo \([0-9]*\.[0-9]*\).*/\1/p')
    if [ -z "$have" ] || [ "$(printf '%s\n%s\n' "$need" "$have" | sort -V | head -n1)" != "$need" ]; then
        say "Installing a newer Rust toolchain with rustup..."
        if retry curl -fsSL https://sh.rustup.rs -o "$tmp/rustup.sh"; then
            sh "$tmp/rustup.sh" -y --profile minimal --no-modify-path ||
                { warn "Could not install rustup; wiremix (Mod+Shift+A) not installed."; return 0; }
        else
            warn "Could not download rustup; wiremix (Mod+Shift+A) not installed."
            return 0
        fi
    fi
    say "Installing wiremix via cargo..."
    cargo install --locked wiremix || warn "Could not install wiremix (Mod+Shift+A)."
}

install_rtk() {
    # Command-output compressor used by the Claude Code PreToolUse hook in
    # ~/.claude/settings.json. The hook is a silent no-op when rtk is missing.
    # Apache-2.0 hook-only build, pinned. Do NOT `cargo install rtk` from crates.io:
    # that is a different, unrelated package.
    command -v cargo >/dev/null 2>&1 || return 0
    command -v rtk >/dev/null 2>&1 && return 0
    say "Installing rtk (Apache-2.0 hook build, ~5 min)..."
    cargo install --git https://github.com/rtk-ai/rtk --tag v1.1.0 --no-default-features rtk ||
        warn "Could not install rtk (optional)."
}

install_yazi() {
    # Not packaged in Debian 13. Static release binary, x86_64 only.
    command -v yazi >/dev/null 2>&1 && return 0
    [ "$(uname -m)" = x86_64 ] || return 0
    command -v unzip >/dev/null 2>&1 || return 0
    say "Installing yazi from the GitHub release..."
    if curl -fsSL \
        "https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip" \
        -o "$tmp/yazi.zip" && unzip -oq "$tmp/yazi.zip" -d "$tmp/yazi"; then
        mkdir -p "$HOME/.local/bin"
        install -m 755 "$tmp"/yazi/*/yazi "$tmp"/yazi/*/ya "$HOME/.local/bin/"
    else
        warn "Could not install yazi (optional)."
    fi
}

install_local_overrides() {
    if [ ! -f "$HOME/.zshrc.local" ] && [ -f "$HOME/.zshrc.local.example" ]; then
        say "Creating ~/.zshrc.local from the example..."
        cp "$HOME/.zshrc.local.example" "$HOME/.zshrc.local"
        chmod 600 "$HOME/.zshrc.local"
    fi
}

enable_ssh_agent() {
    # Sway runs ssh-add against $XDG_RUNTIME_DIR/openssh_agent at login.
    systemctl --user enable ssh-agent.socket >/dev/null 2>&1 ||
        warn "Could not enable ssh-agent.socket. Run after login: systemctl --user enable --now ssh-agent.socket"
}

install_killswitch() {
    # Rejects direct Anthropic traffic for this user, so Claude Code only works
    # through the local proxy (127.0.0.1:10808). Remove: sudo systemctl disable --now claude-killswitch
    src="$HOME/packages"
    [ -f "$src/claude-killswitch.nft" ] || return 0
    command -v systemctl >/dev/null 2>&1 || return 0
    if [ ! -x /usr/sbin/nft ]; then
        warn "nft not found; skipping the Claude killswitch."
        return 0
    fi
    say "Installing the Claude killswitch..."
    uid=$(id -u)
    sed "s|__UID__|$uid|g" "$src/claude-killswitch.nft" >"$tmp/claude-killswitch.nft"
    {
        as_root install -d -m 755 /etc/nftables.d &&
        as_root install -m 644 "$tmp/claude-killswitch.nft" /etc/nftables.d/claude-killswitch.nft &&
        as_root install -m 644 "$src/claude-killswitch.service" /etc/systemd/system/claude-killswitch.service &&
        as_root systemctl daemon-reload &&
        as_root systemctl enable --now claude-killswitch.service
    } || warn "Could not install the Claude killswitch."
}

link_fd() {
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
}

install_shell
install_omz
install_tpm
install_fonts
install_aria2_config
install_local_overrides
link_fd
enable_ssh_agent
install_killswitch
install_yazi
install_neovim_plugins
install_tui_tools
install_wiremix
install_rtk

if command -v zsh >/dev/null 2>&1; then
    zsh -n "$HOME/.zshrc" || warn "~/.zshrc contains a syntax error."
fi

if [ -n "$warnings" ]; then
    printf '\nThese steps FAILED or were skipped:%s\n\n' "$warnings" >&2
fi

if [ "$backed_up" -eq 1 ]; then
    say "Previous conflicting files were backed up to: $backup"
fi

say "Setup complete. Log out and back in, then start Sway."
say "Review README.md for optional tools, secrets, and post-install checks."
