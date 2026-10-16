---
name: review-style
description: "Check a change against the repo's documented coding standards and the style of the code around it. One of the checks of `review`; run it alone for style only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Find every file in the repo that says how code should be written: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md`, style guides under `docs/`. Also read `CLAUDE.md` and `AGENTS.md` in the folders above the repo, and the lint and formatter configs, to know what tooling already enforces.

Compare the diff with:

- **STANDARD**: a documented rule. Cite the file and the rule.
- **CONSISTENCY**: how the same thing is done in the code around it, for example naming, error handling, logging, file layout, how tests are set up. Cite an existing example with its path.
- **DEBUG LEFTOVER**: a debug statement the diff adds: `console.log`, `debugger`, `print`, `System.out.println`, `dump()`, or a focused test (`.only`, `fdescribe`, `fit`). A statement that matches how the code around it logs on purpose is real logging, not a leftover.

Skip anything a linter, formatter or type checker enforces. Skip code comments: `review-comments` checks those.

## Blocking

DEBUG LEFTOVER always blocks. STANDARD findings block when they break a rule in force (`../review/STEPS.md` step 4). In colleague mode, CONSISTENCY findings are suggestions.
