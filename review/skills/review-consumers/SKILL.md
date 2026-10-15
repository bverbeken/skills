---
name: review-consumers
description: "Check whether a change breaks the projects that depend on it. One of the checks of `review`; run it alone for consumers only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

First decide whether the change touches something other code depends on: a public API, shared types, a schema, an event or message format, a published library. If not, return `none`.

Find the consumers in the project's `CLAUDE.md`, `AGENTS.md` or docs. Find each one's local checkout the same way as the repo in step 2 of `STEPS.md`. Never clone one.

Check each consumer on its default branch, never on the branch the user has checked out:

1. `gh repo view <owner>/<consumer> --json defaultBranchRef -q .defaultBranchRef.name`
2. `git -C <consumerRoot> fetch origin <defaultBranch>`
3. `<consumerDir>` is `<consumerRoot>/../.review-worktrees/<consumer>-<defaultBranch>`. If it exists, remove it: `git -C <consumerRoot> worktree remove --force <consumerDir>`.
4. `git -C <consumerRoot> worktree add --detach <consumerDir> FETCH_HEAD`

Search `<consumerDir>` for code that uses what the change touches, and decide whether it breaks. With several consumers, start one `Agent` per consumer, in parallel.

Report each break as a **BREAKS** finding with the consumer's path and line. Also return one line per consumer you could not check, with the reason, for example `not checked: sdk-js (not checked out)`. The report shows these on the "Checks" line.

## Blocking

A break blocks, unless the PR or issue says how and when that consumer gets updated.
