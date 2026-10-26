---
name: implement
description: "Implement a piece of work based on a spec or set of issues."
disable-model-invocation: true
argument-hint: "<issue or spec> [--afk]"
---

Implement the work described by the user in the spec or issues.

If the user passes an issue reference, fetch it from the issue tracker and state its title before starting. If the reference is ambiguous, ask.

Once you have the issue, move it to the issue tracker's in-progress status. The issue tracker docs name that status. Assign it to the user only when the docs say issues have an assignee.

## --afk

With `--afk`, nobody watches the build. Ask nothing: where a step says to ask, take your own recommendation and go on. Stop only on a decision that is really the user's. Then write it in the issue's open question section, move the issue to the status for a stopped build, both as the issue tracker docs name them, and end. Without an issue, print the question and end.

Pass `--afk` on to `tdd` and `ready-for-review`.

## Clarify

With `--afk`, skip this step: the issue's `## Decisions` section holds the decisions. When the issue still has an open question section, its answer never reached the decisions: leave the section as it is, move the issue to the status for a stopped build, and end without building. The user answers it with prepare.

Call the Skill tool with "prepare" and the issue reference or spec, plus `--keep-status`. This step is done when prepare says nothing is open, or the user approved its decisions.

When a new open decision comes up later, during the build or the review, stop and call "prepare" again with the issue reference or spec, `--keep-status` and that decision. Build on the answer, never on a guess. With `--afk`, follow the `--afk` rule instead.

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

The worktree is done when `git -C <path> status` shows the branch, clean. Run every later command from the worktree path. Leave the worktree in place at the end and give the user its path.

## Build

Call the Skill tool with "tdd" where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Commit to the worktree's branch as you go, in small commits: one per green tdd cycle, and one for each other step (a prefactor, wiring, a fix from the review). Each commit holds one step, so the history reads as the order the work was built in.

## Review

With `--afk`, skip this step and the next one, and go to "Ready PR".

Once done, call the Skill tool with "review" and no arguments, from the worktree, to review its branch. On NO GO, fix each blocking finding in its own commit, then run "review" once more. Leave the suggestions for the user.

Judge each review finding by what the code will do in production, not by what the spec says. When a finding says the spec or the design itself is wrong, that is a new open decision: call "prepare" for it, as in Clarify.

## Draft PR

When the review says GO and no question to the user is open, call the Skill tool with "draft-pr" from the worktree, without asking. Give the user the PR link and the worktree path.

When the review still says NO GO after the second run, stop and show the user the blocking findings instead.

## Ready PR

Only with `--afk`:

1. When the branch already has a PR that is out of draft, put it back in draft: `gh pr ready --undo <num>`.
2. Call the Skill tool with "draft-pr" from the worktree. It opens the draft PR, or prints the existing one.
3. When `tdd` picked seams itself, add a `## Seams I chose` section to the PR description, one line per seam with what it catches.
4. Call the Skill tool with "ready-for-review", the PR number, the issue reference and `--afk`.
5. On NOT READY, the problems it lists are the open question: follow the `--afk` rule.

End with the PR link and the worktree path.
