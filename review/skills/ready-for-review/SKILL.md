---
name: ready-for-review
description: "Take one of your own PRs out of draft: run an own-mode review, put the findings as a TODO checklist in the PR description, fix them one by one, and mark the PR ready once it is clean. Use whenever the user asks to take a PR out of draft or mark it ready for review, in any wording (\"PR out of draft\", \"make it ready\", \"undraft it\")."
argument-hint: "[PR number | PR link | empty] [issue] [--afk]"
---

Get the draft PR in `$ARGUMENTS` **clean**, then mark it ready for review. Clean means: `review` without `--only` finds no blocking finding, and nothing about the PR's state on GitHub stops it. `../review/STEPS.md` (next to this skill's folder) holds the shared steps: read it first.

## --afk

With `--afk`, nobody watches. Ask nothing. Where step 6 says to stop and ask, do this instead:

- The fix would change or bend a line in the issue's `## Decisions` section: skip the item. That line is the user's call. This rule wins over the others below.
- The fix needs a choice: take your own recommendation. When the choice is really the user's, as the spec or the issue leaves it to them, skip the item.
- The fix changes code outside the PR's files, or needs a new issue: fix a blocking item, skip a suggestion.
- Merge conflicts: rebase onto `origin/<base>`, fix the conflicts, run the tests, and push with `git push --force-with-lease`. This is the only force-push. When a conflict needs a choice that is really the user's, skip it.
- Unpushed commits: push them.
- An open human thread with a DISMISS verdict: post a reply with the reason, and leave the thread open.
- An open human thread with a FIXED verdict: post a reply that names the commit that fixed it, and resolve the thread.
- Anything else, and every item that is still not fixed after you tried: skip it.

To skip an item, delete it from the list. When the item comes from an open thread, post a **skip reply** on it. A skipped blocking item goes in the NOT READY output of step 7. A skipped suggestion goes in a `## Skipped: your call` section in the PR description, outside the markers, with your recommendation.

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

Run the `review` skill (`../review/SKILL.md`) on the PR, with the issue from the arguments if there is one, without `--only`, and print its report. The mode is **own**. When there are state problems from step 1, review the head commit in a worktree, as in step 2 of `STEPS.md`, so the review sees what is on GitHub. Start the agents as `review` says.

Each blocking finding in the report is a **finding problem**. So is every thread in the report's **Threads** section with a FIX, NOT RESOLVED or NEW PROBLEM verdict, and every human thread with a DISCUSS or CLARIFY verdict that you have not answered. Findings that were dropped in verification don't count.

## 3. Check the PR state

After the review, collect every remaining state problem:

- CI: any check that failed, was cancelled, or is still pending (`gh pr checks`). No CI at all is fine.
- Merge conflicts: `gh pr view --json mergeable` is `CONFLICTING`.
- Unresolved review threads started by a human (`gh api graphql`, `pullRequest.reviewThreads`, `isResolved`). Bot threads are handled in step 5. With `--afk`, leave out the threads that are not **new**. A new thread is an unresolved review thread whose first comment and last comment both do not start with `🤖 `, unless the user wrote the last comment as an answer to a colleague: another person, not the build and not a bot.
- New commits: the head commit is not the one this round's review checked. The review checked older code.

A **round** is one pass through steps 2 and 3. After step 3, check whether the review loop ends:

- A round after the first finds no problem: go to step 7.
- With `--afk`, a round finds only problems you skipped before: go to step 7.
- This is the 5th round with blocking items (finding problems or state problems): stop the review loop.
- A blocking finding came back that you fixed in an earlier round: the same check and the same problem in the same place, in any wording. Example: round 2 fixed "[bugs] `Order.kt:42` empty cart returns null", and round 4 reports "[bugs] `Order.kt:44` an empty cart gives null instead of 0". Only findings you fixed yourself count. Stop the review loop.

When the review loop stops, fix nothing more. Write the TODO list as step 4 says, with the blocking items of this round, and untick the item of a finding that came back. Post a **skip reply** on each open thread among those items. Then go to step 7: those items stay open.

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

A **bot** is a login that ends in `[bot]` or matches `copilot` (case-insensitive). Answer every open bot thread, so none of them stays new:

- DISMISS: post a **bot reply** and resolve the thread (see "Bot replies" below).
- FIXED: post a bot reply that names the commit that fixed it, and resolve the thread.
- DISCUSS or CLARIFY: post a **skip reply** and leave the thread open (see "Skip replies" below).

A bot thread with a FIX verdict is already a TODO item: it gets its reply in step 6, once it is fixed.

