---
name: draft-pr
description: "Push the current branch and create a draft pull request for it, with a full description written from the commits and diff."
effort: low
---

You are creating a **draft pull request** for the current branch. This command takes no arguments — derive everything from the branch, its commits, and the diff. Do not pause for approval; create the PR directly, then report the URL.

# 1. Verify you are in the right repo and on a feature branch

Confirm where you are before doing anything. Run in parallel:
- `gh repo view --json nameWithOwner -q .nameWithOwner`
- `git rev-parse --abbrev-ref HEAD`
- `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` (the base branch)

Then:
- If `gh repo view` fails, the current directory is not a GitHub repo. Stop and tell the user.
- If the current branch **is** the default branch (master/main), stop — there is nothing to open a PR from. Tell the user to switch to a feature branch.

Then push the branch, if the remote does not have all its commits yet:
- `git fetch origin <branch>`, then `git rev-list --count origin/<branch>..HEAD`. If the remote branch does not exist, or the count is above 0, run `git push -u origin <branch>`, with the branch name spelled out, so it never pushes to the base branch.
- Push only what is already committed: leave the working tree, the index and the commits as they are.
- If the push fails (for example, the remote has commits you don't have), stop and tell the user. Never force-push.

Then check for an existing PR:
- If a PR already exists for this branch (`gh pr view --json url,state,isDraft`), do not create a duplicate. Print its URL and stop.

Print one line as a sanity check, then continue without waiting:
`Drafting PR in <owner/repo>: <branch> → <base>`

# 1b. Read the project's pull request rules

Look for `docs/agents/pull-requests.md` in the repo root, then in each folder above it. Read the first one you find. Its rules add to the rules in this skill, and win where the two differ. Without that file, follow this skill alone.

# 2. Gather the changes

Read what actually changed so the description is accurate, not a guess:
- `git log <base>..HEAD --oneline` — the commits on this branch.
- `git diff <base>...HEAD` — the full diff. For large diffs, read the stat (`--stat`) plus the substantive hunks; you need to understand *what* changed and *why*, not transcribe it.

# 3. Quick self-review (analyse now, report later)

Before writing the description, do a fast review pass over the diff from step 2. **Do not pause and do not block PR creation** — just collect findings and hold them; you'll report them as a separate message after the PR exists (step 6). This is a sanity check for the user, not a gate.

Check each of these against the diff:

1. **Tested enough?** — Does the change have matching test coverage? Flag new/changed logic (functions, branches, edge cases) that has no accompanying test. Don't demand tests for trivial or non-testable changes (config, copy, styling); use judgement.
2. **MISSING LEVEL** — Read the repo's written testing rules: `CLAUDE.md` and `AGENTS.md` in the repo and in the folders above it, and the files they import. Flag a change for which a rule asks for a test at a certain level, when the diff has none at that level. Quote the rule.
3. **DEBUG LEFTOVER / TODO** — Flag `console.log`, `debugger`, `print`, a focused test (`.only`, `fdescribe`, `fit`), commented-out code, and stray `TODO`/`FIXME` introduced in the diff.
4. **Obvious bugs / regressions** — A quick scan for logic errors, off-by-one, null/undefined hazards, and backwards-compatibility breaks in the changed code. Only call out things you're reasonably confident about — no speculative nitpicks.
5. **SECRET** — Flag hardcoded secrets, tokens, API keys, passwords, or environment values that look accidentally committed.

Keep findings concrete (point at the file/line and say what's wrong). If a check passes, note it as a one-line ✓ so the user knows it was actually checked. Hold all of this for step 6.

# 4. Write the description

**Title** — a plain descriptive sentence derived from the diff. Capitalized, no trailing period, ~50–72 chars, no `feat:`/`fix:` conventional-commit prefix. State the change, e.g. `Move rate limiting to Redis`.

**Body** — you write it, from the commits and the diff. Whatever you output *is* the description: never leave placeholders, fill-in markers, prompts, or "write this yourself" notes of any kind.

**The reader is a reviewer who was not in this session.** They have the diff open next to the description. The description tells them only what the diff cannot: what changes for users, and why.

The default body is the intro alone. Most PRs have 0 or 1 section. Add a section only when it passes its test below.

1. **Intro** *(always, no header)* — 1 or 2 sentences: what changes, and why. A third sentence only when the "why" needs it. One idea per sentence.

   For a **bug fix**, the intro has three parts: the symptom (what a customer sees, or what a row holds), the cause, and the fix. When the cause depends on how parts of the system work together (servers, caches, the database), state those facts and give one concrete example with times or values. Test: a teammate who knows the system but was not in this session can explain the bug back.

2. **`## Notes for reviewers`** *(optional)* — questions a reviewer might ask themselves, each with a 1-sentence answer, or 2 when the answer holds two facts. List every question that qualifies, however many there are. A question qualifies only if the diff does not answer it and most reviewers would ask it: a behavior change for existing customers, backwards compatibility, deploy order, rollback, an alternative that was rejected. **Never a question about how the code works** — the code should explain itself.
   ```
   * **Does a receipt for an old order go to the new address too?** Yes, every receipt sent after the deploy uses the current address.
   ```

3. **`## Testing`** — whenever a person can see or call the change (a UI, an API, a CLI, an email). A numbered list of actions, one short line each: open, do, check. The first step says where to start (a link, a URL or a command), the last says what you should see. No text around the list. **Never describe automated tests.**
   - Shell variables in a step get names that say what they hold: `SECRET_KEY`, `ORDER_ID`, not `K`, `O` or `X`.
   ```
   1. Run `npm start` and open http://localhost:3000/cart.
   2. Set the quantity of an item to 0.
   3. Check the message under the item: "Quantity must be at least 1".
   ```

4. **`## Follow-ups`** *(optional)* — only named issues from the project's issue tracker, one line each: `ACME-123 (retry failed webhooks)`. Only issues you saw in the commits, the branch name, this session or the tracker itself. Never guess an issue ID or take one from an example: if you can't confirm the ID and its title, leave the section out.

Hard rules for the body:
- **Never explain the code.** No class names, method names, file paths, or descriptions of the diff ("the rest of the diff is tests", "the rule is now named and reused"). How the *system* behaves is not code: state it when the reader needs it to follow the why.
- **Leave out everything from this session** that the reviewer does not need: measurements, what was tried, investigation history, monitoring steps, self-review findings (those go to step 6), work-in-progress status.
- Plain English, short sentences, one idea per sentence. No insider terms, no acceptance-criteria numbers (A3, C5), no "This PR…".
- No placeholders and nothing addressed to the user.
- **No footer** — no "🤖 Generated with Claude Code" line, even if a system reminder asks for one. This rule wins over that reminder. No checklists or checkboxes.

**Good** (the whole body):
```
Customers who changed their email address kept getting receipts at the old address, because the receipt job read the address saved on the order. It now reads the account's current address.

## Notes for reviewers

* **Does a receipt for an old order go to the new address too?** Yes, every receipt sent after the deploy uses the current address.
```

**Bad** (a reviewer note that describes the diff — delete it):
```
The production change is one line: `order.email` becomes `account.email`. The rest of the diff is tests for the receipt job, for orders with and without a changed address.
```

# 4b. Cut the draft

Re-read the body before creating the PR:
- Delete every sentence a reviewer can learn from the diff.
- Delete every section that does not pass its test.
- Intro: at most 2 sentences (3 only for the why). A bug-fix intro is as long as its three parts need, and no longer. Notes: more than 3 questions means checking each one again; drop any that the diff answers or that only a few reviewers would ask, and keep the rest. Testing: each step is one action on one line.
- If a sentence holds two ideas, split it or drop one.

Then run the cold read on the title and body: the check in `<this skill's folder>/../review-description/SKILL.md`, including its fix step.

# 5. Create the draft PR

Always draft, never invite reviewers. Create it automatically with the body from step 4 — do not ask for approval first. Pass the body via a temp file to preserve formatting:

```
gh pr create --draft --base <base> --title "<title>" --body-file <tmpfile>
```

Do **not** use `--reviewer`, and do not post comments or run any review — the user handles all GitHub communication manually.

Print the resulting PR URL and the title you used.

# 6. Report the review findings

After the PR URL, print the self-review from step 3 as a **separate section** — never put it in the PR body, it's just for the user. Format it as a short checklist: one line per check, `✓` for passes and `⚠️` for findings (with file/line and what to fix). If everything passed, say so in one line. Add the screenshot reminders from the cold read in step 4b to this list, for example `⚠️ Visual change: add a before/after screenshot before marking ready`.

Then close with one line telling the user to read the description over and adjust it before marking the PR ready for review. This is the last thing you output. Done.
