---
name: implement
description: "Implement a piece of work based on a spec or set of issues. Use when the user says \"implement <issue>\", or when another skill builds an issue or spec."
argument-hint: "<issue or spec> [review findings] [--afk]"
---

Implement the work described by the user in the spec or issues. Write the code and nothing else: `foreman` holds the steps before and after this one.

If the user passes an issue reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

When the arguments hold review findings, the build is done already: fix each finding in its own commit, in the existing worktree, and end as below.

UPPERCASE statuses, such as `TO_CLARIFY`, are factory statuses. The issue tracker docs map each one to a status of the tracker.

## --afk

With `--afk`, nobody watches the build. Ask nothing: where a step says to ask, take your own recommendation and go on. Pass `--afk` on to `tdd`.

- When the issue still has an open question section, its answer never reached the decisions: **stop** without building.
- A new open decision during the build: take your own recommendation, or **stop** when the decision is really the user's.

To **stop**: write the question in the issue's open question section, or leave the one that is there, as the issue tracker docs name it, and move the issue to `TO_CLARIFY`. When the docs map no `TO_CLARIFY`, the issue stays in its status: say that it needs a manual move. Then end, and say that the build stopped. When there is no issue, or the docs name no such section, print the question, leave the status alone, and end.

## Open decisions

Build from the issue's `## Decisions` section. When an open decision comes up during the build, stop and call the Skill tool with "prepare", the issue reference or spec, `--keep-status` and that decision. A review finding that says the spec or the design is wrong is a new open decision too. Build on the answer, never on a guess.

## Worktree

Build the work in its own git worktree, so the user's checkout stays untouched.

1. Pick the repo the work belongs in. In a multi-repo workspace, take it from the issue (its labels, the code it names). If it could be more than one repo, ask.
2. Pick the branch: the issue's git branch name from the issue tracker, or a short kebab-case name for a spec without an issue.
3. Run `git fetch origin`, then create the worktree at `<repo>/../<repo>.worktrees/<branch>`:
   - New branch: `git worktree add --no-track -b <branch> <path> origin/<default branch>`. `--no-track` keeps the new branch from tracking the default branch.
   - Branch exists already: `git worktree add <path> <branch>`. If it is checked out in another worktree, use that worktree.
   - If the work depends on a branch that is not merged yet, ask which base to use.
4. Copy the ignored local setup files from the main checkout into the worktree, for example `.java-version` or `.env`. List them with `git -C <repo> ls-files --others --ignored --exclude-standard --directory`, and skip build output and dependency folders.
5. Install what the build needs in the worktree (for example `yarn install`), before the first test run.

The worktree is done when `git -C <path> status` shows the branch, clean. Run every later command from the worktree path. Leave the worktree in place at the end.

## Build

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Commit to the worktree's branch as you go, in small commits: one per green tdd cycle, and one for each other step (a prefactor, wiring, a fix for a review finding). Each commit holds one step, so the history reads as the order the work was built in.

End with the worktree path, the branch, and the seams that `tdd` picked itself, if any. When another skill called this one, go back to it and continue its next step.
