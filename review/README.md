# review

A full code review in one command, at any stage of a PR. Say `review 142` or paste a PR link. Claude runs eleven checks in parallel, checks the comments already on the PR against the code, verifies every blocking finding, drafts the replies, and ends with a clear **GO** or **NO GO**.

## The checks

| Skill | Checks |
|---|---|
| `review-tests` | Is every new code path tested? Do the tests assert behavior? |
| `review-spec` | Does the change do what the issue, its linked conversations and the PR say? Is every difference explained? |
| `review-bugs` | Bugs of every kind, from six angles that run in parallel: every changed line, every removed rule, the callers of changed functions, the pitfalls of the language, wrappers and proxies, and secrets in added lines. Each angle is its own skill, for example `review-bugs-callers`. |
| `review-performance` | N+1 queries, unbounded reads, missing indexes, wasted work, load on shared services. |
| `review-style` | The repo's documented standards, and consistency with the code around it. |
| `review-comments` | Every comment the change adds, and the test, name or extracted method that should replace it. |
| `review-refactoring` | Names, duplicate code, code in the wrong place, code smells. |
| `review-architecture` | Does the change fit the codebase's design and its recorded decisions (ADRs, glossary)? |
| `review-consumers` | Does the change break the projects that depend on it? Each consumer is checked by its own agent, in parallel. |
| `review-dependencies` | For each dependency the change adds: why this one, is it maintained, can we trust it (vulnerabilities, signs of a supply chain attack), is its license allowed, and what are the alternatives. Each dependency is researched by its own agent, in parallel. Finds nothing when no dependency is added. |
| `review-description` | Can a teammate who only reads the PR description say what was wrong, why, and what changes? An agent reads it cold, with nothing else. Runs only on a PR. |

Each check can also run on its own, for example `/review-tests 142`.

A diff that holds only Markdown text, for example a change to `CLAUDE.md`, gets only spec, bugs, style, comments and description. A change to a skill's files gets all checks. `--only bugs,tests` runs the named checks on any diff.

**Comments already on the PR.** Run `review` again whenever comments come in. It sorts the existing threads and handles each group:

| | Your PR | A colleague's PR |
|---|---|---|
| Open thread, someone else has the last word | Checked against the code: FIXED, FIX, DISMISS, DISCUSS or CLARIFY, with a draft reply | Your threads and answered bot threads: RESOLVED, NOT RESOLVED (with the example that still fails) or NEW PROBLEM, with a draft reply |
| Resolved thread | Checked again: you want your PR spotless before it goes out of draft | Settled: never raised again |
| You have the last word | Listed as waiting | Listed as waiting |
| The build has the last word (a reply under your login that starts with `🤖 `), or only bots answered the build's reply | Listed as waiting; checked again once you answer | |

A finding that is already in a thread is not reported twice. On a colleague's PR, a finding someone else already raised is listed under "Already raised".

**Ready for review.** `/ready-for-review 142` gets your own draft PR ready and takes it out of draft. It runs `review` in own mode and writes a TODO checklist in the PR description: blocking items first, then suggestions. Then it fixes them one by one, with a commit per item, and ticks each one off. It stops and asks you when a fix needs your choice, or would change a line in the issue's `## Decisions` section, as `prepare` writes it. With `--afk` it asks nothing: it takes its own recommendation, answers your threads with replies that start with `🤖 `, and leaves the PR in draft when something only you can decide is left. Copilot threads get a short reply and are resolved, both the fixed and the dismissed ones. After 5 rounds with blocking items, or when a blocking finding it fixed comes back, it stops and leaves the PR in draft. When a new review round finds nothing that blocks and CI is green, it removes the ticked items from the description and marks the PR ready, and moves its issue to `REVIEW`. It refuses PRs that are not yours.

## What it does

