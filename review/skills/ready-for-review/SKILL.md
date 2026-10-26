---
name: ready-for-review
description: "Take one of your own PRs out of draft: run a full own-mode review, put the findings as a TODO checklist in the PR description, fix them one by one, and mark the PR ready once it is clean. Use whenever the user asks to take a PR out of draft or mark it ready for review, in any wording (\"PR out of draft\", \"make it ready\", \"undraft it\")."
argument-hint: "[PR number | PR link | empty] [issue] [--afk]"
---

Get the draft PR in `$ARGUMENTS` **clean**, then mark it ready for review. Clean means: the full `review` finds no blocking finding, and nothing about the PR's state on GitHub stops it. `../review/STEPS.md` (next to this skill's folder) holds the shared steps: read it first.

## --afk

With `--afk`, nobody watches. Ask nothing. Where step 6 says to stop and ask, do this instead:

- The fix needs a choice: take your own recommendation. When the choice is really the user's, as the spec or the issue leaves it to them, skip the item.
- The fix changes code outside the PR's files, or needs a new issue: fix a blocking item. Delete a suggestion from the list, and add it to a `## Skipped: your call` section in the PR description, outside the markers, with your recommendation.
- Merge conflicts: rebase onto `origin/<base>`, fix the conflicts, run the tests, and push with `git push --force-with-lease`. This is the only force-push. When a conflict needs a choice that is really the user's, skip it.
- Unpushed commits: push them.
- An open human thread with a DISMISS verdict: post a reply with the reason, and leave the thread open.
- An open human thread with a FIXED verdict: post a reply that names the commit that fixed it, and resolve the thread.
- Anything else, and every item that is still not fixed after you tried: skip it. Add a skipped suggestion to `## Skipped: your call`, with your recommendation.

A human thread with a FIX verdict is an item: once it is fixed, reply and resolve it, as for a bot thread. Start every reply you post with `🤖 `, so `review` knows it is the build's.

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

Run the `review` skill (`../review/SKILL.md`) on the PR, all checks, and print its report. The mode is **own**. When there are state problems from step 1, review the head commit in a worktree, as in step 2 of `STEPS.md`, so the review sees what is on GitHub.

Each blocking finding in the report is a **finding problem**. So is every thread in the report's **Threads** section with a FIX, NOT RESOLVED or NEW PROBLEM verdict. Findings that were dropped in verification don't count.

## 3. Check the PR state

After the review, collect every remaining state problem:

- CI: any check that failed, was cancelled, or is still pending (`gh pr checks`). No CI at all is fine.
- Merge conflicts: `gh pr view --json mergeable` is `CONFLICTING`.
- Unresolved review threads started by a human (`gh api graphql`, `pullRequest.reviewThreads`, `isResolved`). Bot threads are handled in step 5. With `--afk`, leave out the threads where the build has the last word.
- New commits: the head commit changed since step 1. The review checked older code.

## 4. Write the TODO list

When there is no problem and no suggestion, go to step 7.

Otherwise put a **TODO list** in the PR description, between two markers, after the rest of the body:

```
<!-- ready-for-review:todo -->
## TODO

### Blocking
- [ ] [bugs] `src/Order.kt:42` Empty cart returns null instead of 0.
- [ ] [CI] `unit-tests` fails on `OrderTest.emptyCart`.

### Suggestions
- [ ] [refactoring] `src/Order.kt:30` Extract the discount rule into `Discount.apply`.
<!-- /ready-for-review:todo -->
```

- **Blocking**: every finding problem, then every state problem.
- **Suggestions**: every suggestion from the review, most useful first.
- One line per item: the check or state, the location, one sentence.

Edit the body with `gh pr view <num> --json body`, then `gh pr edit <num> --body-file <file>`. Change only the text between the markers: the rest of the description is the user's. When the markers are already there, keep the items in it and add only problems that are not on the list yet.

## 5. Handle bot threads

