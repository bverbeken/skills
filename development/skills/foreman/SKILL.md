---
name: foreman
description: "Do the next step for an issue, based on its status: prepare it, build it up to a PR that is ready for review, or handle new review threads. Or, without an issue, show the issues in the pipeline and mark the ones that wait on the user. Use when the user says \"foreman\", \"do the next thing\", \"next step for <issue>\", \"foreman, do the next thing on <issue>\", or \"foreman status\"."
argument-hint: "[issue | status] [--afk]"
---

Do the next step for the issue in `$ARGUMENTS`. The order of the steps lives only in this skill. Each worker skill does one step: call it with the Skill tool.

UPPERCASE statuses, such as `NEXT_UP`, are Foreman statuses. The issue tracker docs map each one to a status of the tracker.

Without `--afk`, do one step and end. With `--afk`, nobody watches: ask nothing, pass `--afk` on to `implement` and `ready-for-review`, and keep going until the issue waits on the user.

To **stop** with a problem: without `--afk`, show the user the problem and end. The issue stays in its status: say so, and say which status to move it to. With `--afk`, write the problem in the issue's open question section, as the issue tracker docs name it, move the issue to `TO_CLARIFY`, and end. When the docs name no such section, print the problem, leave the status alone, and end.

## 1. Check the mapping

Read the issue tracker docs. When they don't map all 9 Foreman statuses (`USEFUL`, `BLOCKED`, `TO_CLARIFY`, `NEXT_UP`, `BUSY`, `READY_FOR_REVIEW`, `READY_TO_MERGE`, `MERGED`, `DONE`), refuse: name the statuses that are missing, change nothing, and end.

The issue tracker docs also say which issues are **Foreman's**, for example by a field, a label or an assignee. When they don't say, every issue is Foreman's.

