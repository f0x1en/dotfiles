#!/bin/sh
set -eu

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/f0x1en/dotfiles.git}"
CFG="${DOTFILES_GIT_DIR:-$HOME/.cfg}"
WORK_TREE="${DOTFILES_WORK_TREE:-$HOME}"

say() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
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
    apt_run() { DEBIAN_FRONTEND=noninteractive apt-get "$@"; }
else
    if ! command -v sudo >/dev/null 2>&1; then
        die "Install sudo or run this script as root."
    fi
    as_root() { sudo "$@"; }
    apt_run() { sudo env DEBIAN_FRONTEND=noninteractive apt-get "$@"; }
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
    [ -d "$HOME/.oh-my-zsh" ] && return 0
    say "Installing Oh My Zsh..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" ||
        warn "Could not install Oh My Zsh."
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
        if curl -fsSL \
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

install_cargo_tools() {
    if ! command -v cargo >/dev/null 2>&1; then
        say "cargo not found; skipping optional tools: wiremix, bluetui, wlctl."
        return 0
    fi

    for tool in wiremix bluetui wlctl; do
        command -v "$tool" >/dev/null 2>&1 && continue
        say "Installing $tool via cargo..."
        cargo install "$tool" || warn "Could not install $tool."
    done
}

install_local_overrides() {
    if [ ! -f "$HOME/.zshrc.local" ] && [ -f "$HOME/.zshrc.local.example" ]; then
        say "Creating ~/.zshrc.local from the example..."
        cp "$HOME/.zshrc.local.example" "$HOME/.zshrc.local"
        chmod 600 "$HOME/.zshrc.local"
    fi
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
install_neovim_plugins
install_cargo_tools

if command -v zsh >/dev/null 2>&1; then
    zsh -n "$HOME/.zshrc" || warn "~/.zshrc contains a syntax error."
fi

if [ "$backed_up" -eq 1 ]; then
    say "Previous conflicting files were backed up to: $backup"
fi

say "Setup complete. Log out and back in, then start Sway."
say "Review README.md for optional tools, secrets, and post-install checks."
