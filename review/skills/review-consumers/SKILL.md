---
name: review-consumers
description: "Check whether a change breaks the projects that depend on it. One of the checks of `review`; run it alone for consumers only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

This check has two parts. This file finds the consumers to check. `CONSUMER.md`, next to it, checks the consumers it gets and returns their breaks. "Item agents" in step 4 of `../review/STEPS.md` (next to this skill's folder) says how the item agents start.

**Run alone:** read `../review/STEPS.md`. Run its steps 1 to 3, then the check below. Then start the item agents for the consumers it returns, with `CONSUMER.md` as the check file. Wait until they have returned, then run steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return its list.

## Check

Find the consumers to check.

First decide whether the change touches something other code depends on: a public API, shared types, a schema, an event or message format, a published library. If not, return `none`.

Find the consumers in the project's `CLAUDE.md`, `AGENTS.md` or docs. Find each one's local checkout the same way as the repo in step 2 of `STEPS.md`. Never clone one.

Return one line per consumer with a local checkout: `<consumer> (<owner>/<repo>) at <consumerRoot> — uses: <what the change touches that it may use>`. Return one line per consumer you can't check, with the reason, for example `not checked: sdk-js (not checked out)`. The report shows these on the "Checks" line.

## Blocking

A break blocks, unless the PR or issue says how and when that consumer gets updated.
