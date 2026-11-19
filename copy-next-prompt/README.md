# copy-next-prompt

A long session gets expensive: every call sends the whole conversation again. `/clear` starts fresh, but then the next session doesn't know what you just decided.

`/copy-next-prompt` writes a short prompt for the next step you agreed on and copies it to your clipboard. You `/clear`, paste, and go on.

The prompt holds only what a new session can't find by itself: the decisions and why, file paths, issue IDs, and options you ruled out. It leaves out what the new session reads anyway, like `CLAUDE.md` and the code. It is at most 15 lines.

## Use

- `/copy-next-prompt`: the prompt is for the last next step you agreed on. When there is none, Claude asks.
- `/copy-next-prompt write the tests for the parser`: the prompt is for that step.

## Needs

macOS: the prompt goes to the clipboard with `pbcopy`.