## 6. Fix the items

Take the unticked items one by one, blocking first, then suggestions, in list order. For each item:

1. Decide if the fix is clear. **Stop and ask the user** when any of these is true, and wait for the answer:
   - The fix needs a choice that the spec, the code and the item don't make.
   - The fix would change or bend a line in the issue's `## Decisions` section.
   - The fix needs something only the user can make, such as a video, or a screenshot that `SCREENSHOTS.md` leaves to the user.
   - The thread's verdict is DISCUSS or CLARIFY.
   - The fix changes code outside the PR's files, or behavior the PR does not touch.
   - It is a state problem other than failing or pending CI: uncommitted changes, unpushed commits, merge conflicts, or an open human thread.
   - You tried and the item is still not fixed.

   Ask about one item per message, with the options you see. When the user says to skip an item, delete it from the list, note it as skipped, and post a **skip reply** when it comes from an open thread.
2. Fix it. For a bug or a missing test: write the test first and see it fail, then fix the code. For failing CI: read the failing job's log (`gh run view <run-id> --log-failed`) and fix the cause. For pending CI: wait for it (`gh pr checks <num> --watch`). For a description finding: edit the description outside the markers, with no commit. For a screenshot finding: make and upload the images as `SCREENSHOTS.md` in this skill's folder says.
3. Run the tests that cover the change. They pass.
4. Commit only this item's change, with a message that says what it fixes. Push.
5. Tick the item in the PR description.
6. When the item came from a bot thread: post a bot reply and resolve the thread.

The loop is done when every item on the list is ticked.

Then wait for CI on the new head (`gh pr checks <num> --watch`), and go back to step 2: the code changed, so review it again. In this round and every later one, add only blocking items to the list, and keep new suggestions for the final output. With `--afk`, nobody reads the final output: add the new suggestions of a later round to the list and fix them too.

## 7. Decide

First run step 5 for every open bot thread that has no `🤖 ` reply yet: a round without problems comes here without step 5.

With `--afk`, then put the suggestions of the last round that you did not fix in `## Skipped: your call`.

When a blocking item was skipped, or the review loop stopped with blocking items open, leave the PR in draft and end with:

```
# NOT READY
- [<check or state>] <one sentence per problem; for a change to a decision: the decision line, the fact found, the question, and your recommendation>
```

List every problem left, findings first, then state problems.

When there is no problem left:

1. Remove the ticked items from the TODO list. Remove an empty `### Blocking` or `### Suggestions` heading. When no item is left, remove the whole list with its markers. The public description shows the change, not the fixes on the way.
2. Run `gh pr ready <num> -R <owner>/<repo>`.
3. When the PR belongs to an issue, move the issue to `REVIEW`, the factory status that the issue tracker docs map to a status of the tracker. Take the issue from the arguments, or else find it in the branch name, the PR title or its body. In a public repo, issue numbers stay out of the branch and the PR, so only the arguments name the issue. With no issue, leave the tracker alone. When the docs map no status to `REVIEW`, leave the issue where it is and say so at the end.
4. End with:

```
# READY
PR #<num> is out of draft: <url>
Fixed: <n> blocking, <n> suggestions · Skipped: <one line each, or: none>
New suggestions: <one line each, from rounds after the first, or: none>
Tracker: <issue> moved to `REVIEW`, or: the tracker has no `REVIEW`, <issue> stays <status>, or: no issue
```

## Skip replies

A skip reply tells a thread that its decision is the user's: `🤖 <url> Skipped: this one is your call.` Post it as the last paragraph of "Bot replies" says, but leave the thread open. Post one per thread, also when more than one item comes from it.

## Bot replies

A bot reply says in one sentence what happened. A teammate who never saw the code understands it.

- Fixed: `Fixed in <short sha>: an empty cart now returns 0.`
- Dismissed: `Not changing this: the caller already filters out null ids (OrderService.kt:18).`

Before you post, check the reply with a cold read: start one `Agent` (general-purpose) and give it only the bot's comment and the reply. The brief: "Say in your own words what was decided and why. Say if you had to read the reply twice." Rewrite the reply when the reader got it wrong or read it twice. In step 5, check all the replies of that step in one agent.

Post the reply and resolve the thread with `gh api graphql`: `addPullRequestReviewThreadReply` with the thread's `id` and the body, then `resolveReviewThread` with the same `id`. A review body or a PR comment has no thread `id`: post the reply with `gh pr comment <num> -R <owner>/<repo> --body-file <file>`, and resolve nothing. Put the URL of the comment you answer right after the `🤖 ` marker, so `review` joins the reply to it.
