#!/bin/sh
# SessionStart: if a handoff note exists for this project, tell Claude (not dump it).
cwd=$(jq -r '.cwd // empty' 2>/dev/null); [ -n "$cwd" ] || cwd="$PWD"
f=$("$HOME/.claude/hooks/handoff-path.sh" "$cwd")
[ -f "$f" ] || exit 0
age=$(( ( $(date +%s) - $(stat -c %Y "$f") ) / 3600 ))
if [ "$age" -ge 48 ]; then when="$((age/24)) days ago"; else when="${age}h ago"; fi
jq -n --arg p "$f" --arg w "$when" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:("A handoff note exists for this project (saved " + $w + "): " + $p + ". In your first reply, say so in one line and suggest /where-am-i. Do not read or summarize it unless asked.")}}'
exit 0
