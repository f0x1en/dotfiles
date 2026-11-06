#!/bin/sh
# SessionStart: always set default modes (caveman, ponytail). If a handoff note exists, tell Claude (not dump it).
ctx="Default modes for this session: caveman is ON (follow the caveman skill from the first reply until the user says 'stop caveman' or 'normal mode'). Use the ponytail skill on coding tasks."
cwd=$(jq -r '.cwd // empty' 2>/dev/null); [ -n "$cwd" ] || cwd="$PWD"
f=$("$HOME/.claude/hooks/handoff-path.sh" "$cwd")
if [ -f "$f" ]; then
  age=$(( ( $(date +%s) - $(stat -c %Y "$f") ) / 3600 ))
  if [ "$age" -ge 48 ]; then when="$((age/24)) days ago"; else when="${age}h ago"; fi
  ctx="$ctx A handoff note exists for this project (saved $when): $f. In your first reply, say so in one line and suggest /where-am-i. Do not read or summarize it unless asked."
fi
jq -n --arg c "$ctx" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
exit 0
