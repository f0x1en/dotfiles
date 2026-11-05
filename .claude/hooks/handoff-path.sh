#!/bin/sh
# Print the handoff-note path for a project directory (default: current dir).
# Project = git toplevel if inside a normal repo, else the directory itself.
# Notes live outside repos (~/.claude/handoffs) so they never pollute git or your dotfiles.
dir="${1:-$PWD}"
top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) && dir="$top"
slug=$(printf '%s' "$dir" | sed 's|/|-|g; s|^-||')
printf '%s\n' "$HOME/.claude/handoffs/$slug.md"
