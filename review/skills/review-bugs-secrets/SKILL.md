---
name: review-bugs-secrets
description: "Look for secrets in the lines a change adds: API keys, tokens, passwords, private keys. One of the checks of `review`; run it alone for secrets only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Read every line the diff in `<reviewDir>` adds, in code, config and tests, for a **SECRET**: an API key, a token, a password, a private key, or a connection string with a password in it. A value that is obviously fake, like `test-key` or `password123` in a test, is not a secret.

Report each finding in the form of step 4 of `STEPS.md`, with `check: bugs`.

## Blocking

A SECRET always blocks.
