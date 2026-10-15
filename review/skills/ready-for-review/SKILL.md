---
name: ready-for-review
description: "Take one of your own draft PRs out of draft, but only after a full strict review finds nothing but nits: no blocking finding, no suggestion beyond a nit, green CI, no conflicts."
argument-hint: "[PR number | PR link | empty]"
---

Mark the draft PR in `$ARGUMENTS` ready for review, only when it is **clean**. Clean means: the full `review` finds nothing but **nits** (see step 4), and nothing about the PR's state on GitHub stops it. `../review/STEPS.md` (next to this skill's folder) holds the shared steps: read it first.

## 1. Check the PR

Run step 1 of `STEPS.md`. An empty argument means the open PR of the current branch. Then stop and say why when any of these is true:

- There is no PR.
- The PR's author is not the user (`gh api user -q .login`). This skill only works on the user's own PRs.
- The PR is not open, or it is not a draft.

Note the PR's head commit: `gh pr view <num> -R <owner>/<repo> --json headRefOid -q .headRefOid`.

When the PR's branch is checked out locally, compare it with GitHub. Each difference is a **state problem** (see step 3):

- Uncommitted changes: `git status --porcelain` shows anything.
- Local commits that are not pushed: local `HEAD` is not the head commit.

## 2. Review

Run the `review` skill (`../review/SKILL.md`) on the PR, all checks, and print its report. The mode is **own (strict)**. When there are state problems from step 1, review the head commit in a worktree, as in step 2 of `STEPS.md`, so the review sees what is on GitHub.

Each blocking finding in the report is a **finding problem**. Each suggestion is a finding problem too, unless it is a nit (see step 4). So is every thread in the report's **Threads** section with a FIX, NOT RESOLVED or NEW PROBLEM verdict. Findings that were dropped in verification don't count.

## 3. Check the PR state

After the review, collect every remaining state problem:

- CI: any check that failed, was cancelled, or is still pending (`gh pr checks`). No CI at all is fine.
- Merge conflicts: `gh pr view --json mergeable` is `CONFLICTING`.
- Unresolved review threads, from bots or from people (`gh api graphql`, `pullRequest.reviewThreads`, `isResolved`).
- New commits: the head commit changed since step 1. The review checked older code.

## 4. Decide

When there is any finding problem or state problem, leave the PR in draft and end with:

```
# NOT READY
- [<check or state>] <one sentence per problem>
```

List every problem, findings first, then state problems. The user wants a clean PR, so every suggestion that is not a nit counts as much as a blocking finding.

A **nit** is a suggestion that passes all three tests:

- Fixing it changes nothing in production: no behavior, no data, no query, no API text, no config.
- Fixing it changes no test outcome, and leaving it cannot hide a bug.
- The fix is a few lines in one place.

| Suggestion | Nit? |
|---|---|
| The same one-line expression appears in two tests | yes |
| A log message could be worded better | yes |
| A test hard-codes a value that production reads from a constant | no: the test can drift from production |
| A config value is not validated | no: it changes behavior |
| A query costs more than needed | no |
| The API description could be clearer | no: a user reads it |

When you are not sure, it is not a nit.

When there is no problem, run `gh pr ready <num> -R <owner>/<repo>` and end with:

```
# READY
PR #<num> is out of draft: <url>
Nits left: <one line per nit, or: none>
```

`gh pr ready` is the only change this skill makes on GitHub. It posts no comments and changes no code.
