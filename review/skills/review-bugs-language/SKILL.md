---
name: review-bugs-language
description: "Hunt for bugs in a change that come from the classic pitfalls of its language or framework. One of the checks of `review`; run it alone for this kind of bug only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Name the languages and frameworks of the diff in `<reviewDir>`. Then read every line the diff adds for the classic pitfalls of each one. For example:

- JavaScript and TypeScript: `0` or `""` treated as missing, `==` that converts types, a closure that captures a loop variable.
- Python: a mutable default argument, a closure that binds its variable late.
- Go: a write to a nil map, a goroutine or closure that captures the range variable.
- SQL: input put into a query without parameters.
- Any language: a time zone or daylight saving time error, `==` on floats.

Report only a pitfall the diff adds. Use the name of the pitfall in caps as the type, for example **FALSY ZERO**, **SQL INJECTION** or **FLOAT EQUALITY**.

Keep a finding only when you can name the input or state that triggers it and the wrong result. Example: "`for (var i …) setTimeout(() => send(i))` → every callback sends the last `i`."

Report each finding in the form of step 4 of `STEPS.md`, with `check: bugs`.

## Blocking

A bug blocks when it matches the definition of blocking in `STEPS.md`. Otherwise it is a suggestion.
