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
- **WRONG LEVEL**: a test at a level the repo's written testing rule does not want, for example edge cases in slow end-to-end tests where the rule asks for unit or integration tests, or mocks where the project tests against real systems. Read the rule first in `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` and the files they import. The written rule wins over the existing tests and over what the issue asks for. Without a written rule, follow what the project's existing tests do.

## Blocking

WRONG LEVEL against a written rule blocks: it breaks a written repo rule. In colleague mode, other test findings are suggestions.