Show the [status](#status) instead of steps 2 to 4 when the first word of `$ARGUMENTS` is `status`, or when `$ARGUMENTS` names no issue and has no `--afk`. `--afk` changes nothing for `status`.

## 2. Pick the issue

With an issue reference, fetch the issue and state its title. If the reference is ambiguous, ask, or with `--afk`, end. Build the issue also when it is not Foreman's: the user named it.

Without one, with `--afk`, pick the issue closest to done:

1. `READY_FOR_REVIEW` with a new thread (see step 3)
2. `NEXT_UP`

Skip the issues that are not Foreman's (step 1). Within one status, order the issues as the board order in the tracker docs, or else oldest first, and take the first one. Say which issue you picked and why. When no issue has a step, say so, name what waits on the user, and end.

## 3. Run the step

| Status | Step |
|---|---|
| `TO_CLARIFY` | Without `--afk`: call "prepare" with the issue. With `--afk`: no step, the decisions are the user's. |
| `NEXT_UP` | Build, below. |
| `READY_FOR_REVIEW` | When the PR has a **new thread**: an unresolved review thread whose first comment and last comment both do not start with `🤖 `, unless the user wrote the last comment as an answer to a colleague: another person, not the build and not a bot. That thread waits on the colleague. To find the last comment, skip the bot comments that come after a `🤖 ` comment. A thread where only bots wrote after the build's reply is not new. Fetch the threads with the query in step 1 of `<this skill's folder>/../review/THREADS.md`, which also defines a bot. The build starts each comment it posts with `🤖 `. Then **open the PR's worktree**, below, and **ready the PR** from it. Otherwise: no step, the PR waits on its review. When the **user reviews**, say "review PR #n, and move it to `READY_TO_MERGE` when ok". Otherwise say "request a reviewer on PR #n, and move it to `READY_TO_MERGE` once they approve". |
| `READY_TO_MERGE` | No step: the user merges the PR on GitHub. Say "merge PR #n on GitHub". |
| `USEFUL` | No step: the issue is not planned yet. |
| `BLOCKED` | No step: name the issues in its blocked list that are not `MERGED` or `DONE`. |
| `BUSY` | When the issue tracker docs say issues have an assignee, and the issue is assigned to someone other than the user: no step, a teammate builds it. When the issue is **fresh**: build, below. When a PR is linked to it in the tracker, without `--afk`: ask "PR #n is linked. A build may still be running on it, on this machine or the Mac mini. Continue?", and go on only after a yes. When the PR is still in draft, **open the PR's worktree**, below, and **ready the PR** from it. When the PR is open and out of draft, move the issue to `READY_FOR_REVIEW`. When the PR is closed or merged, **stop** with its state. With `--afk`, or without a linked PR: no step, a build may still be running, or it broke off. To build it again, the user moves it back to `NEXT_UP`. |
| `MERGED` | No step. Say "do the docs, changelog and release, then move it to `DONE`". |
| `DONE` | No step: the issue is done. |

A `BUSY` issue is **fresh** when a person moved it there and no build has started: it is assigned to the user (when the issue tracker docs say issues have an assignee), no PR is linked to it in the tracker, and no branch with the issue's branch name exists, locally or on `origin`, in the repo the work belongs in. Pick that repo as `implement` does. When it could be more than one repo, ask, or with `--afk`, treat the issue as not fresh.

The **user reviews** when the issue tracker docs have a line that starts with `Reviewer: me`, after an optional list dash, for example `- Reviewer: me. Ben reviews his own PRs.`. A tracker with `Reviewer: team`, or without a `Reviewer:` line, waits on a reviewer the user requests.

When there is no step, change nothing. When `implement` stops, it writes its own question and moves the issue: end. When another worker ends without its normal result, for example `draft-pr` can't push, **stop** with its message.

### Build

1. Move the issue to `BUSY`. Assign it to the user only when the issue tracker docs say issues have an assignee.
2. Call "implement" with the issue. When it stops, end.
3. Call "review" with the branch that `implement` gives and the issue, from its worktree. On NO GO, call "implement" with the issue and the blocking findings, so it fixes each in its own commit. When it stops, end. Run "review" once: `ready-for-review` reviews the fixes.
4. When the branch already has a PR that is out of draft, put it back in draft: `gh pr ready --undo <num>`. Call "draft-pr" from the worktree, with the seams that `tdd` picked itself, if any.
5. Link the PR to the issue as the issue tracker docs say.
6. **Ready the PR**, below.

### Open the PR's worktree

Find the repo whose `origin` points to the PR's repo: the current repo, or else a folder next to it. When there is none, **stop**. Take its main worktree as `<repo>`, as step 1 of `Worktree` in `implement` does. Find the worktree that has the PR's branch checked out in `git worktree list --porcelain`, and run `git fetch origin`. When there is no such worktree, create it at `<repo>/../<repo>.worktrees/<branch>`: `git worktree add <path> <branch>` when the local branch exists, otherwise `git worktree add --no-track -b <branch> <path> origin/<branch>`. Copy the ignored setup files into it and install what the tests need, as `implement` does. When the branch is behind `origin/<branch>`, fast-forward it.

### Ready the PR

When the PR is out of draft, put it back in draft: `gh pr ready --undo <num>`. Call "ready-for-review" with the PR link and the issue. On NOT READY, **stop** with its problems.

## 4. Go on or end

Without `--afk`, end after the step. With `--afk`, read the issue's status again. When it has a step, go back to step 3 when the status changed and its step has not run yet in this run. Otherwise end: a step that left the status as it was, such as a refusal, does not run twice.

Every end of this skill, also a refusal or a stop, ends with the lines below. Only the [status](#status) ends in its own way.

- the issue and its status now;
- why you stopped there;
- the next step and who takes it. Say it plainly when it is the user's, for example "Request a reviewer on PR #12, and move ACME-123 to `READY_TO_MERGE` once they approve".

## Status

`/foreman status` shows the issues in the pipeline. It changes nothing: it moves no issue, calls no skill and changes no PR.

List every issue in `TO_CLARIFY`, `NEXT_UP`, `BUSY`, `READY_FOR_REVIEW`, `READY_TO_MERGE` and `MERGED`, grouped by status in that order. Leave out the other statuses. Within one status, use the order of step 2.

Give each issue one line: its id, its title, its PR link when it has one, and what moves it on. An issue that is not Foreman's (step 1) takes the first row of the table below in place of a row that waits on `foreman`, in the group of its own status. Mark the issues that wait on the user with `▶`.

| Status | Waits on | What moves it on |
|---|---|---|
| not Foreman's (step 1), where the row would wait on `foreman` | the user | run it yourself |
| `TO_CLARIFY` | the user | answer the open decisions, or the open question when the issue has one |
| `NEXT_UP` | `foreman` | run `/foreman <issue>` |
| `BUSY`, assigned to a teammate (step 3) | the teammate | nothing: a teammate builds it |
| `BUSY`, fresh (step 3) | `foreman` | run `/foreman <issue>` |
| `BUSY`, not fresh, with a PR link | the user | if no build is running on PR #<n>, run `/foreman <issue>` |
| `BUSY`, not fresh, without a PR link | `foreman` | what step 3 says for `BUSY` |
| `READY_FOR_REVIEW` with a new thread (step 3) | `foreman` | run `/foreman <issue>` |
| `READY_FOR_REVIEW` without a new thread, the user reviews (step 3) | the user | review PR #<n>, and move it to `READY_TO_MERGE` when ok; or, without a PR link: no PR linked |
| `READY_FOR_REVIEW` without a new thread, otherwise | the user | request a reviewer on PR #<n>, and move it to `READY_TO_MERGE` once they approve; or, without a PR link: no PR linked |
| `READY_TO_MERGE` | the user | merge PR #<n> on GitHub |
| `MERGED` | the user | do the docs, changelog and release, then move it to `DONE` |

End with one line that names the user's first action: the one on the first marked line. When no issue waits on the user, say so.

```
TO_CLARIFY
  ▶ ACME-22 Export to CSV: answer the open question
NEXT_UP
    ACME-18 Faster search: run /foreman ACME-18
  ▶ ACME-21 Rename the shared folder: run it yourself
READY_FOR_REVIEW
  ▶ ACME-17 Dark mode: request a reviewer on PR #10, and move it to `READY_TO_MERGE` once they approve
MERGED
  ▶ ACME-15 Export to PDF: do the docs, changelog and release, then move it to `DONE`

Next for you: answer the open question of ACME-22.
```
