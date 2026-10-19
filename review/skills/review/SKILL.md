---
name: review
description: "Review <PR number, GitHub or Linear link, issue ID, or branch> at any stage, before or after comments came in: ten checks in parallel (tests, spec, bugs, performance, style, comments, refactoring, architecture, consumers, description), the open review threads checked against the code, draft replies, and a GO / NO GO verdict. Use when the user says \"review <something>\", pastes a PR link to review, asks if a change is ready to merge, says a reviewer replied, asks to handle the comments on a PR, or another skill wants its work reviewed."
argument-hint: "[PR number | PR link | issue | branch | empty] [--only check,check]"
---

Review the target in `$ARGUMENTS` and give one report. `STEPS.md` in this skill's folder holds the shared steps: read it first.

## 1. Set up once

Run steps 1, 2 and 3 of `STEPS.md`. Run them without asking for confirmation. If one fails, stop and report the problem.

When the target is a PR, read `THREADS.md` in this skill's folder and run its steps 1 and 2. They sort the PR's existing comments into groups.

## 2. Run the checks in parallel

The checks are the skills next to this one: `review-tests`, `review-spec`, `review-bugs`, `review-performance`, `review-style`, `review-comments`, `review-refactoring`, `review-architecture`, `review-consumers`, `review-description`. Their files are at `<this skill's folder>/../review-<check>/SKILL.md`.

Run all ten, or only the ones named in `--only` (for example `--only bugs,tests`). The checks always look at the full diff, also when the PR was reviewed before.

`review-description` runs only when the target is a PR, and in a different way: instead of a check agent, start its cold reader (step 1 of its check) with the PR's title and body as the text.

Start one `Agent` (general-purpose) per check, all in one message, so they run at the same time. In the same message, start the thread agents of `THREADS.md` step 3. Give each check agent:

- The path of its check file, and the path of `STEPS.md`.
- `<contextFile>`.
- This brief: "Read the check file and run its check on the code in `<reviewDir>`. Steps 1 to 3 are done: everything they produce is in `<contextFile>`. Return your findings in the form of step 4 of `STEPS.md`, or `none`. Do not verify, do not write a report."

## 3. Verify and report

Wait until all agents have returned. Run step 2 of `review-description` on the cold reader's answer, with `<contextFile>` as what you know. When the target is a PR, also run its PR material check. When the PR has threads, run step 4 of `THREADS.md` to remove duplicate findings. Then run step 5 of `STEPS.md` on the blocking findings, from the checks and from the threads.

When verification rejects a thread's finding, its verdict becomes DISMISS (triage) or RESOLVED (recheck). Write its reply again to match.

Then run step 6 of `STEPS.md` for the report.

## 4. Let the user triage the blocking items

Skip this when the verdict is GO, or when another skill runs `review` (for example `ready-for-review`).

Otherwise, ask the user which blocking items don't block. The items are every line under **Blocking** and every `(blocking)` line under **Threads**, by their `B<n>` tag. Ask in the richest way the session offers:

- **An inline widget tool** (for example `show_widget`, with its elicitation form): one group per item. The group's question is `B<n> · <TYPE> · <location>`, with the finding below it in muted text. In the group: a toggle, "Doesn't block", unselected at the start, and a text area for that item, "Why not?". An item with a reason but no toggle counts as picked.
- **`AskUserQuestion`**: one multi-select question per four items, at most four questions. Option label: `B<n> <TYPE>`. Description: the location and the finding. Above 16 items, use the plain question below. Then ask in one line why each picked item doesn't block, one `B<n>: <reason>` per line.
- **Neither**: one line, "Reply with `B<n>: <why it doesn't block>`, one per line, or press enter to keep them all."

When the user picks none, or skips, stop: the report stands.

Otherwise, move each picked item to **Not blocking (your call)**, with the user's reason when they gave one. It no longer counts toward the verdict. Its draft stays: a colleague's PR still gets the comment. Then print the **Blocking**, **Threads** and **Not blocking (your call)** sections again, and the verdict, worked out again by the rule in step 6 of `STEPS.md`.

Keep the user's call for the rest of the conversation. When `review` runs again and a blocking finding is the same problem at the same place as one the user moved, put it straight under **Not blocking (your call)** and don't ask about it again.
