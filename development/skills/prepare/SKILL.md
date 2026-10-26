---
name: prepare
description: "Prepare an issue before it is built: ask the user about every open decision, then write the answers in the issue. Use when the user says \"prepare <issue>\", or when another skill needs a decision about an issue or spec it is building."
---

Prepare one issue so it can be built without asking: every decision the user has to make is settled and written in the issue.

Arguments: an issue reference, or a spec without an issue. Optional: one decision that came up during a build or a review, and `--keep-status`, which leaves the issue's status alone.

## 1. Read

When the arguments hold a decision, that decision is the list. Read the issue's `## Decisions` section and go to step 3.

When the issue is already in the conversation, use it. Otherwise, fetch the issue from the issue tracker and state its title. If the reference is ambiguous, ask. Read the issue tracker docs, the issue and the code it touches. For a spec without an issue, read the spec and the code it touches.

## 2. List the open decisions

List every decision the issue leaves open: behavior it does not describe, two ways to read one sentence, a conflict with the code, a seam the tests need. Look up facts yourself; list only the decisions that are the user's.

The issue's `## Decisions` section is settled. List a decision from it again only when the code contradicts it.

A question that stopped an earlier build is open: the section the issue tracker docs name for it, for example `## Open question`. Put it on the list.

If the list is empty, say so in one line and go to step 5.

## 3. Ask

Call the Skill tool with "grilling" and grill the user on the list. Settle every decision before you write anything.

## 4. Write

Write the answers in a `## Decisions` section, one line per decision, in the words the builder will read. Write them in the issue's language.

- When the issue has a `## Decisions` section, add the new answers below the last line, and replace the lines a new answer overrules.
- Otherwise add the section right after the text that says what the issue delivers, before `## Done when` or the acceptance criteria.
- Remove the open question section once its answer is in the decisions.

Show the user the full section, and the open question section you will remove, and ask for an ok. After the ok, write the section in the issue body, the text of the issue itself, never in a comment. For a spec without an issue, the decisions stay in the conversation.

## 5. Move

Leave the status alone and say so in each of these cases:

- There is no issue, only a spec.
- `--keep-status` was passed.
- The issue tracker docs name no status for an issue that is ready to be built, such as `Ready`.
- The issue is already at that status or past it, for example in review or merged.

Otherwise, move the issue to that status.

When there is an issue, tell the user what changed in it. When another skill called this one, go back to it and continue its next step.
