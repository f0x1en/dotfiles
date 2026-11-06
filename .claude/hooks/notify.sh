#!/bin/sh
# Notification hook: desktop alert when Claude needs you (permission prompt / idle).
msg=$(jq -r '.message // "Claude Code needs your attention"' 2>/dev/null)
command -v notify-send >/dev/null 2>&1 || exit 0
notify-send -a "Claude Code" -u normal -h string:x-canonical-private-synchronous:claude-needs-you "Claude needs you" "$msg"
exit 0
