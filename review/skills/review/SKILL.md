---
name: review
description: "Review <PR number, GitHub or Linear link, issue ID, or branch>: a full code review with eight checks in parallel (tests, spec, bugs, performance, style, refactoring, architecture, consumers) and a GO / NO GO verdict. Use when the user says \"review <something>\", pastes a PR link to review, asks if a change is ready to merge, or another skill wants its work reviewed."
argument-hint: "[PR number | PR link | issue | branch | empty] [--only check,check]"
---

Review the target in `$ARGUMENTS` with eight checks and give one report. `STEPS.md` in this skill's folder holds the shared steps: read it first.

## 1. Set up once

Run steps 1, 2 and 3 of `STEPS.md`. Run them without asking for confirmation. If one fails, stop and report the problem.

## 2. Run the checks in parallel

The checks are the skills next to this one: `review-tests`, `review-spec`, `review-bugs`, `review-performance`, `review-style`, `review-refactoring`, `review-architecture`, `review-consumers`. Their files are at `<this skill's folder>/../review-<check>/SKILL.md`.

Run all eight, or only the ones named in `--only` (for example `--only bugs,tests`).

Start one `Agent` (general-purpose) per check, all in one message, so they run at the same time. Give each one:

- The path of its check file, and the path of `STEPS.md`.
- `<contextFile>`.
- This brief: "Read the check file and run its check on the code in `<reviewDir>`. Steps 1 to 3 are done: everything they produce is in `<contextFile>`. Return your findings in the form of step 4 of `STEPS.md`, or `none`. Do not verify, do not write a report."

## 3. Verify and report

Wait until all checks have returned, then collect their findings. Run step 5 of `STEPS.md` on the blocking ones, then step 6 for the report.
