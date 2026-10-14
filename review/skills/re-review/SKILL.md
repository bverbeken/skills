---
name: re-review
description: "Re-review <PR> you reviewed before: check only the answered threads (yours and review bots') against the new code, and give a GO / NO GO verdict. Use when the user says \"re-review <PR>\", \"they replied\", or asks to check the replies on a PR they reviewed."
argument-hint: "[PR number | PR link | Linear review link | empty]"
---

Re-review the PR in `$ARGUMENTS`: only the threads that got an answer. `../review/STEPS.md` (next to this skill's folder) holds the shared steps: read it first.

## 1. Set up

Run steps 1 and 2 of `STEPS.md`. The target must be a PR. If it has none, stop and say so.

## 2. Collect the answered threads

"You" is the user running this: `gh api user -q .login` on GitHub, `me` in Linear.

Get the threads:

- **With the Linear tools:** `mcp__linear__get_diff_threads` with the PR link. Linear links a review body to its reply, which GitHub does not.
- **Otherwise:** the PR's review threads (`gh api graphql`, `pullRequest.reviewThreads` with their comments), your review bodies (`gh pr view --json reviews`), and the PR comments (`gh pr view --json comments`). Treat a PR comment from the author after one of your review bodies as an answer to it.

Keep:

- **Your threads**: threads you started or replied in, where someone answered after your last comment in that thread.
- **Bot threads**: threads started by a review bot (Copilot or another code review bot) that have any answer from a human, whenever it came.

Leave out threads started by other humans. Count the threads of yours and of bots that have no answer yet.

If nothing is left to check, say so and stop.

## 3. Check each thread

Note the commits since your last review: `git -C <reviewDir> log --oneline <your last reviewed commit>..HEAD`. Use the commit your last review was on, or the thread's anchor commit.

Start one `Agent` (general-purpose) per thread, all in one message. Give each one the thread (finding, answers, file and lines), `<reviewDir>`, the commit list, and this brief:

"An answer says either that the problem is fixed, or that it is not a problem.
- For a fix: read the commits it names, or the commits since the review. Try the thread's original example, or one you build, against the new code. Does the problem still happen?
- For an argument: check it against the code, docs or source it names. Is it true?
- If the answer points to another repo, find its checkout next to `<reviewDir>`'s repo, like in step 2 of `STEPS.md`. If it is not checked out, say `not checked`.
Answer RESOLVED, NOT RESOLVED or NEW PROBLEM, with one sentence why. For NOT RESOLVED, give the example that still fails. Return the finding in the form of step 4 of `STEPS.md`, with `check: <thread author>`."

Also run the `review-bugs` check (`../review-bugs/SKILL.md`) on the fix commits only, in one more agent. Its bugs are NEW PROBLEM findings.

Wait until all agents have answered.

## 4. Verify and report

Run step 5 of `STEPS.md` on the blocking NOT RESOLVED and NEW PROBLEM findings. Then print the report, following the rules of step 6:

```
## Re-review PR #<num>: <title>
<owner/repo> · since your review of <date time> · <n> new commits · <n> answered threads
CI: <status>

**Not resolved**
- [<thread author>] <thread title> — <one sentence>. Still fails: <example>.

**New problem**
- [<thread author or bugs>] `<location>` — <one sentence>. Fix: <fix>.

**Resolved**
- [<thread author>] <thread title> — <one sentence why>.

**Dropped in verification**
- [<thread author>] <thread title> — <why it was wrong>.

**Not yet answered**: <n> threads (<author: title>, …)

# GO      (or: # NO GO)
<one line: why>
```

NO GO means at least one verified blocking NOT RESOLVED or NEW PROBLEM finding.
