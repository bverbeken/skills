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

**Re-review.** After you reviewed a PR and the author answered, `re-review 142` checks only the answered threads: yours, and every answered thread from a review bot such as Copilot. For each one it says RESOLVED, NOT RESOLVED (with the example that still fails) or NEW PROBLEM, runs `review-bugs` on the fix commits, and ends with GO / NO GO. `review` reminds you of it when it sees you reviewed the PR before.

## What it does

- **Takes any target.** A PR number, a GitHub PR link, an issue ID or link, a Linear review link, a branch name, or nothing for the current branch (uncommitted changes included).
- **Leaves your checkout alone.** Anything other than the current branch is checked out in a separate git worktree. The worktree stays, so you can ask follow-up questions.
- **Reads the whole spec.** The issue, its comments, its parent, every link it can open (support conversations, docs), the PR description and the commits.
- **Strict on your own work.** When the PR is yours, or there is no PR yet, anything a careful colleague would comment on blocks. A colleague's PR gets the normal bar. Breaking a written repo rule blocks in both cases.
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

## Install

All ten skills must sit next to each other: the checks read the shared steps in `review/STEPS.md`.

**By copying** (no updates, you copy again to get changes; [`CHANGELOG.md`](CHANGELOG.md) lists what changed):

```bash
git clone https://github.com/bverbeken/skills.git
cp -r skills/review/skills/* ~/.claude/skills/
```

**As a plugin** (updates with `/plugin marketplace update bverbeken-skills`):

```
/plugin marketplace add bverbeken/skills
/plugin install review@bverbeken-skills
```

As a plugin, the skill names get a prefix: `/review:review 142`, `/review:review-tests 142`. Saying "review 142" works either way.

## Requirements

- A recent Claude Code. `review-bugs` runs its built-in `/code-review`.
- `git`. The review checks out PRs and branches in separate worktrees.
- The [GitHub CLI](https://cli.github.com/) (`gh`), logged in with access to your repos.
- An MCP server for your issue tracker (Linear, Jira, …), unless your issues are GitHub issues. Without it, the spec is only the PR description and the commits.
- Optional: MCP servers for what your issues link to, for example a support tool. The review reads those links too.
- Your repos checked out side by side in one folder. The review finds the repo for a PR link there, and checks the consumers there. Run Claude from that folder or from one of the repos.

## Set up your project

Tell Claude about your project in a `CLAUDE.md`: in the repo, in the folder that holds your checkouts, or in `~/.claude/CLAUDE.md`. Without it, the review still works, but `review-spec` may miss the issue and `review-consumers` checks nothing.

Example:

```markdown
## Code reviews

Issues live in Linear, team ACME, with IDs like ACME-123. Read them with the Linear MCP tools.

Who depends on what:
- The REST API in `acme-api` is used by the SDKs `acme-java`, `acme-python` and `acme-js`.
- The shared types in `acme-types` are used by `acme-web` and `acme-mobile`.
```

- **Issue tracker**: where issues live and how their IDs look. For GitHub issues: "Issues are GitHub issues in this repo."
- **Consumers**: which repos use which code. A consumer that isn't checked out next to the others is reported as "not checked".
- **Coding standards and decisions**: `CODING_STANDARDS.md`, `CONTRIBUTING.md`, ADRs, a glossary. The checks find these by themselves, so only name them when they live somewhere unusual.

## Credits

`review-spec` and `review-refactoring` are based on the `code-review` skill in [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, © Matt Pocock).