- **Takes any target.** A PR number, a GitHub PR link, an issue ID or link, a Linear review link, a branch name, or nothing for the current branch (uncommitted changes included).
- **Leaves your checkout alone.** Anything other than the current branch is checked out in a separate git worktree. The worktree stays, so you can ask follow-up questions.
- **Reads the whole spec.** The issue, its comments, its parent, every link it can open (support conversations, docs), the PR description and the commits.
- **Strict on your own work.** When the PR is yours, or there is no PR yet, anything a careful colleague would comment on blocks. A colleague's PR gets the normal bar. Breaking a written repo rule blocks in both cases.
- **Verifies before it blocks.** Every blocking finding goes to a separate agent that tries to prove it wrong. Only confirmed findings count toward NO GO. The rejected ones are listed, so you can disagree.
- **Never posts and never changes code.** The review and the draft replies are only printed in your terminal. You post what you want yourself.
- **Reads, doesn't run.** It doesn't run tests or linters: CI does that. The CI status is in the header.

Example output:

```
## PR #142: Add retry to webhook sender
acme/api · +120/-14 across 5 files · base: main
Spec: API-87 + 1 support conversation
CI: all checks passed

**Blocking** (verified)
- [bugs] `src/webhooks/sender.ts:58` — The retry runs after a timeout even when the first request succeeded.

**Suggestions**
- [tests] MISSING TEST `src/webhooks/sender.test.ts` — No test covers the case where all retries fail.
- [performance] LOAD `src/webhooks/sender.ts:40` — Every retry reads the full subscriber list again.

**Dropped in verification**
- [spec] `src/webhooks/sender.ts:12` — Max 3 retries is missing — the constant is set in config/webhooks.ts.

**Checks**: tests 1 · spec 0 · bugs 1 · performance 1 · style 0 · comments 0 · refactoring 0 · architecture 0 · consumers 0 · dependencies 0 · description 0

# NO GO
The retry can send the same webhook twice.
```

## Usage

```
/review https://github.com/acme/api/pull/142
/review 142                  # a PR in the current repo
/review API-87               # an issue: reviews its PR or branch
/review feature/retries      # a branch
/review                      # the current branch
/review 142 --only bugs,tests
```

Saying "review 142" or "is this PR ready to merge?" also works.

## Install

All nineteen skills must sit next to each other: the checks read the shared steps in `review/STEPS.md`. Link the skill folders into `~/.claude/skills/`. The steps are in the [README of this repo](../README.md#install). [`CHANGELOG.md`](CHANGELOG.md) lists what changed.

## Requirements

- `git`. The review checks out PRs and branches in separate worktrees.
- The [GitHub CLI](https://cli.github.com/) (`gh`), logged in with access to your repos.
- An MCP server for your issue tracker (Linear, Jira, …), unless your issues are GitHub issues. Without it, the spec is only the PR description and the commits.
- Optional: MCP servers for what your issues link to, for example a support tool. The review reads those links too.
- Your repos checked out side by side in one folder. The review finds the repo for a PR link there, and checks the consumers there. Run Claude from that folder or from one of the repos.

## Set up your project

Tell Claude about your project in a `CLAUDE.md`: in the repo, in the folder that holds your checkouts, or in `~/.claude/CLAUDE.md`. Without it, the review still works, but `review-spec` may miss the issue and `review-consumers` checks nothing. When it names an issue tracker doc, `ready-for-review` reads there which status `REVIEW` maps to, and moves the issue to it when the PR is ready. The [development README](../development/README.md#factory-statuses) lists the factory statuses.

Example:

```markdown
## Code reviews

Issues live in Linear, team ACME, with IDs like ACME-123. Read them with the Linear MCP tools.

Who depends on what:
- The REST API in `acme-api` is used by the SDKs `acme-java`, `acme-python` and `acme-js`.
- The shared types in `acme-types` are used by `acme-web` and `acme-mobile`.
```

- **Issue tracker**: where issues live and how their IDs look. For GitHub issues: "Issues are GitHub issues in this repo."
- **Licenses**: which licenses your dependencies may have, if that differs from the default in `review-dependencies`. Example: "No GPL, also not in CI."
- **Consumers**: which repos use which code. A consumer that isn't checked out next to the others is reported as "not checked".
- **Review settings**: a file your `CLAUDE.md` names, usually `docs/agents/review-settings.md`, with one `key: value` per line. With `screenshots: required`, a missing screenshot, before/after or video blocks your own PRs. Without it, they are suggestions.
- **Coding standards and decisions**: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, ADRs, a glossary. The checks find these by themselves, so only name them when they live somewhere unusual.

## Credits

`review-spec` and `review-refactoring` are based on the `code-review` skill in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, © Matt Pocock).
