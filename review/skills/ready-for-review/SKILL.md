---
name: ready-for-review
description: "Take one of your own PRs out of draft: run an own-mode review, put the findings as a TODO checklist in the PR description, fix them one by one, and mark the PR ready once it is clean. Use whenever the user asks to take a PR out of draft or mark it ready for review, in any wording (\"PR out of draft\", \"make it ready\", \"undraft it\")."
argument-hint: "[PR number | PR link | empty] [issue]"
---

Get the draft PR in `$ARGUMENTS` **clean**, then mark it ready for review. Clean means: the last round's review finds no blocking finding, and nothing about the PR's state on GitHub stops it. `../review/STEPS.md` (next to this skill's folder) holds the shared steps: read it first.

## Solo project

A project is **solo** when the issue tracker docs have a line that starts with `Reviewer: me`, after an optional list dash. `Reviewer: team`, no line or no docs is a team project, and this section does not apply. On a solo project, these rules replace the matching parts of the steps below:

- **One review pass, in step 2.** Run the first of these that fits, and no review it does not name:
  1. The PR has an open human thread or an answered bot thread that step 3 does not leave out, or an unanswered bot thread (step 3) when the PR was out of draft before (its timeline has a `ready_for_review` event): run `review --only threads`, and keep the findings of a report that rule 2 accepts.
  2. This session has a report that the first round of step 2 would accept, or a light report that meets the same conditions, and its `Head:` line is the head commit from step 1: keep its findings, blocking and suggestions alike. When the PR has an unanswered bot thread (step 3), also run `review --only threads`, as a report made before the PR existed has no verdict for it.
  3. Otherwise: run `review --light`.
- **No description check.** `review --only description` does not run. The cold read in `draft-pr` is enough.
- **Suggestions, in step 6.** Apply each one in its own commit, and the tests must pass. A suggestion that changes code outside the PR's files stays open: delete it from the list.
- **A look at fixes, in step 6.** A one-line fix, a test or a refactoring needs no further look. Any other fix that adds a branch, an error path or a change in behavior gets one read, after its commit. Start one `Agent` (general-purpose) with the finding and the commit's diff, and this brief: "Read this fix. Does it introduce a bug? Name the case that fails, or answer `none`." Fix what it finds in its own commit, without another look.
- **One round, in steps 3 and 6.** A commit this run made is not a state problem. When every item is ticked and an unanswered bot thread has no verdict from this run, run `review --only threads` for it, and add a FIX verdict to the TODO list as a step 6 item. When that list is done too, wait for CI on the new head (`gh pr checks <num> --watch`). Fix a check that fails, as a step 6 item, and wait for CI on that head too. `gh pr checks` exits with `no checks reported` until GitHub registers the checks of a new head. When the head before had checks, retry for up to 2 minutes, and count a head that still has none as pending CI. Then run step 3 once more for the state of the PR, and go to step 7, not back to step 2. A state problem still left then counts as a skipped blocking item, so it goes in the NOT READY output of step 7.

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

In the first round, first look in this session for the last report of `review` on this PR or its branch, without `--only`, with `mode: own`. A report of a check run alone, of `review --only`, of `review --since`, of `review --light`, or of an earlier reuse round does not count: it does not cover the whole PR. Nor does a report whose `Head:` line has `+ uncommitted changes`: it covers more than the commit. Take its `Head:` line:

- It is the head commit from step 1: reuse the report. Keep its findings from the code checks, blocking and suggestions alike, and run `review` with `--only description` instead of the full review. That runs the cold read, the PR material check and the thread check of `THREADS.md`. This round's report is the kept findings plus that report. Example: `implement` reviewed `a1b2c3d` and `draft-pr` pushed it unchanged, so the first round reuses that review.
- It is an ancestor of the head commit (`git merge-base --is-ancestor <sha> <head commit>`): run `review` with `--since <sha>`, so it reviews only the commits that came after. Keep the suggestions of the earlier report that this session has not fixed yet. One that an earlier run skipped stays an open suggestion. **Verify again** its blocking findings. This round's report is the kept suggestions, the blocking findings that are still in the code, and the new report. Example: `review` gave NO GO on `a1b2c3d`, and `implement` fixed it in `e4f5a6b`, so the first round reviews only the fix, and checks that the finding is gone.
- Otherwise, or without such a report: run the full review.

To **verify again** a list of findings, start one `Agent` (general-purpose) per finding, all in one message, once `review` has written `<contextFile>`. A `--since` review only reports on the changed lines, so a fix that missed its finding would go unseen. Verify again every finding of the code checks, and the threads that a commit fixed. Step 3 checks state items, such as CI, again by itself, and `review-description` reads the PR body again in every round. Give each agent `<contextFile>`, its finding and this brief: "Read the code at the head commit with `git -C <repoRoot> show <head commit>:<path>`. Is this finding still in the code? Answer `NOT FIXED` when you can quote the code that still has the problem. For a finding about something missing, such as a test or a spec requirement, answer `FIXED` only when you can quote the code that now adds it, and `NOT FIXED` otherwise. In all other cases answer `FIXED`. Add one sentence why." A NOT FIXED finding stays blocking. A FIXED one is gone.

Every later round runs `review` with `--since` and the `Head:` line of the round before, so it reviews only the fixes of that round, and **verifies again** the blocking items that the round before fixed with a commit. An item verified again as NOT FIXED is a blocking finding that came back, as step 3 says. After the first round, no round runs the full review. Read the PR's head commit again first (`gh pr view <num> -R <owner>/<repo> --json headRefOid -q .headRefOid`), and fetch it (`git fetch origin pull/<num>/head`): the one from step 1 is old by now, and someone may have pushed it from elsewhere, for example with GitHub's "Update branch". When `git merge-base --is-ancestor` exits with 1, that `Head:` is not an ancestor of the new head commit, and someone rewrote the branch during the loop: stop the review loop, as step 3 says, with `[state] the branch was rewritten during the review loop` as a blocking item. When it exits with another error, git doesn't know one of the two commits: fetch again and run the check once more.

Each blocking finding in the report is a **finding problem**. So is every thread in the report's **Threads** section with a FIX, NOT RESOLVED or NEW PROBLEM verdict, and every human thread with a DISCUSS or CLARIFY verdict that you have not answered. Findings that were dropped in verification don't count.

## 3. Check the PR state

After the review, collect every remaining state problem:

- CI: any check that failed, was cancelled, or is still pending (`gh pr checks`). No CI at all is fine.
- Merge conflicts: `gh pr view --json mergeable` is `CONFLICTING`.
- Unresolved review threads started by a human (the query in step 1 of `../review/THREADS.md`, `isResolved`). An open bot thread where a person wrote is an **answered bot thread**. It counts as a human thread in every step: do what the last answer of a person asks. An open bot thread where no person wrote is an **unanswered bot thread**: step 5 handles it. Step 1 of `../review/THREADS.md` defines the **skip reply** and a **skipped bot thread**. Leave out, in every step, the skipped bot threads, the review threads that step 1 of `../review/THREADS.md` skips because of a `PENDING` review, the threads where the user's last comment answers a colleague, as they wait on the colleague, and the threads the user said to skip in this run. One exception: a skipped bot thread that a finding names (`Also raised by`) gets a bot reply in step 6, once that finding is fixed.
- New commits: the head commit is not the one this round's review checked. The review checked older code.

A **round** is one pass through steps 2 and 3. After step 3, check whether the review loop ends:

- A round after the first finds no problem: go to step 7.
- A round finds only problems the user said to skip: go to step 7.
- This is the 5th round with blocking items (finding problems or state problems): stop the review loop.
- A blocking finding came back that you fixed in an earlier round: the same check and the same problem in the same place, in any wording. Example: round 2 fixed "[bugs] `Order.kt:42` empty cart returns null", and round 4 reports "[bugs] `Order.kt:44` an empty cart gives null instead of 0". Only findings you fixed yourself count. Stop the review loop.

When the review loop stops, fix nothing more. Write the TODO list as step 4 says, with the blocking items of this round, and untick the item of a finding that came back. Then go to step 7: those items stay open.

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
- One line per item: the check or state, the location, one sentence. A finding that names a bot thread keeps its `Also raised by` sentence (step 4 of `../review/THREADS.md`).

Edit the body with `gh pr view <num> --json body`, then `gh pr edit <num> --body-file <file>`. Change only the text between the markers, the `## Open suggestions` section and the `## Follow-ups` section: the rest of the description is the user's. A `## Skipped: your call` section, from an older version of this skill, is this skill's too: its items are open suggestions, so remove the section. When the markers are already there, keep the items in it and add only problems that are not on the list yet.

## 5. Handle bot threads

Step 1 of `../review/THREADS.md` defines a **bot**. Answer every unanswered bot thread (step 3):

- DISMISS: post a **bot reply** and resolve the thread, as "Bot replies" says.
- FIXED: post a bot reply that names the commit that fixed it, and resolve the thread.
- DISCUSS or CLARIFY: ask the user, as step 6 says. When the answer is a fix, the thread is a step 6 item. When it changes nothing, post a bot reply with the reason, and resolve the thread. When the user says to skip it, post the skip reply (step 1 of `../review/THREADS.md`), and leave the thread open. The next run leaves the thread out, as step 3 says, until a person writes on it. When a finding names the thread (`Also raised by`), the user's answer on the thread also settles that finding:
  - A fix: the finding is the one step 6 item for both.
  - Changes nothing: delete the finding from the TODO list. It is not a skipped item.
  - Skip: the finding stays on the list. Its fix in step 6 also gets the thread its bot reply.

A bot thread with a FIX verdict is already a TODO item: it gets its reply in step 6, once it is fixed.

## 6. Fix the items

Take the unticked items one by one, blocking first, then suggestions, in list order. A screenshot suggestion that needs something only the user can make, or whose upload fails in step 2, is skipped without asking: delete it from the list. For each item:

1. Decide if the fix is clear. On an answered bot thread, the answer says what to do. When the answer leads to no change, post a bot reply with the reason, resolve the thread, tick the item, and go to the next item. **Stop and ask the user** when any of these is true, and wait for the answer:
   - The fix needs a choice that the issue, the spec, the code and the item don't make.
   - The fix goes against the issue.
   - The fix needs something only the user can make, such as a video, or a screenshot that `SCREENSHOTS.md` leaves to the user. A blocking screenshot whose upload fails in step 2 also stops here.
   - The thread's verdict is DISCUSS or CLARIFY, and it is not an answered bot thread. A finding that names a thread (`Also raised by`) is not a thread item: step 5 already asked about the thread, so the other rules here decide.
   - The fix changes code outside the PR's files, or behavior the PR does not touch.
   - It is a state problem other than failing or pending CI: uncommitted changes, unpushed commits, merge conflicts, or an open human thread other than an answered bot thread.
   - You tried and the item is still not fixed.

   Ask about one item per message, with the options you see and your recommendation. For merge conflicts, recommend a merge of `origin/<base>`: a rebase rewrites the branch, and the next round then stops the review loop. When the user says to skip an item, delete it from the list and note it as skipped. When the user's answer makes the item a follow-up issue, delete it from the list, and add one line that names the issue under a `## Follow-ups` heading in the PR description, outside the TODO markers, unless that line is there already. A follow-up is not a skipped item.
2. Fix it. For a bug or a missing test: write the test first and see it fail, then fix the code. For failing CI: read the failing job's log (`gh run view <run-id> --log-failed`) and fix the cause. For pending CI: wait for it (`gh pr checks <num> --watch`). For a description finding: edit the description outside the markers, with no commit. For a screenshot finding: make and upload the images as `SCREENSHOTS.md` in this skill's folder says.
3. Run the tests that cover the change, as `Test runs` says. They pass.
4. Commit only this item's change, with a message that says what it fixes. Push.
5. Tick the item in the PR description.
6. When the item came from a bot thread, also an answered bot thread, or names a bot thread (`Also raised by`): post a bot reply that names the commit, and resolve the thread.

The loop is done when every item on the list is ticked.

Then wait for CI on the new head (`gh pr checks <num> --watch`), and go back to step 2: the code changed, so review it again. In this round and every later one, add only blocking items to the list: new suggestions are open suggestions.

## 7. Decide

First run step 5 for every unanswered bot thread: a round without problems comes here without step 5.

Then write the open suggestions as "Open suggestions" says.

When a blocking item was skipped, or the review loop stopped with blocking items open, leave the PR in draft and end with:

```
# NOT READY
Review: reused from <short sha>
Open suggestions: <one line each, or: none>
- [<check or state>] <one sentence per problem>
```

List every problem left, findings first, then state problems. Print the `Review:` line, in this output and in READY, only when the first round reused a review.

When there is no problem left:

1. Remove the ticked items from the TODO list. Remove an empty `### Blocking` or `### Suggestions` heading. When no item is left, remove the whole list with its markers. The public description shows the change, not the fixes on the way.
2. Run `gh pr ready <num> -R <owner>/<repo>`.
3. End with:

```
# READY
PR #<num> is out of draft: <url>
Review: reused from <short sha>
Fixed: <n> blocking, <n> suggestions · Skipped: <one line each, or: none>
Open suggestions: <one line each, or: none>
Follow-ups: <the lines under `## Follow-ups`, or: none>
```

## Open suggestions

Open suggestions are the suggestions nobody decided on:

- The new suggestions of rounds after the first.
- A screenshot suggestion that step 6 skips without asking.
- A suggestion that the first round keeps from an earlier report, when an earlier run skipped it.
- On a solo project: a suggestion that changes code outside the PR's files.

A suggestion the user said to skip is not open.

Where they go depends on the project, as "Solo project" defines it:

- On a solo project: write them in a `## Open suggestions` section at the end of the PR description, after the TODO markers. One line each, with the check, the place and your recommendation: `- [refactoring] \`src/Order.kt:30\` Extract the discount rule into \`Discount.apply\`.`
- On a team project: list them in the final output only. The description stays clean for colleagues.

Each run rewrites the section, and removes it when no open suggestion is left. On a team project, it removes an `## Open suggestions` section that an earlier run left in the PR description. Every final output lists them too.

## Bot replies

A bot reply and the skip reply of step 5 are the only comments this skill posts. A bot reply goes on a bot thread, and the thread is resolved after it. The skip reply gets no cold read, and its thread stays open. It says in one sentence what happened. A teammate who never saw the code understands it.

- Fixed: `Fixed in <short sha>: an empty cart now returns 0.`
- Dismissed: `Not changing this: the caller already filters out null ids (OrderService.kt:18).`

Before you post, check the reply with a cold read: start one `Agent` (general-purpose) and give it only the bot's comment and the reply. The brief: "Say in your own words what was decided and why. Say if you had to read the reply twice." Rewrite the reply when the reader got it wrong or read it twice. In step 5, check all the replies of that step in one agent.

Post the reply and resolve the thread with `gh api graphql`: `addPullRequestReviewThreadReply` with the thread's `id` and the body, then `resolveReviewThread` with the same `id`. Post the skip reply with `addPullRequestReviewThreadReply` only, so its thread stays open. A review body or a PR comment has no thread to resolve: post nothing on it.

## Test runs

When the `implement` skill is installed, run the tests with the `run-tests` script in its folder, as the `Test runs` section of `implement` says. For example: `run-tests 10m ./mvnw test`.

Otherwise run the tests yourself, and read only the summary line and the failures. Keep the output out of the working tree. For example, run `log=$(mktemp); ./mvnw test > "$log" 2>&1`, then read the lines that match `fail` or `error` and the last 15 lines of `$log`.
