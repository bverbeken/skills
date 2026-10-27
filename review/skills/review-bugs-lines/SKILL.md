---
name: review-bugs-lines
description: "Hunt for bugs in a change line by line: every changed line and the function around it. One of the checks of `review`; run it alone for this kind of bug only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Read every hunk of the diff in `<reviewDir>`, line by line, in code, config and tests. Then read the whole function around each hunk. A bug in an unchanged line of a changed function counts too: the change keeps it or fails to fix it.

For every line, ask: what input, state, timing or platform makes this line wrong? Look for:

- **WRONG CONDITION**: an inverted or wrong condition, `&&` where `||` is meant, a wrong comparison operator.
- **OFF BY ONE**: a loop bound, slice, index or range that is one too far or one too short.
- **NULL ACCESS**: a value read without a check, where another path shows it can be null, undefined or missing.
- **FALSY ZERO**: a check like `if (count)` that treats `0`, `""` or `false` as missing.
- **MISSING AWAIT**: an async call whose result or error nobody waits for.
- **WRONG VARIABLE**: a copy-pasted line that still uses the variable of the line it was copied from.
- **SWALLOWED ERROR**: a catch that logs or ignores an error the caller needs to see.
- **UNESCAPED REGEX**: user input or a literal with `.`, `*`, `+`, `?` or `(` put into a regex without escaping.

Keep a finding only when you can name the input or state that triggers it and the wrong result. Example: "`limit` is `0` → `if (limit)` is false → the query returns every row instead of none."

Report each finding in the form of step 4 of `STEPS.md`, with `check: bugs`.

## Blocking

A bug blocks when it matches the definition of blocking in `STEPS.md`. Otherwise it is a suggestion.
