---
name: merge
description: "Merge the PR of an approved issue with a rebase merge, close the issue with a result, and remove its worktree and branch. Use when the user says \"merge <issue>\" or \"merge the PR of <issue>\", or when another skill merges an approved issue."
argument-hint: "<issue> [--afk]"
---

Merge the PR of the issue in `$ARGUMENTS`, then close the issue and clean up. Merge never asks the user anything. A problem found before anything changed makes it **refuse**; a problem after it changed something makes it **stop**. `--afk` changes nothing; accept it so a calling skill can pass it to every worker.

To **refuse**: print why, change nothing, and end.

To **stop**: write what went wrong in the issue's open question section and move the issue to the status for a stopped build, both as the issue tracker docs name them. Then end. When the docs name no such section or status, print the problem, leave the status alone, and end.

## 1. Find the issue and its PR

Fetch the issue from the issue tracker and state its title. If the reference is ambiguous, **refuse**.

Find the issue's PR as the issue tracker docs say. When the docs say nothing about it, take the issue's repo and branch name from the issue tracker, as `implement` does, and the newest PR of that branch: `gh pr list -R <owner>/<repo> --head <branch name> --state all`. When there is no PR, **refuse**.

Read the PR once: `gh pr view <num> -R <owner>/<repo> --json number,title,url,state,isDraft,baseRefName,headRefName,headRefOid`. `<base>` is `baseRefName` and `<branch>` is `headRefName`.

Work in the repo's main checkout: the current repo when its `origin` points to `<owner>/<repo>`, or else a folder next to it whose `origin` does. When there is none, **refuse**. `<worktree>` is the worktree that has `<branch>` checked out (`git worktree list --porcelain`). When there is none, it is `<repo>/../<repo>.worktrees/<branch>`, where `implement` puts it.

Find the test command in the repo's README, `CLAUDE.md` or `AGENTS.md`. A repo without tests skips every test step below.

## 2. Check

When the PR is already merged, an earlier run broke off after the merge. Skip the checks below. Go on with step 4 when the issue is still in the approved status, or with step 6 when it moved on.

Otherwise, **refuse** when any of these is true:

- The issue is not in the status the issue tracker docs name for an approved PR. That status is the user's approval: a GitHub approval is not needed.
- The PR is closed without a merge, or it is a draft.
- A CI check failed or is still pending (`gh pr checks <num>`). No CI at all is fine.

## 3. Merge

Run `gh pr merge <num> --rebase --match-head-commit <headRefOid>`, so only the approved head gets merged. When GitHub accepts it, go to step 4.

When GitHub refuses it, read `gh pr view <num> --json mergeStateStatus`. GitHub computes it after a while: read it again every few seconds while it is `UNKNOWN`. When it is not `BEHIND` or `DIRTY`, a rebase can't help: **refuse** with GitHub's message. Otherwise rebase once, in `<worktree>`. When it is gone, run `git fetch origin` and create it: `git worktree add <worktree> <branch>` when the local branch exists, otherwise `git worktree add --no-track -b <branch> <worktree> origin/<branch>`. Copy the ignored setup files into it and install what the tests need, as `implement` does. Before the rebase, **refuse** when the worktree has uncommitted changes, or when its `HEAD` is not the PR's `headRefOid`. Only the code the user approved gets rebased.

1. `git fetch origin`, then `git rebase origin/<base>`. On a conflict: `git rebase --abort`, and **stop** with the files that conflict. Merge never fixes a conflict itself: a fix is new code the user did not review.
2. Run the tests on the branch. When they fail: reset the branch to `origin/<branch>`, and **stop** with the failing tests.
3. `git push --force-with-lease=<branch>:<headRefOid>`. When the repo has CI, wait until `gh pr view <num> --json headRefOid,statusCheckRollup` shows the new head commit with its checks started, then run `gh pr checks <num> --watch`. When it fails, **stop** with the failing checks.
4. Run `gh pr merge <num> --rebase --match-head-commit <new head>` again. When GitHub refuses it again, **stop** with its message.

## 4. Test the merged code

When the repo has no tests, go to step 5.

Run the tests on the merged code in a temporary worktree:

1. `git fetch origin`. Remove a leftover from an earlier run: `git worktree remove --force <repo>/../<repo>.worktrees/merged-<branch>`. Then `git worktree add --detach <repo>/../<repo>.worktrees/merged-<branch> origin/<base>`.
2. Copy the ignored setup files and install what the tests need, as `implement` does for its worktree.
3. Run the full test suite.
4. Remove the temporary worktree.

When the tests fail, keep the merge and revert nothing. Record the failing tests as a **stop** does, but go on with step 6 instead of ending.

## 5. Close the issue

Move the issue to the done status that the issue tracker docs name, and do what the docs say comes with it, such as moving issues it blocked.

When the docs name a result section, add it, for example:

```
## Result (2026-10-26)
Add the merge skill (PR #4). Last commit on main: a1b2c3d.
```

That is the PR title, the PR link, and the short SHA of the PR's last commit on `<base>`: `gh pr view <num> --json mergeCommit`. The rebase merge gave it a new SHA. When the repo has no tests, add "No tests in this repo."

## 6. Clean up

1. Remove the worktree and delete the local branch. Keep both when the worktree has uncommitted changes (`git status --porcelain`) or commits that are not on the PR (`git log <headRefOid>..<branch>`, with the last `headRefOid`). Delete the branch with `git branch -D`: the rebase merge gave its commits new SHAs, so `-d` refuses it.
2. Delete the branch on GitHub: `git push origin --delete <branch>`. When GitHub already deleted it, skip this.
3. In the main checkout: when it is on `<base>` and clean, run `git pull`. Otherwise run `git fetch origin`.

When you kept the worktree, say why and give its path.

End with the PR link, the status the issue is in now, and, after a stop, the problem.
