---
name: where-am-i
description: Re-orient after a break or context switch. Reports goal, done, in-progress, ONE next step and blockers from the handoff note and git state, in under 10 lines. Use when the user types /where-am-i, or asks "where was I", "what was I doing", "catch me up", "what's next", or resumes a project.
---

# Where am I

Read-only. Do not edit files. Do not start the work.

## Gather (read-only)

1. Handoff note: run `~/.claude/hooks/handoff-path.sh` to get the path. Read it if it exists.
2. Git state:
   - Normal repo: `git status -sb` and `git log --oneline -5`.
   - Home directory (dotfiles bare repo): `git --git-dir="$HOME/.cfg" --work-tree="$HOME" status -s -uno` and the same with `log --oneline -5`.
3. If there is no handoff note and git shows no recent change: reply `No handoff, no recent changes. Tell me the goal.` and stop.

## Reply format (exactly this, nothing before or after)

```
Goal: <one line>
Done: <one line, or ->
In progress: <one line, or ->
Next: <ONE concrete first action: a command, or a file and edit>
Blocked/risk: <one line, or ->
State: <branch>, <N> uncommitted, last commit "<subject>" (<age>)
Note: <when the handoff was saved>
```

## Rules

- `Next` is one step small enough to start in under two minutes.
- Do not guess. Write `unknown` for any field the note and git do not show.
- If the note and git disagree (note says done, files still uncommitted), say so in `Blocked/risk`.
- If the note is older than 7 days, append: `Note may be outdated.`
- No greeting, no menu of options, no offer to continue. End after `Note`.
