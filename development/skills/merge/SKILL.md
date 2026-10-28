---
name: merge
description: "Merge the PR of an approved issue with a squash merge, or the method the repo allows, close the issue with a result, and remove its worktree and branch. Use when the user says \"merge <issue>\" or \"merge the PR of <issue>\", or when another skill merges an approved issue."
argument-hint: "<issue> [--afk]"
---

Merge the PR of the issue in `$ARGUMENTS`, then close the issue and clean up. Merge never asks the user anything. A problem found before anything changed makes it **refuse**; a problem after it changed something makes it **stop**. `--afk` changes nothing; accept it so a calling skill can pass it to every worker.

To **refuse**: print why, change nothing, and end.

UPPERCASE statuses, such as `APPROVED`, are factory statuses. The issue tracker docs map each one to a status of the tracker. When the docs map no status for a move, leave the issue where it is and say so at the end.

To **stop**: write what went wrong in the issue's open question section, as the issue tracker docs name it, and move the issue to `TO_CLARIFY`. When the docs map no `TO_CLARIFY`, the issue stays in its status: say that it needs a manual move. Then end. When the docs name no such section, print the problem, leave the status alone, and end.

## 1. Find the issue and its PR

Fetch the issue from the issue tracker and state its title. If the reference is ambiguous, **refuse**.

Find the issue's PR as the issue tracker docs say. When the docs say nothing about it, take the issue's repo and branch name from the issue tracker, as `implement` does, and the newest PR of that branch: `gh pr list -R <owner>/<repo> --head <branch name> --state all`. When there is no PR, **refuse**.

Read the PR once: `gh pr view <num> -R <owner>/<repo> --json number,title,url,state,isDraft,author,baseRefName,headRefName,headRefOid`. `<base>` is `baseRefName` and `<branch>` is `headRefName`.

Pick `<method>` from the merge methods the repo allows (`gh api repos/<owner>/<repo> -q '{squash: .allow_squash_merge, rebase: .allow_rebase_merge, merge: .allow_merge_commit}'`): `--squash` when it is allowed, otherwise `--rebase`, otherwise `--merge`.

Work in the repo's main checkout: the current repo when its `origin` points to `<owner>/<repo>`, or else a folder next to it whose `origin` does. When there is none, **refuse**. Run every later command in the main checkout or one of its worktrees, so `gh` finds the PR without `-R`. `<worktree>` is the worktree that has `<branch>` checked out (`git worktree list --porcelain`). When there is none, it is `<repo>/../<repo>.worktrees/<branch>`, where `implement` puts it.

Find the test command in the repo's README, `CLAUDE.md` or `AGENTS.md`. A repo without tests skips every test step below.

## 2. Check

When the issue tracker docs map no status to `APPROVED`, **refuse**: merge can't tell whether the user approved the PR.

When the PR is already merged, an earlier run broke off after the merge. Skip the checks below. Go on with step 4 when the issue is still in `APPROVED`, or with step 6 when it moved on.

Otherwise, **refuse** when any of these is true:

- The PR's author is not the user (`gh api user -q .login`). Merge only merges the user's own PRs.
- The issue is not in `APPROVED`. That status is the user's approval: a GitHub approval is not needed.
- The PR is closed without a merge, or it is a draft.
- A CI check failed or is still pending (`gh pr checks <num>`). No CI at all is fine.

## 3. Merge

Run `gh pr merge <num> <method> --match-head-commit <headRefOid>`, so only the approved head gets merged. When GitHub accepts it, go to step 4.

When GitHub refuses it, read `gh pr view <num> --json mergeStateStatus`. GitHub computes it after a while: read it again every few seconds while it is `UNKNOWN`. When it is not `BEHIND` or `DIRTY`, a rebase can't help: **refuse** with GitHub's message. Otherwise rebase once, in `<worktree>`. When it is gone, run `git fetch origin` and create it: `git worktree add <worktree> <branch>` when the local branch exists, otherwise `git worktree add --no-track -b <branch> <worktree> origin/<branch>`. Copy the ignored setup files into it and install what the tests need, as `implement` does. Before the rebase, **refuse** when the worktree has uncommitted changes, or when its `HEAD` is not the PR's `headRefOid`. Only the code the user approved gets rebased.

1. `git fetch origin`, then `git rebase origin/<base>`. On a conflict: `git rebase --abort`, and **stop** with the files that conflict. Merge never fixes a conflict itself: a fix is new code the user did not review.
2. Run the tests on the branch. When they fail: reset the branch to `origin/<branch>`, and **stop** with the failing tests.
3. `git push --force-with-lease=<branch>:<headRefOid> origin <branch>`. When the repo has CI, wait at most 10 minutes until `gh pr view <num> --json headRefOid,statusCheckRollup` shows the new head commit with its checks started. Then wait at most 60 minutes for them to finish: `gh pr checks <num> --watch`. When a limit runs out, **stop** with "no CI result for <sha>". When a check fails, **stop** with the failing checks.
4. Run `gh pr merge <num> <method> --match-head-commit <new head>` again. When GitHub refuses it again, **stop** with its message.

## 4. Test the merged code

When the repo has no tests, go to step 5.

Run the tests on the merged code in a temporary worktree:

1. `git fetch origin`. Remove a leftover from an earlier run: `git worktree remove --force <repo>/../<repo>.worktrees/merged-<branch>`. Then `git worktree add --detach <repo>/../<repo>.worktrees/merged-<branch> origin/<base>`.
2. Copy the ignored setup files and install what the tests need, as `implement` does for its worktree.
3. Run the full test suite.
4. Remove the temporary worktree.

When the tests fail, keep the merge and revert nothing. Go on with step 5: the code is on `<base>`, so the issue is done. Repairing `<base>` is new work.

## 5. Close the issue

Move the issue to `DONE`, and do what the docs say comes with it, such as moving issues it blocked.

When the docs name a result section, add it, for example:

```
## Result (2026-10-26)
Add the merge skill (https://github.com/acme/app/pull/4). Last commit on main: a1b2c3d.
```

That is the PR title, the PR link, and the short SHA of the PR's commit on `<base>`: `gh pr view <num> --json mergeCommit`. The merge gave it a new SHA. When the repo has no tests, add "No tests in this repo." When the tests failed on the merged code, add "Tests fail on <base> after the merge:" and the failing tests, and say at the end that `<base>` needs a fix.

## 6. Clean up

1. Remove the worktree and delete the local branch. Keep both when the worktree has uncommitted changes (`git status --porcelain`) or commits that are not on the PR (`git log <headRefOid>..<branch>`, with the last `headRefOid`). Delete the branch with `git branch -D`: the merge gave its commits new SHAs, so `-d` refuses it.
2. Delete the branch on GitHub: `git push origin --delete <branch>`. When GitHub already deleted it, skip this.
3. In the main checkout: when it is on `<base>` and clean, run `git pull`. Otherwise run `git fetch origin`.

When you kept the worktree, say why and give its path.

End with the PR link, the status the issue is in now, and, after a stop, the problem.
