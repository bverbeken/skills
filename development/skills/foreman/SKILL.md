---
name: foreman
description: "Do the next step for an issue, based on its status: prepare it, build it up to a PR that is ready for review, handle new review threads, or merge it. Use when the user says \"foreman\", \"do the next thing\", \"next step for <issue>\", or \"foreman, do the next thing on <issue>\"."
argument-hint: "[issue] [--afk]"
---

Do the next step for the issue in `$ARGUMENTS`. The order of the steps lives only in this skill. Each worker skill does one step: call it with the Skill tool.

UPPERCASE statuses, such as `READY`, are factory statuses. The issue tracker docs map each one to a status of the tracker.

Without `--afk`, do one step and end. With `--afk`, nobody watches: ask nothing, pass `--afk` on to `implement`, `ready-for-review` and `merge`, and keep going until the issue waits on the user.

To **stop** with a problem: without `--afk`, show the user the problem and end. The issue stays in its status: say so, and say which status to move it to. With `--afk`, write the problem in the issue's open question section, as the issue tracker docs name it, move the issue to `TO_CLARIFY`, and end. When the docs name no such section, print the problem, leave the status alone, and end.

## 1. Check the mapping

Read the issue tracker docs. When they don't map all 8 factory statuses (`BACKLOG`, `BLOCKED`, `TO_CLARIFY`, `READY`, `BUSY`, `REVIEW`, `APPROVED`, `DONE`), refuse: name the statuses that are missing, change nothing, and end.

## 2. Pick the issue

With an issue reference, fetch the issue and state its title. If the reference is ambiguous, ask, or with `--afk`, end.

Without one, pick the issue closest to done:

1. `APPROVED`
2. `REVIEW` with a new thread (see step 3)
3. `READY`
4. `TO_CLARIFY`, only without `--afk`

Within one status, follow the board order the tracker docs give, or else take the oldest issue. Say which issue you picked and why. When no issue has a step, say so, name what waits on the user, and end.

## 3. Run the step

| Status | Step |
|---|---|
| `TO_CLARIFY` | Without `--afk`: call "prepare" with the issue. With `--afk`: no step, the decisions are the user's. |
| `READY` | Build, below. |
| `REVIEW` | When the PR has a **new thread**: an open review thread that a human started, where neither the build (its replies start with `🤖 `) nor the user has the last word. Then put the PR back in draft (`gh pr ready --undo <num>`), then call "ready-for-review" with the PR number and the issue. On NOT READY, **stop** with its problems. Otherwise: no step, the PR waits on the user's review. |
| `APPROVED` | Call "merge" with the issue. |
| `BACKLOG` | No step: the issue is not planned yet. |
| `BLOCKED` | No step: name the issues in its blocked list that are not `DONE`. |
| `BUSY` | No step: a build may still be running, or it broke off. Move the issue back to `READY` to build it again. |
| `DONE` | No step: the issue is merged. |

When there is no step, change nothing. When a worker stops, it writes its own question and moves the issue: end.

### Build

1. Move the issue to `BUSY`. Assign it to the user only when the issue tracker docs say issues have an assignee.
2. Call "implement" with the issue. When it stops, end.
3. Call "review" with the branch that `implement` gives and the issue, from its worktree. On NO GO, call "implement" with the issue and the blocking findings, so it fixes each in its own commit, then call "review" once more. Run "review" at most twice.
4. When the second run still says NO GO, **stop** with the blocking findings.
5. When the branch already has a PR that is out of draft, put it back in draft: `gh pr ready --undo <num>`. Call "draft-pr" from the worktree, with the seams that `tdd` picked itself, if any.
6. Link the PR to the issue as the issue tracker docs say.
7. Call "ready-for-review" with the PR number and the issue. On NOT READY, **stop** with its problems.

## 4. Go on or end

Without `--afk`, end after the step. With `--afk`, read the issue's status again. When it has a step, go back to step 3, but run the `REVIEW` step at most once per run. Otherwise end.

Every end of this skill, also a refusal or a stop, ends with:

- the issue and its status now;
- why you stopped there;
- the next step and who takes it. Say it plainly when it is the user's, for example "Review PR #12, then move ACME-123 to `APPROVED`".
