---
name: review-bugs
description: "Hunt for bugs in a change from six angles in parallel: changed lines, removed rules, callers, language pitfalls, wrappers and secrets. One of the checks of `review`; run it alone for bugs only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

The bug check has no check of its own. It is these angle skills, next to this one:

- `review-bugs-lines`: every changed line and the function around it.
- `review-bugs-removed`: every deleted line, and where the new code still enforces its rule.
- `review-bugs-callers`: the callers of every changed function.
- `review-bugs-language`: the pitfalls of the diff's language.
- `review-bugs-wrappers`: wrappers and proxies.
- `review-bugs-secrets`: secrets in added lines.

Their files are at `<this skill's folder>/../<angle>/SKILL.md`. `review` starts the angles itself, next to its other checks.

## Run alone

Read `../review/STEPS.md` (next to this skill's folder) and run its steps 1 to 3.

First write the list of angles above, with the count. Example: "6 agents: 6 bug angles". Then send exactly that many `Agent` (general-purpose) calls in one message, one per angle, so they run at the same time. Start them only as `Agent` calls, all in that one message. Give each what "Check agents" in step 4 of `STEPS.md` says, with its angle file as the check file.

Wait until all agents have returned. Merge their findings, as "Bug angles" in step 4 of `STEPS.md` says. Then run steps 5 and 6 of `STEPS.md` for this check only.
