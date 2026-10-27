---
name: review-bugs-callers
description: "Hunt for bugs in a change across files: the callers of every changed function, and the functions it calls. One of the checks of `review`; run it alone for this kind of bug only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

For each function the diff in `<reviewDir>` changes, search the repo for its callers. Read each call site and decide whether the change breaks it. Look for:

- **NEW PRECONDITION**: the function now needs an argument, a state or an order that a caller doesn't give.
- **CHANGED RETURN**: the return value has a new shape, type, unit or meaning, or can now be null or empty, and a caller still reads it the old way.
- **NEW EXCEPTION**: the function now throws or rejects where a caller doesn't catch it.
- **ORDER DEPENDENCY**: a caller relies on timing or order that the change no longer gives, for example a side effect that now happens later.

Also read the functions the changed code calls. When the same diff changes one of them, check that the call is still safe.

Keep a finding only when you can name the call site, the input that reaches it and the wrong result. Example: "`findSeat` now returns `null` for a missing seat → `book.ts:40` calls `findSeat(id).label` → a `TypeError` for an unknown ID instead of a 404."

Report each finding in the form of step 4 of `STEPS.md`, with `check: bugs`. The location is the call site that breaks.

## Blocking

A bug blocks when it matches the definition of blocking in `STEPS.md`. Otherwise it is a suggestion.
