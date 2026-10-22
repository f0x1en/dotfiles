#!/bin/sh
set -eu

if [ ! -r /etc/os-release ]; then
    printf '%s\n' "Cannot identify operating system."
    exit 1
fi

. /etc/os-release

if [ "${ID:-}" != debian ]; then
    printf '%s\n' "This installer supports Debian only."
    exit 1
fi

packages_file="$HOME/packages/debian.txt"

if [ ! -r "$packages_file" ]; then
    printf 'Package list not found: %s\n' "$packages_file" >&2
    exit 1
fi

set --
while IFS= read -r package || [ -n "$package" ]; do
    case "$package" in
        ''|\#*) continue ;;
    esac
    set -- "$@" "$package"
done < "$packages_file"

if [ "$#" -eq 0 ]; then
    printf '%s\n' "No packages listed."
    exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
    apt-get update
    apt-get install --no-install-recommends "$@"
else
    if ! command -v sudo >/dev/null 2>&1; then
        printf '%s\n' "Install sudo or run this script as root." >&2
        exit 1
    fi
    sudo apt-get update
    sudo apt-get install --no-install-recommends "$@"
fi
