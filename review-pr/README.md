# review-pr

Review a GitHub pull request and get a clear verdict: **GO** or **NO GO**. Paste a PR link and Claude checks out the PR, reads the changes in context, and prints a short review in your terminal.

## What it does

- **No `cd` needed.** Paste a PR link from any repo. Claude finds the local checkout in the current folder, its subfolders, or the parent's subfolders, by matching the git remote.
- **Leaves your checkout alone.** The PR is checked out in a separate git worktree, so your branch and uncommitted work stay as they are. The worktree stays after the review, so you can ask follow-up questions.
- **Reads more than the diff.** Full changed files, callers, related tests and recent history.
- **Checks the consumers.** If the PR changes something other code depends on (a public API, shared types, a schema), Claude checks the repos that use it, on their default branch. It reports each place that breaks.
- **Never posts.** The review is only printed in your terminal. Nothing is posted to the PR.

Example output:

```
## PR #142: Add retry to webhook sender
acme/api · alice · +120/-14 across 5 files · base: main

# NO GO
The retry loop can send the same webhook twice.

**Blocking**
- `src/webhooks/sender.ts:58` — The retry runs after a timeout even when the first request succeeded.

**Suggestions**
- **MISSING TEST** `src/webhooks/sender.test.ts` — No test covers the case where all retries fail.
```

## Usage

Paste a PR link, or run the skill directly:

```
/review-pr https://github.com/acme/api/pull/142
/review-pr 142          # a PR in the current repo
/review-pr              # the PR for the current branch
```

Linear review links (`linear.app/<workspace>/review/<slug>`) also work if you have the Linear MCP server installed.

## Telling it about consumers

Claude finds out who uses your code from your `CLAUDE.md` or docs. List them there, for example:

```markdown
The REST API is used by the SDKs in `sdk-java`, `sdk-python` and `sdk-js`.
```

Consumers must be checked out next to the repo to be checked. The review says which ones it could not check.

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`), logged in
- Optional: the [Linear MCP server](https://linear.app/docs/mcp), for Linear review links