A **bot** is a login that ends in `[bot]` or matches `copilot` (case-insensitive). For each open bot thread with a DISMISS verdict, post a **bot reply** and resolve the thread (see "Bot replies" below). A bot thread with a FIX verdict is already a TODO item: it gets its reply in step 6, once it is fixed.

## 6. Fix the items

Take the unticked items one by one, blocking first, then suggestions, in list order. For each item:

1. Decide if the fix is clear. **Stop and ask the user** when any of these is true, and wait for the answer:
   - The fix needs a choice that the spec, the code and the item don't make.
   - The fix needs something only the user can make, such as a screenshot or a video.
   - The thread's verdict is DISCUSS or CLARIFY.
   - The fix changes code outside the PR's files, or behavior the PR does not touch.
   - It is a state problem other than failing or pending CI: uncommitted changes, unpushed commits, merge conflicts, or an open human thread.
   - You tried and the item is still not fixed.

   Ask about one item per message, with the options you see. When the user says to skip an item, delete it from the list and note it as skipped.
2. Fix it. For a bug or a missing test: write the test first and see it fail, then fix the code. For failing CI: read the failing job's log (`gh run view <run-id> --log-failed`) and fix the cause. For pending CI: wait for it (`gh pr checks <num> --watch`). For a description finding: edit the description outside the markers, with no commit.
3. Run the tests that cover the change. They pass.
4. Commit only this item's change, with a message that says what it fixes. Push.
5. Tick the item in the PR description.
6. When the item came from a bot thread: post a bot reply and resolve the thread.

The loop is done when every item on the list is ticked.

Then wait for CI on the new head (`gh pr checks <num> --watch`), and go back to step 2: the code changed, so review it again. In this round and every later one, add only blocking items to the list, and keep new suggestions for the final output. Stop when a round finds no problem. With `--afk`, also stop when a round finds only problems you skipped before, and go to step 7. With `--afk`, nobody reads the final output: add the new suggestions of a later round to the list and fix them too, and put the suggestions of the last round in `## Skipped: your call`.

## 7. Decide

When a blocking item was skipped, leave the PR in draft and end with:

```
# NOT READY
- [<check or state>] <one sentence per problem>
```

List every problem left, findings first, then state problems.

When there is no problem left:

1. Remove the ticked items from the TODO list. Remove an empty `### Blocking` or `### Suggestions` heading. When no item is left, remove the whole list with its markers. The public description shows the change, not the fixes on the way.
2. Run `gh pr ready <num> -R <owner>/<repo>`.
3. When the PR belongs to an issue, move the issue to the review status that the issue tracker docs name. Take the issue from the arguments, or else find it in the branch name, the PR title or its body. In a public repo, issue numbers stay out of the branch and the PR, so only the arguments name the issue. With no issue or no such status, leave the tracker alone.
4. End with:

```
# READY
PR #<num> is out of draft: <url>
Fixed: <n> blocking, <n> suggestions · Skipped: <one line each, or: none>
New suggestions: <one line each, from rounds after the first, or: none>
```

## Bot replies

A bot reply says in one sentence what happened. A teammate who never saw the code understands it.

- Fixed: `Fixed in <short sha>: an empty cart now returns 0.`
- Dismissed: `Not changing this: the caller already filters out null ids (OrderService.kt:18).`

Before you post, check the reply with a cold read: start one `Agent` (general-purpose) and give it only the bot's comment and the reply. The brief: "Say in your own words what was decided and why. Say if you had to read the reply twice." Rewrite the reply when the reader got it wrong or read it twice. In step 5, check all the replies of that step in one agent.

Post the reply and resolve the thread with `gh api graphql`: `addPullRequestReviewThreadReply` with the thread's `id` and the body, then `resolveReviewThread` with the same `id`. A review body or a PR comment has no thread `id`: post the reply with `gh pr comment <num> -R <owner>/<repo> --body-file <file>`, and resolve nothing.
