---
name: review-tests
description: "Check whether a change is well tested. One of the eight checks of `review`; run it alone for a quick look at the tests."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Read the tests only. Do not run them: CI does that.

For every code path the diff adds or changes, find the test that covers it. Read the full test files, not only the diff. Look for:

- **MISSING TEST**: a new or changed path without a test, including error paths and the edge cases the spec names.
- **WEAK TEST**: a test that runs the code but asserts nothing that would fail if the behavior broke.
- **WEAKENED TEST**: an assertion loosened, a test deleted or skipped, with no reason in the PR or commits.
- **WRONG LEVEL**: a unit test with mocks where the project tests this kind of code against real systems, or the other way round. Follow what the project's existing tests do.

## Blocking

Test findings never block. They are always suggestions.
