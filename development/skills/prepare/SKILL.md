---
name: prepare
description: "Prepare an issue before it is built: ask the user about the decisions that matter, decide the details, then write both in the issue. Use when the user says \"prepare <issue>\", or when another skill needs a decision about an issue or spec it is building."
---

Prepare one issue so it can be built without asking: every decision the user has to make is settled and written in the issue.

Arguments: an issue reference, or a spec without an issue. Optional: one decision that came up during a build or a review, and `--keep-status`, which leaves the issue's status alone.

## 1. Read

When the arguments hold a decision, that decision is the list. Read the issue's `## Decisions` section and go to step 3.

When the issue is already in the conversation, use it. Otherwise, fetch the issue from the issue tracker and state its title. If the reference is ambiguous, ask. Read the issue tracker docs, the issue and the code it touches. For a spec without an issue, read the spec and the code it touches.

## 2. List the open decisions

First check that the issue is still current: the code or another issue may already cover it. When it may be moot, ask that one question, and stop when the user says it is.

List every decision the issue leaves open: behavior it does not describe, two ways to read one sentence, a conflict with the code, a seam the tests need. Look up facts yourself.

Sort each decision into one of two lists.

Ask the user when the decision changes:

- what a user sees or does: screens, keys, wording, the order of steps
- what can be lost, leaked or not undone
- a name the user will read or type: a command, a flag, a folder, a status
- where config or code lives, or which repo owns it
- the scope: what the issue includes, drops or splits off
- the order of work, or a link to another issue
- how the process runs: who moves a status, who merges

Decide yourself on details inside a choice that is already made: limits, timeouts, retries, file layout, data shape, error text, test scope, cleanup. When a case is outside the issue, decide to leave it out and propose a follow-up issue.

The issue's `## Decisions` section is settled. List a decision from it again only when the code contradicts it.

A question that stopped an earlier build is open: the section the issue tracker docs name for it, for example `## Open question`. Put it on the list.

If both lists are empty, say so in one line and go to step 5. If only the list to ask is empty, say so in one line and go to step 4.

## 3. Ask

Before the first question, summarize the issue for the user in a few short lines: what it is about, what it delivers when it is done, and what blocks it. Then call the Skill tool with "grilling" and grill the user on the list to ask. Keep each question short, in plain words, and say what each answer changes for the user. Settle every decision before you write anything. Tell grilling that you ask for the confirmation yourself: the ok in step 4 is the user's confirmation.

## 4. Write

Write the answers in a `## Decisions` section, one line per decision, in the words the builder will read. Write them in the issue's language.

- When the issue has a `## Decisions` section, add the new answers below the last line, and replace the lines a new answer overrules.
- Otherwise add the section right after the text that says what the issue delivers, before `## Done when` or the acceptance criteria.
- Remove the open question section once its answer is in the decisions.
- Write your own decisions in the same section, each line ending with `(decided by prepare)`. The user sees them at the ok and can overrule any one.

Show the user the full section, and the open question section you will remove, and ask for an ok. After the ok, write the section in the issue body, the text of the issue itself, never in a comment. For a spec without an issue, the decisions stay in the conversation.

## 5. Move

UPPERCASE statuses, such as `NEXT_UP`, are Faber statuses. The issue tracker docs map each one to a status of the tracker.

Leave the status alone and say so in each of these cases:

- There is no issue, only a spec.
- `--keep-status` was passed.
- The issue tracker docs map no status to `NEXT_UP`.
- The issue is in `BLOCKED`, or closed without being done, for example canceled.
- The issue is already in `NEXT_UP` or past it, for example in `READY_FOR_REVIEW` or `MERGED`.

Otherwise, move the issue to `NEXT_UP`.

When there is an issue, tell the user what changed in it. When another skill called this one, go back to it and continue its next step.
