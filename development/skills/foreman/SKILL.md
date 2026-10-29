---
name: foreman
description: "Do the next step for an issue, based on its status: prepare it, build it up to a PR that is ready for review, handle new review threads, or merge it. Or, without an issue, show the issues in the pipeline and mark the ones that wait on the user. Use when the user says \"foreman\", \"do the next thing\", \"next step for <issue>\", \"foreman, do the next thing on <issue>\", or \"foreman status\"."
argument-hint: "[issue | status] [--afk]"
---

Do the next step for the issue in `$ARGUMENTS`. The order of the steps lives only in this skill. Each worker skill does one step: call it with the Skill tool.

UPPERCASE statuses, such as `READY`, are factory statuses. The issue tracker docs map each one to a status of the tracker.

Without `--afk`, do one step and end. With `--afk`, nobody watches: ask nothing, pass `--afk` on to `implement`, `ready-for-review` and `merge`, and keep going until the issue waits on the user.

To **stop** with a problem: without `--afk`, show the user the problem and end. The issue stays in its status: say so, and say which status to move it to. With `--afk`, write the problem in the issue's open question section, as the issue tracker docs name it, move the issue to `TO_CLARIFY`, and end. When the docs name no such section, print the problem, leave the status alone, and end.

## 1. Check the mapping

Read the issue tracker docs. When they don't map all 8 factory statuses (`BACKLOG`, `BLOCKED`, `TO_CLARIFY`, `READY`, `BUSY`, `REVIEW`, `APPROVED`, `DONE`), refuse: name the statuses that are missing, change nothing, and end.

Show the [status](#status) instead of steps 2 to 4 when the first word of `$ARGUMENTS` is `status`, or when `$ARGUMENTS` names no issue and has no `--afk`. `--afk` changes nothing for `status`.

## 2. Pick the issue

With an issue reference, fetch the issue and state its title. If the reference is ambiguous, ask, or with `--afk`, end.

Without one, with `--afk`, pick the issue closest to done:

1. `APPROVED`
2. `REVIEW` with a new thread (see step 3)
3. `READY`

Within one status, order the issues as the board order in the tracker docs, or else oldest first, and take the first one. Say which issue you picked and why. When no issue has a step, say so, name what waits on the user, and end.

## 3. Run the step

| Status | Step |
|---|---|
| `TO_CLARIFY` | Without `--afk`: call "prepare" with the issue. With `--afk`: no step, the decisions are the user's. |
| `READY` | Build, below. |
| `REVIEW` | When the PR has a **new thread**: an unresolved review thread whose first comment and last comment both do not start with `🤖 `, unless the user wrote the last comment as an answer to a colleague: another person, not the build and not a bot. That thread waits on the colleague. To find the last comment, skip the bot comments that come after a `🤖 ` comment. A thread where only bots wrote after the build's reply is not new. Fetch the threads with the query in step 1 of `<this skill's folder>/../review/THREADS.md`, which also defines a bot. The build starts each comment it posts with `🤖 `. Then find the repo's main checkout and the worktree that has the PR's branch checked out, as `merge` step 1 does, and run `git fetch origin`. When there is no such worktree, create it at `<repo>/../<repo>.worktrees/<branch>`: `git worktree add <path> <branch>` when the local branch exists, otherwise `git worktree add --no-track -b <branch> <path> origin/<branch>`. Copy the ignored setup files into it and install what the tests need, as `implement` does. When the branch is behind `origin/<branch>`, fast-forward it. Then **ready the PR** from that worktree, below. Otherwise: no step, the PR waits on a reviewer: the user requests one and moves the issue to `APPROVED` once they approve. |
| `APPROVED` | Call "merge" with the issue. |
| `BACKLOG` | No step: the issue is not planned yet. |
| `BLOCKED` | No step: name the issues in its blocked list that are not `DONE`. |
| `BUSY` | When the issue is **fresh**: build, below. Otherwise no step: a build may still be running, or it broke off. To build it again, the user moves it back to `READY`. |
| `DONE` | No step: the issue is merged. |

A `BUSY` issue is **fresh** when a person moved it there and no build has started: it is assigned to the user (when the issue tracker docs say issues have an assignee), no PR is linked to it in the tracker, and no branch with the issue's branch name exists, locally or on `origin`, in the repo the work belongs in. Pick that repo as `implement` does. When it could be more than one repo, ask, or with `--afk`, treat the issue as not fresh.

When there is no step, change nothing. When `implement` or `merge` stops, it writes its own question and moves the issue: end. When another worker ends without its normal result, for example `draft-pr` can't push, **stop** with its message.

### Build

1. Move the issue to `BUSY`. Assign it to the user only when the issue tracker docs say issues have an assignee.
2. Call "implement" with the issue. When it stops, end.
3. Call "review" with the branch that `implement` gives and the issue, from its worktree. On NO GO, call "implement" with the issue and the blocking findings, so it fixes each in its own commit. When it stops, end. Run "review" once: `ready-for-review` reviews the fixes.
4. When the branch already has a PR that is out of draft, put it back in draft: `gh pr ready --undo <num>`. Call "draft-pr" from the worktree, with the seams that `tdd` picked itself, if any.
5. Link the PR to the issue as the issue tracker docs say.
6. **Ready the PR**, below.

### Ready the PR

When the PR is out of draft, put it back in draft: `gh pr ready --undo <num>`. Call "ready-for-review" with the PR link and the issue. On NOT READY, **stop** with its problems.

## 4. Go on or end

Without `--afk`, end after the step. With `--afk`, read the issue's status again. When it has a step, go back to step 3 when the status changed and its step has not run yet in this run. Otherwise end: a step that left the status as it was, such as a refusal, does not run twice.

Every end of this skill, also a refusal or a stop, ends with the lines below. Only the [status](#status) ends in its own way.

- the issue and its status now;
- why you stopped there;
- the next step and who takes it. Say it plainly when it is the user's, for example "Request a reviewer on PR #12, and move ACME-123 to `APPROVED` once they approve".

## Status

`/foreman status` shows the issues in the pipeline. It changes nothing: it moves no issue, calls no skill and changes no PR.

List every issue in `TO_CLARIFY`, `READY`, `BUSY`, `REVIEW` and `APPROVED`, grouped by status in that order. Leave out the other statuses. Within one status, use the order of step 2.

Give each issue one line: its id, its title, its PR link when it has one, and what moves it on. Mark the issues that wait on the user with `▶`.

| Status | Waits on | What moves it on |
|---|---|---|
| `TO_CLARIFY` | the user | answer the open decisions, or the open question when the issue has one |
| `READY` | `foreman` | run `/foreman <issue>` |
| `BUSY`, fresh (step 3) | `foreman` | run `/foreman <issue>` |
| `BUSY`, not fresh | `foreman` | what step 3 says for `BUSY` |
| `REVIEW` with a new thread (step 3) | `foreman` | run `/foreman <issue>` |
| `REVIEW` without a new thread | the user | request a reviewer on PR #<n>, and move it to `APPROVED` once they approve; or, without a PR link: no PR linked |
| `APPROVED` | `foreman` | run `/foreman <issue>` |

End with one line that names the user's first action: the one on the first marked line. When no issue waits on the user, say so.

```
TO_CLARIFY
  ▶ ACME-22 Export to CSV: answer the open question
READY
    ACME-18 Faster search: run /foreman ACME-18
REVIEW
  ▶ ACME-17 Dark mode: request a reviewer on PR #10, and move it to `APPROVED` once they approve

Next for you: answer the open question of ACME-22.
```
