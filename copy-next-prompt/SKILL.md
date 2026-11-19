---
name: copy-next-prompt
description: Write a self-contained prompt for the next step agreed in this session and copy it to the clipboard, so the user can /clear and paste it. Use when the user says "/copy-next-prompt", "hand off", "copy the next prompt", "prompt for the next step", or "I want to clear".
argument-hint: "[the next step; default: the next step we agreed on]"
effort: low
---

# Copy the prompt for the next step

Next step: `$ARGUMENTS`

1. **Pick the next step.** With an argument, take that. Without one, take the last next step we agreed on in this session. When there is none, ask the user what the next step is, and stop.
2. **Write the prompt** as the user talking to Claude, in plain English:
   - Line 1: what to do, as one instruction.
   - Then only what a new session cannot find by itself: decisions from this session and why, file paths, issue IDs with a short description, and options that were ruled out.
   - Leave out what the new session reads anyway: CLAUDE.md, the code, the notes it is pointed to.
   - At most 15 lines.
3. **Copy it:** pipe the prompt through a quoted heredoc into `pbcopy`.
4. **Reply** with the prompt in a code block, then one line: "Copied. /clear and paste."
   When this session left uncommitted changes in a repo, add a line naming the repo.
