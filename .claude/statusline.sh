#!/bin/bash
# Status line: model | dir | branch*changes | ctx % | handoff
input=$(cat)
model=$(jq -r '.model.display_name // "?"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
pct=$(jq -r '.context_window.used_percentage // 0' <<<"$input" | cut -d. -f1)
[ -n "$dir" ] || dir="$PWD"
case "$dir" in "$HOME"|"$HOME"/*) short="~${dir#"$HOME"}" ;; *) short="$dir" ;; esac
g=""
if git -C "$dir" rev-parse --show-toplevel >/dev/null 2>&1; then
  br=$(git -C "$dir" branch --show-current 2>/dev/null); [ -n "$br" ] || br=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  n=$(git -C "$dir" status --porcelain -uno 2>/dev/null | wc -l)
  g=" | $br"; [ "$n" -gt 0 ] && g="$g*$n"
elif [ "$dir" = "$HOME" ] && [ -d "$HOME/.cfg" ]; then
  br=$(git --git-dir="$HOME/.cfg" branch --show-current 2>/dev/null)
  n=$(git --git-dir="$HOME/.cfg" --work-tree="$HOME" status -s -uno 2>/dev/null | wc -l)
  g=" | cfg:$br"; [ "$n" -gt 0 ] && g="$g*$n"
fi
ho=""; [ -f "$("$HOME/.claude/hooks/handoff-path.sh" "$dir")" ] && ho=" | handoff"
warn=""; [ "${pct:-0}" -ge 75 ] && warn="!"
printf '%s | %s%s | ctx %s%%%s%s\n' "$model" "$short" "$g" "${pct:-0}" "$warn" "$ho"
