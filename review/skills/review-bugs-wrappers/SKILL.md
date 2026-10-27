---
name: review-bugs-wrappers
description: "Hunt for bugs in a change that adds or changes a type that wraps another: a cache, proxy, decorator or adapter. One of the checks of `review`; run it alone for this kind of bug only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Find each type the diff in `<reviewDir>` adds or changes that wraps another one: a cache, a proxy, a decorator or an adapter. When there is none, return `none`.

For each wrapper, look for:

- **WRONG ROUTE**: a method that goes through a registry, a session or a global instead of the wrapped instance. Example: a caching provider with a `delegate` field that loads an ID with `session.get(id)` instead of `delegate.get(id)` reads its own cache again, or recurses.
- **MISSING FORWARD**: a method the callers use that the wrapper doesn't pass on, so it does nothing, throws, or skips the wrapped instance.

Keep a finding only when you can name the call and the wrong result. Example: "`CachedVenues.reload()` is not forwarded → `admin.ts:12` calls it → the cache keeps the old venue."

Report each finding in the form of step 4 of `STEPS.md`, with `check: bugs`.

## Blocking

A bug blocks when it matches the definition of blocking in `STEPS.md`. Otherwise it is a suggestion.
