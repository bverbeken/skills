---
name: review-bugs-removed
description: "Hunt for bugs in a change through what it removes: every deleted or replaced line, and where the new code still enforces its rule. One of the checks of `review`; run it alone for this kind of bug only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Read every line the diff in `<reviewDir>` deletes or replaces, in code, config and tests. For each one, name the rule or behavior it enforced. Then search the new code for the place that still enforces it. When you can't find that place, it is a candidate. Look for:

- **REMOVED GUARD**: a check, a lock or an early return that is gone, so a case it stopped now gets through.
- **DROPPED ERROR PATH**: an error that was thrown, returned or handled, and is now ignored or turned into a success.
- **NARROWED VALIDATION**: input that was rejected before and is accepted now, or a format, range or length that is no longer checked.
- **STILL USED**: a deleted import, variable, function, field or file that code in the new version still uses. Search the whole file and the repo for its name, not only the diff.

Keep a finding only when you can name the input or state that the old code handled and the wrong result the new code gives. Example: "the deleted `if (!user.isAdmin) throw` → a normal user calls `deleteVenue` → the venue is deleted."

When you see a bug that this angle does not look for, report it too, with the input that triggers it. Another angle may miss it.

Report each finding in the form of step 4 of `STEPS.md`, with `check: bugs`.

## Blocking

A bug blocks when it matches the definition of blocking in `STEPS.md`. Otherwise it is a suggestion.
