---
name: review-architecture
description: "Check whether a change fits the codebase's design and its recorded decisions. One of the eight checks of `review`; run it alone for architecture only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Gather the project's recorded decisions:

- ADRs (`docs/adr/`, `docs/decisions/`, or wherever the project keeps them).
- Domain docs and glossaries (`docs/agents/domain.md`, `GLOSSARY.md`, `CONTEXT.md`).
- What `CLAUDE.md` / `AGENTS.md` say about structure.
- The existing code: how similar features are built, and which layer or module owns what.

Then look for:

- **WRONG LAYER**: logic in a layer that doesn't own it, for example business rules in a controller or SQL in a view.
- **SECOND WAY**: a new way to do something the codebase already does one way.
- **NEW DEPENDENCY**: a dependency between modules that didn't depend on each other, or one that points the wrong way.
- **CONTRADICTS DECISION**: a choice that goes against a recorded decision. Cite it.
- **UNRECORDED DECISION**: a choice big enough that it should be recorded, and isn't.
- **DOMAIN TERMS**: a domain term used differently from the glossary, or a new name for a concept that already has one.

Small moves to another package belong to `review-refactoring`. Report placement here when it reflects a design choice.

## Blocking

CONTRADICTS DECISION blocks when the change doesn't explain why. In colleague mode, everything else is a suggestion.
