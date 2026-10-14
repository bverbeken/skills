---
name: review-style
description: "Check a change against the repo's documented coding standards and the style of the code around it. One of the eight checks of `review`; run it alone for style only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Find every file in the repo that says how code should be written: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md`, style guides under `docs/`. Also read the lint and formatter configs, to know what tooling already enforces.

Compare the diff with:

- **STANDARD**: a documented rule. Cite the file and the rule.
- **CONSISTENCY**: how the same thing is done in the code around it, for example naming, error handling, logging, file layout, how tests are set up. Cite an existing example with its path.

Skip anything a linter, formatter or type checker enforces.

## Blocking

Style findings never block. They are always suggestions.
