---
name: review-bugs
description: "Hunt for bugs in a change with Claude Code's built-in code-review. One of the checks of `review`; run it alone for bugs only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Run the built-in `code-review` skill from `<reviewDir>` (`cd <reviewDir>` first):

- Call the Skill tool with `code-review` and the arguments `high <PR number>`. Without a PR, use `high <branch name>`.
- When the review runs in place and there are uncommitted changes, call it a second time with only `high`. That reviews the uncommitted diff.

Keep its bug findings: wrong behavior, crashes, security holes, data loss, race conditions, broken error handling. Keep its test findings too, as `check: tests`. Drop its reuse, simplification and efficiency findings. The `review-refactoring` and `review-performance` checks cover those.

Turn each kept finding into the form of step 4 of `STEPS.md`. Set `verified: yes` for findings it marks CONFIRMED. Leave it out for PLAUSIBLE ones.

## Blocking

A bug blocks when it matches the definition of blocking in `STEPS.md`. Otherwise it is a suggestion.
