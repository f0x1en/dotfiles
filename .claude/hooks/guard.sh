#!/bin/bash
# PreToolUse(Bash) guard. Reads the hook JSON on stdin.
#  - BLOCKS (exit 2) staging everything in the dotfiles bare repo ($HOME is its work tree):
#      add -A / --all / .   and   add -f <directory>
#  - ASKS before force-push, hard reset, git clean -f.
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cmd" ] || exit 0

# Judge only the real command: drop heredoc bodies and quoted strings first, so text
# that merely mentions "add -A" (docs, commit messages, python code) cannot trigger it.
scan=$(printf '%s' "$cmd" | perl -0777 -pe 's/<<-?\s*(["\x27]?)(\w+)\1[^\n]*\n.*?\n\s*\2[ \t]*(?=\n|$)/<<HEREDOC/gs; s/\x27[^\x27]*\x27/\x27\x27/gs; s/"(?:[^"\\]|\\.)*"/""/gs' 2>/dev/null)
[ -n "$scan" ] || scan="$cmd"

ask() { jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$r}}'; exit 0; }

if [[ "$cmd" == *".cfg"* ]]; then
  if printf '%s' "$scan" | grep -Eq '(^|[;&|[:space:]])add[[:space:]]+([^;&|]*[[:space:]])?(-A|--all|\.)([[:space:];&|]|$)'; then
    echo "Blocked: add -A / add . on the dotfiles repo would stage \$HOME. Add explicit paths (or 'add -u')." >&2
    exit 2
  fi
  if printf '%s' "$scan" | grep -Eq '(^|[;&|[:space:]])add[[:space:]]+([^;&|]*[[:space:]])?(-f|--force)([[:space:]]|$)'; then
    for tok in $(printf '%s' "$scan" | sed -E 's/.*[[:space:]]add[[:space:]]+//; s/[;&|].*//'); do
      case "$tok" in -*) continue ;; esac
      p="${tok/#\~/$HOME}"
      if [ -d "$p" ] || [ -d "$cwd/$p" ]; then
        echo "Blocked: add -f on directory '$tok' force-adds ignored files (node_modules, caches, backups). Name files explicitly." >&2
        exit 2
      fi
    done
  fi
fi

printf '%s' "$scan" | grep -Eq 'git[^;&|]*[[:space:]]push[^;&|]*([[:space:]]-f([[:space:]]|$)|--force)' && ask "Force-push rewrites remote history. Confirm."
printf '%s' "$scan" | grep -Eq 'git[^;&|]*[[:space:]]reset[[:space:]]+[^;&|]*--hard' && ask "git reset --hard discards uncommitted work. Confirm."
printf '%s' "$scan" | grep -Eq 'git[^;&|]*[[:space:]]clean[[:space:]]+-[a-zA-Z]*f' && ask "git clean -f deletes untracked files. Confirm."
exit 0
