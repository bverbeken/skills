# Threads

How `review` handles a PR that already has comments. "You" is the user: `gh api user -q .login`. Comments that the user's own tools post (for example their Claude Code) carry the user's login, so they count as the user's. One exception: a comment from the user's login that starts with `🤖 ` is the **build**'s. `ready-for-review` posts the build's `🤖 ` comments, with and without `--afk`, and they count as neither yours nor someone else's. It posts four kinds:

- A reply to a bot thread, for example a Copilot thread, that says what was fixed or why not. The build resolves the thread.
- A reply that names the commit of a fix. The build resolves the thread.
- A reply with the reason it changes nothing: on a bot thread you answered, and with `--afk` on a human thread it dismisses. The thread stays open.
- A **skip reply**, `🤖 <url> Skipped: this one is your call.`, on a thread whose decision is yours. The thread stays open.

When you answer after the build on a bot thread, the thread goes to **triage** (step 2), and `ready-for-review` handles it as a human thread: it does what your answer asks.

## 1. Fetch

Get everything in one query:

```
gh api graphql -f query='
query($owner:String!,$repo:String!,$num:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$num){
      reviewThreads(first:100){
        nodes{
          id
          isResolved
          isOutdated
          comments(first:50){ nodes{ author{__typename login} body path line originalLine url createdAt originalCommit{oid} } }
        }
      }
      reviews(first:50){ nodes{ author{__typename login} body state submittedAt url commit{oid} } }
      comments(first:100){ nodes{ author{__typename login} body createdAt url } }
    }
  }
}' -F owner=<owner> -F repo=<repo> -F num=<num>
```

With the Linear tools, also call `mcp__linear__get_diff_threads` with the PR link. Linear links a review body to its reply, which GitHub does not.

Turn the result into **threads**:

- Each review thread is a thread.
- Each review body with text is a thread. Skip empty bodies, `PENDING` reviews, and review bodies from a bot: a bot's summary has nothing to act on.
- PR comments: a comment that answers a review body joins that thread. A build comment that names the URL of a review body or a PR comment joins that thread. Treat any other PR comment from the PR author after a review body as its answer. Every other PR comment is a thread of its own.

The **starter** is the author of a thread's first comment. A **bot** is an author whose `__typename` is `Bot`, or a login that ends in `[bot]` or matches `copilot` (case-insensitive). GraphQL gives an app's login without `[bot]`: CodeRabbit is `coderabbitai`. Everyone else is a human.

If there are no threads, stop here: `review` runs as for a new PR.

## 2. Sort

Put every thread in exactly one group. The mode comes from step 1 of `STEPS.md`.

**Own mode**: the first row that matches wins. Bot comments that come after a build comment don't count for the last word.

| Thread | Group |
|---|---|
| Open, and the build has the last word | **waiting** |
| Open, and you have the last word after the build | **triage** |
| Open, and someone else has the last word | **triage** |
| Open, and only you commented in it (a note from you or your tools) | **triage** |
| Open, and you have the last word after a bot | **triage** |
| Open, and you have the last word after someone else | **waiting** |
| Resolved | **recheck** |

**Colleague mode**

| Thread | Group |
|---|---|
| You started it or commented in it, and someone answered after your last comment | **recheck** |
| A bot started it, and a human answered | **recheck** |
| Resolved, and not in **recheck** | **settled** |
| You started it, and you have the last word | **waiting** |
| Anything else | **context** |

**Settled** and **context** threads are only used to remove duplicate findings (see step 4).

Print one line: `Threads: <n> to triage · <n> to recheck · <n> waiting · <n> settled · <n> context`. Leave out groups with 0.

## 3. Check the threads

Run this at the same time as the checks: start these agents in the same message as the check agents.

Start one `Agent` (general-purpose) per thread in **triage** and **recheck**. When there are more than 10, give each agent the threads of one file. Give each agent: the thread or threads (every comment, verbatim, with path, lines and URL), `<contextFile>`, `<reviewDir>`, the mode, and the brief for its group below. Each agent returns, per thread: the verdict, one sentence why, a finding in the form of step 4 of `STEPS.md` when the verdict asks for one (with `check: <starter>`), and the draft reply.

Draft replies are written as the user: first person, friendly, direct, ready to paste into the thread. One to three sentences.

### Triage brief

"Read the code around the thread's lines in `<reviewDir>`: the function, its callers, its tests. For a comment on the whole PR, read the diff. Check the comment's claim against that code.

When the claim depends on a number, a boundary or floating point ('off by one when N is 0', 'rounding adds up'), test it before you decide: find the values the code really gets, and run them, or a large random sample of them. If no example fails, the problem is theoretical: say what you ran.

Give one verdict:
- FIXED: the code already solves it. Name the commit. Reply: what fixed it.
- FIX: the claim is right and the code still has the problem. Return a finding: `blocking` when a careful colleague would ask for the change, `suggestion` when it is taste. Reply: agree, and say what will change.
- DISMISS: the claim is wrong or does not apply here. Reply: why, with the proof (the line, the type, what you ran).
- DISCUSS: there is a good reason to do it differently. Reply: that reason, politely, and ask what they think.
- CLARIFY: you can't tell what is asked. Reply: one focused question.

Be skeptical of bots: they often ask for redundant checks, comments or constants, or miss the rest of the codebase, and sometimes find a real bug. Take every human comment seriously: never call it noise."

### Recheck brief

"The thread raised a problem. The answers say it is fixed, or that it is not a problem. Find out which is true in the current code in `<reviewDir>`.
- For a fix: read the commits since the thread's commit (`git -C <reviewDir> log --oneline <thread commit>..HEAD`). Try the thread's example, or one you build, against the new code. Does the problem still happen?
- For an argument: check it against the code, docs or source it names. Is it true?
- If an answer points to another repo, find its checkout like in step 2 of `STEPS.md`. If it is not checked out, say `not checked`.

Give one verdict:
- RESOLVED: the problem is gone, or the argument holds. No reply needed when the thread is already resolved; otherwise the reply says it looks good.
- NOT RESOLVED: the problem still happens. Return the finding, with the example that still fails. Reply: the example, and what is still needed.
- NEW PROBLEM: the fix causes another problem. Return the finding. Reply: the problem and its example."

## 4. Remove duplicate findings

When all agents have answered, compare each finding from the checks with the threads. A finding matches a thread when it is about the same problem in the same code, even if the words differ.

| The finding matches | What to do |
|---|---|
| A **triage** or **recheck** thread | Drop the finding. The thread's verdict covers it. |
| A **waiting** thread | Drop the finding. The thread is listed under "Waiting". |
| A **settled** thread | Drop the finding. |
| A **context** thread | Move it to "Already raised", with the thread's starter and URL. |

In own mode every resolved thread is in **recheck**, so a resolved thread never hides a finding that is still true.

Then go back to `review` step 3: findings from threads are verified like any other.
