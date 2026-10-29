---
name: draft-pr
description: "Push the current branch and create a draft pull request for it, with a full description written from the commits and diff."
argument-hint: "[seams that tdd picked]"
effort: low
---

You are creating a **draft pull request** for the current branch. Derive everything from the branch, its commits, and the diff. The only argument is an optional list of seams that `tdd` picked itself, one line per seam with what it catches. Do not pause for approval; create the PR directly, then report the URL.

# 1. Verify you are in the right repo and on a feature branch

Confirm where you are before doing anything. Run in parallel:
- `gh repo view --json nameWithOwner -q .nameWithOwner`
- `git rev-parse --abbrev-ref HEAD`
- `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` (the base branch)

Then:
- If `gh repo view` fails, the current directory is not a GitHub repo. Stop and tell the user.
- If the current branch **is** the default branch (master/main), stop — there is nothing to open a PR from. Tell the user to switch to a feature branch.

Then read the project's pull request rules. When a `CLAUDE.md` or `AGENTS.md` in the repo or in a folder above it names a pull request doc, usually `docs/agents/pull-requests.md`, read it. The path is relative to the folder of the file that names it. Its rules add to this skill's rules for the description, and win where the two differ. The git rules of this skill always hold: draft only, no reviewers, never force-push. When no file names a pull request doc, follow this skill alone.

Then push the branch, if the remote does not have all its commits yet:
- `git fetch origin <branch>`, then `git rev-list --count origin/<branch>..HEAD`. If the remote branch does not exist, or the count is above 0, run `git push -u origin <branch>`, with the branch name spelled out, so it never pushes to the base branch.
- Push only what is already committed: leave the working tree, the index and the commits as they are.
- If the push fails (for example, the remote has commits you don't have), stop and tell the user. Never force-push.

Then check for an existing PR:
- If an open PR already exists for this branch (`gh pr view --json url,state,isDraft` shows `OPEN`), do not create a duplicate. A closed or merged PR for the branch does not count: create a new one. Print its URL and stop, or go back to the skill that called this one.

Print one line as a sanity check, then continue without waiting:
`Drafting PR in <owner/repo>: <branch> → <base>`

# 2. Gather the changes

Read what actually changed so the description is accurate, not a guess. Run `git fetch origin <base>` first, so the local base can't be behind:
- `git log origin/<base>..HEAD --oneline` — the commits on this branch.
- `git diff origin/<base>...HEAD` — the full diff. For large diffs, read the stat (`--stat`) plus the substantive hunks; you need to understand *what* changed and *why*, not transcribe it.

# 3. Write the description

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

5. **`## Seams I chose`** — only when the arguments hold a list of seams: that list, one line per seam.

Hard rules for the body:
- **Never explain the code.** No class names, method names, file paths, or descriptions of the diff ("the rest of the diff is tests", "the rule is now named and reused"). How the *system* behaves is not code: state it when the reader needs it to follow the why.
- **Leave out everything from this session** that the reviewer does not need: measurements, what was tried, investigation history, monitoring steps, work-in-progress status.
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

# 4. Cut the draft

Re-read the body before creating the PR:
- Delete every sentence a reviewer can learn from the diff.
- Delete every section that does not pass its test.
- Intro: at most 2 sentences (3 only for the why). A bug-fix intro is as long as its three parts need, and no longer. Notes: more than 3 questions means checking each one again; drop any that the diff answers or that only a few reviewers would ask, and keep the rest. Testing: each step is one action on one line.
- If a sentence holds two ideas, split it or drop one.

# 5. Cold read

Run the cold read on the title and body: the check in `<this skill's folder>/../review-description/SKILL.md`, including its fix step. Create the PR only after this step.

The step is done when a cold reader's answer matches the change and you fixed its findings. When the second cold reader still finds problems, go on to step 6 anyway: the report lists the findings that are left. Keep count of the findings you fixed and the findings that are left.

# 6. Create the draft PR

Always draft, never invite reviewers. Create it automatically with the title and body from step 5 — do not ask for approval first. Pass the body via a temp file to preserve formatting:

```
gh pr create --draft --base <base> --title "<title>" --body-file <tmpfile>
```

Do **not** use `--reviewer`, and do not post comments or run any review — the user handles all GitHub communication manually.

Print the resulting PR URL and the title you used.

# 7. Report

After the PR URL, print one line about the cold read, also when no finding is left: `Cold read: 2 findings fixed, 0 left`. Then print each finding that is left, one per line.

Then print the screenshot reminders from the cold read in step 5, one line each, for example `⚠️ Visual change: add a before/after screenshot before marking ready`. When a `CLAUDE.md` or `AGENTS.md` in the repo or in a folder above it names a review settings file, usually `docs/agents/review-settings.md`, read it, with the path relative to the folder of the file that names it. When there is no such file, or it does not hold `screenshots: required`, say the screenshot is optional: `⚠️ Visual change: a before/after screenshot would help (optional)`.

Then close with one line telling the user to read the description over and adjust it before marking the PR ready for review. This is the last thing you output. When another skill called this one, go back to it and continue its next step.
