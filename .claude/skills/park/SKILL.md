---
name: park
description: Save a handoff note so work can resume later without re-explaining. Writes goal, progress, state, next step and gotchas to the project's handoff file. Use when the user types /park, or says "park this", "save my place", "handoff", "I'm stopping", or before ending a long session.
---

# Park

Write the handoff note, then stop. Do not commit, push, or change code.

## Steps

1. Get the path: run `~/.claude/hooks/handoff-path.sh`.
2. Run `git status -sb` (or the dotfiles form in the home directory: `git --git-dir="$HOME/.cfg" --work-tree="$HOME" status -s -uno`) for facts.
3. Overwrite the file with at most 25 lines in this shape:

```
# Handoff: <YYYY-MM-DD HH:MM> | <project directory name>
Goal: <one line>
Done this session:
- <max 5 bullets>
State: <branch>; uncommitted: <file names>; tests/build: <pass | fail | not run>
Next: <ONE concrete first step: a command, or a file and edit>
Then: <up to 2 further steps>
Open decisions: <questions still pending, or ->
Gotchas: <things that wasted time; commands that need an exact form>
```

## Rules

- Facts only: from this conversation and git. Write `unknown` when not known.
- Never write secrets, tokens, API keys, or passwords. Paths and commands exact.
- `Next` is small enough to start in under two minutes.
- Final reply, exactly one line: `Parked: <path>. Next: <the Next step>.`
