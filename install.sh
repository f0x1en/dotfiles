#!/bin/sh
set -eu

REPO_URL="https://github.com/f0x1en/dotfiles.git"
CFG="$HOME/.cfg"

if [ ! -r /etc/os-release ]; then
    echo "Cannot identify operating system." >&2
    exit 1
fi

. /etc/os-release
if [ "${ID:-}" != debian ]; then
    echo "This installer supports Debian only." >&2
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "Install git first: sudo apt-get install git" >&2
    exit 1
fi

if [ ! -d "$CFG" ]; then
    echo "Cloning dotfiles..."
    git clone --bare "$REPO_URL" "$CFG"
fi

if ! git --git-dir="$CFG" rev-parse --verify HEAD >/dev/null 2>&1; then
    echo "Cannot read the dotfiles repository at $CFG" >&2
    exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

git --git-dir="$CFG" show HEAD:packages/debian.txt > "$tmp/packages.txt"
git --git-dir="$CFG" ls-tree -r --name-only HEAD > "$tmp/tracked.txt"

set --
while IFS= read -r package || [ -n "$package" ]; do
    case "$package" in
        ''|\#*) continue ;;
    esac
    set -- "$@" "$package"
done < "$tmp/packages.txt"

if [ "$#" -eq 0 ]; then
    echo "The package manifest is empty." >&2
    exit 1
fi

echo "Installing Debian packages..."
if [ "$(id -u)" -eq 0 ]; then
    apt-get update
    apt-get install --no-install-recommends "$@"
else
    command -v sudo >/dev/null 2>&1 || {
        echo "Install sudo or run this script as root." >&2
        exit 1
    }
    sudo apt-get update
    sudo apt-get install --no-install-recommends "$@"
fi

backup="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
backed_up=0

echo "Checking for conflicting configuration files..."
while IFS= read -r path; do
    parent=$(dirname "$path")

    while [ "$parent" != "." ]; do
        target="$HOME/$parent"
        if [ -L "$target" ] || {
            [ -e "$target" ] && [ ! -d "$target" ]
        }; then
            mkdir -p "$backup/$(dirname "$parent")"
            mv "$target" "$backup/$parent"
            backed_up=1
        fi
        parent=$(dirname "$parent")
    done

    target="$HOME/$path"
    if [ -e "$target" ] || [ -L "$target" ]; then
        git --git-dir="$CFG" show "HEAD:$path" > "$tmp/expected"
        if [ -L "$target" ] || [ -d "$target" ] ||
            ! cmp -s "$tmp/expected" "$target"; then
            mkdir -p "$backup/$(dirname "$path")"
            mv "$target" "$backup/$path"
            backed_up=1
        fi
    fi
done < "$tmp/tracked.txt"

echo "Checking out dotfiles into $HOME..."
git --git-dir="$CFG" --work-tree="$HOME" checkout -f main
git --git-dir="$CFG" config status.showUntrackedFiles no

if [ "$backed_up" -eq 1 ]; then
    echo "Previous conflicting files were backed up to: $backup"
fi

echo "Setup complete. Open a new terminal or log out and back in."
echo "Review README.md for the installed tools and setup details."
