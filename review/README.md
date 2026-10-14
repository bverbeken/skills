# review

A full code review in one command. Say `review 142` or paste a PR link. Claude runs eight checks in parallel, verifies every blocking finding, and ends with a clear **GO** or **NO GO**.

## The checks

| Skill | Checks |
|---|---|
| `review-tests` | Is every new code path tested? Do the tests assert behavior? |
| `review-spec` | Does the change do what the issue, its linked conversations and the PR say? Is every difference explained? |
| `review-bugs` | Bugs of every kind, including security. Runs Claude Code's built-in `/code-review`. |
| `review-performance` | N+1 queries, unbounded reads, missing indexes, wasted work, load on shared services. |
| `review-style` | The repo's documented standards, and consistency with the code around it. |
| `review-refactoring` | Names, duplicate code, code in the wrong place, code smells. |
| `review-architecture` | Does the change fit the codebase's design and its recorded decisions (ADRs, glossary)? |
| `review-consumers` | Does the change break the projects that depend on it? |

Each check can also run on its own, for example `/review-tests 142`.

## What it does

- **Takes any target.** A PR number, a GitHub PR link, an issue ID or link, a Linear review link, a branch name, or nothing for the current branch (uncommitted changes included).
- **Leaves your checkout alone.** Anything other than the current branch is checked out in a separate git worktree. The worktree stays, so you can ask follow-up questions.
- **Reads the whole spec.** The issue, its comments, its parent, every link it can open (support conversations, docs), the PR description and the commits.
- **Verifies before it blocks.** Every blocking finding goes to a separate agent that tries to prove it wrong. Only confirmed findings count toward NO GO. The rejected ones are listed, so you can disagree.
- **Never posts and never changes code.** The review is only printed in your terminal.
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

**Checks**: tests 1 · spec 0 · bugs 1 · performance 1 · style 0 · refactoring 0 · architecture 0 · consumers 0

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

## Telling it about your project

Claude reads these from your `CLAUDE.md` / `AGENTS.md`:

- **The issue tracker**, for example "Issues live in Linear, team API" or "Issues are GitHub issues in this repo".
- **The consumers**, for example "The REST API is used by the SDKs in `sdk-java`, `sdk-python` and `sdk-js`." Consumers must be checked out next to the repo. The review says which ones it could not check.
- **Coding standards and decisions**: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, ADRs, a glossary. The checks find them by themselves.

## Install

Install the plugin, so all nine skills sit together. The checks find the shared steps in `review/STEPS.md` next to them.

```
/plugin marketplace add bverbeken/skills
/plugin install review@bverbeken-skills
```

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`), logged in
- Claude Code's built-in `/code-review`, for `review-bugs`
- Optional: an MCP server for your issue tracker (Linear, Jira, …), and for anything the issues link to (for example Intercom)

## Credits

`review-spec` and `review-refactoring` are based on the `code-review` skill in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, © Matt Pocock).
