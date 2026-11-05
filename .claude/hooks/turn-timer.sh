#!/bin/sh
# turn-timer.sh start  (UserPromptSubmit): remember when the turn began. Prints nothing.
# turn-timer.sh end    (Stop): notify only if the turn took >= 30s, so quick answers stay quiet.
mode="$1"
input=$(cat)
sid=$(printf '%s' "$input" | jq -r '.session_id // "x"' 2>/dev/null)
f="${XDG_RUNTIME_DIR:-/tmp}/claude-turn-$sid"
case "$mode" in
  start) date +%s > "$f" 2>/dev/null ;;
  end)
    [ -f "$f" ] || exit 0
    start=$(cat "$f"); rm -f "$f"
    el=$(( $(date +%s) - start ))
    [ "$el" -ge 30 ] || exit 0
    command -v notify-send >/dev/null 2>&1 || exit 0
    last=$(printf '%s' "$input" | jq -r '.last_assistant_message // ""' 2>/dev/null | head -n1 | cut -c1-90)
    notify-send -a "Claude Code" -t 8000 -h string:x-canonical-private-synchronous:claude-done "Claude finished ($((el/60))m $((el%60))s)" "$last"
    ;;
esac
exit 0
