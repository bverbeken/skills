---
name: review
description: "Review <PR number, GitHub or Linear link, issue ID, or branch> at any stage, before or after comments came in: eleven checks in parallel (tests, spec, bugs, performance, style, comments, refactoring, architecture, consumers, dependencies, description), the open review threads checked against the code, draft replies, and a GO / NO GO verdict. Use when the user says \"review <something>\", pastes a PR link to review, asks if a change is ready to merge, says a reviewer replied, asks to handle the comments on a PR, or another skill wants its work reviewed."
argument-hint: "[PR number | PR link | issue | branch | empty] [--only check,check]"
---

Review the target in `$ARGUMENTS` and give one report. `STEPS.md` in this skill's folder holds the shared steps: read it first.

## 1. Set up once

Run steps 1, 2 and 3 of `STEPS.md`. Run them without asking for confirmation. If one fails, stop and report the problem.

When the target is a PR, read `THREADS.md` in this skill's folder and run its steps 1 and 2. They sort the PR's existing comments into groups.

## 2. Run the checks in parallel

The checks are the skills next to this one: `review-tests`, `review-spec`, `review-bugs`, `review-performance`, `review-style`, `review-comments`, `review-refactoring`, `review-architecture`, `review-consumers`, `review-dependencies`, `review-description`. Their files are at `<this skill's folder>/../review-<check>/SKILL.md`.

Run all eleven, or only the ones named in `--only` (for example `--only bugs,tests`). The checks always look at the full diff, also when the PR was reviewed before.

Without `--only`, a **text-only** diff gets the short set: spec, bugs, style, comments and description. The diff is text-only when every file in `git -C <reviewDir> diff --name-only <merge-base>` ends in `.md` and none is in a skill folder: a folder that holds a `SKILL.md`, in `<reviewDir>` or on the base, or a folder below it. A change to a skill gets all checks. Example: a diff of `CLAUDE.md` and `docs/setup.md` is text-only; a diff of `review/skills/review/STEPS.md` is not.

`review-bugs` runs as its angles: start one check agent per angle skill that `review-bugs` lists, with the angle's file as the check file. `--only bugs` runs all angles.

`review-description` runs only when the target is a PR, and in a different way: instead of a check agent, start its cold reader (step 1 of its check) with the PR's title and body as the text.

Start one `Agent` (general-purpose) per check, all in one message, so they run at the same time. In the same message, start the thread agents of `THREADS.md` step 3. Give each check agent what "Check agents" in step 4 of `STEPS.md` says.

## 3. Verify and report

Wait until all agents have returned. Run step 2 of `review-description` on the cold reader's answer, with `<contextFile>` as what you know. When the target is a PR, also run its PR material check. Merge the findings of the bug angles, as "Bug angles" in step 4 of `STEPS.md` says. When the PR has threads, then run step 4 of `THREADS.md` to remove duplicate findings. Then run step 5 of `STEPS.md` on the blocking findings, from the checks and from the threads.

When verification rejects a thread's finding, its verdict becomes DISMISS (triage) or RESOLVED (recheck). Write its reply again to match.

Then run step 6 of `STEPS.md` for the report. `review-dependencies` also returns one line per new dependency: they go in the report's "New dependencies" section.
