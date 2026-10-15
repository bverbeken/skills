---
name: review-spec
description: "Check whether a change does what its issue, linked conversations and PR say it should. One of the eight checks of `review`; run it alone to compare a change with its spec."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

The spec is everything in `<contextFile>`: the issue, its comments, its parent, the linked sources, the PR description and the commits. List every requirement in it, then compare each one with the diff. Look for:

- **MISSING**: a requirement the change does not implement, or only partly.
- **WRONG**: a requirement that looks implemented, but where the code does something else.
- **UNASKED**: behavior in the diff that no source asks for.
- **SPEC QUESTION**: a requirement that looks wrong itself, for example one that conflicts with another source or with how the product works today.

A difference is explained when the PR description, a commit message or an issue comment says why. Then it is not MISSING or WRONG.

Quote the source for each finding: the sentence and where it comes from.

## Blocking

MISSING and WRONG block when the difference is not explained. In colleague mode, UNASKED and SPEC QUESTION are suggestions.
