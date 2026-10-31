# Changelog

Changes in what the development skills do, newest first. Wording-only changes are left out.

## 2026-10-30

- `tdd` and `implement` run every test run with a time limit: 10 minutes, or the limit the repo sets next to its test command. A test the change wrote that times out counts as a failing test. An existing test that times out before the change has any commit or edit stops the build at once. When an existing test times out later in the build, it runs once more on the base, set up like the build. When it passes there, the change caused the hang, and it counts as a failing test. When it hangs or fails on the base too, it stops the build as a setup failure. Without `--afk`, `implement` asks you. With `--afk`, it writes the command, the limit and the last lines of output as an open question, and moves the issue to `TO_CLARIFY`. A missing `timeout` for a limit over 10 minutes stops the build the same way.
- `merge` started in a linked worktree, such as the PR's own, works from the main worktree. `foreman --afk` can now call it from the PR's worktree, right after `ready-for-review` moves the issue to `APPROVED`.
- `foreman` without `--afk` moves a `BUSY` issue with a linked PR on. It first asks whether a build may still be running on the PR, and goes on only after a yes. A draft PR gets `ready-for-review`, which moves the issue to `REVIEW`. A PR out of draft moves the issue to `REVIEW` directly. With `--afk`, such an issue still has no step. `foreman status` marks it `▶`: if no build is running on the PR, run `/foreman <issue>`.

## 2026-10-29

- `implement` runs one existing test near the change before the first tdd cycle. When a test fails for a reason outside the change, such as a database version or a missing tool, it names the cause and waits for you to fix the machine. With `--afk`, it writes the cause as an open question and moves the issue to `TO_CLARIFY`. It never bases the branch on an older commit, skips a test, or changes the machine to make tests pass.
- `foreman` and `foreman status`: bot comments after a `🤖 ` reply don't count as the last comment of a thread. A thread where only a bot answered the build's reply is not new, so `foreman --afk` does not pick its PR again. A bot is an author whose GraphQL type is `Bot`, such as CodeRabbit, or a login that ends in `[bot]` or matches `copilot`.
- `draft-pr` runs the cold read as its own step, before it creates the PR. When the second cold reader still finds problems, it creates the draft PR anyway. Its report always has a cold read line, for example `Cold read: 2 findings fixed, 0 left`, and lists each finding that is left.

## 2026-10-28

- `draft-pr`: its screenshot reminder says the screenshot is optional, unless the repo's review settings hold `screenshots: required`.
- `foreman`: a new review thread is an unresolved thread whose first and last comments both do not start with `🤖 `, whoever wrote them. A thread you open on your own PR now counts as new, also when the build posts under your login. A thread where you answered a colleague last is not new: it waits on them. `foreman status` uses the same rule.
- `foreman` builds a `BUSY` issue that you moved there yourself, when no build has started for it: it is assigned to you, with no linked PR and no branch for it.
- `/foreman` without an issue shows `foreman status`. With `--afk`, it still picks the issue closest to done: `APPROVED`, `REVIEW` with a new thread, then `READY`.
- `merge` refuses a PR that someone else opened.
- `merge` uses a squash merge. When the repo allows no squash merge, it uses a rebase merge, and otherwise a merge commit.

## 2026-10-27

- `foreman`: the build runs `review` once. After `implement` fixes the blocking findings, the build goes on to `draft-pr` and `ready-for-review`. It no longer stops after a second NO GO.
- New: `foreman status` lists the issues in `TO_CLARIFY`, `READY`, `BUSY`, `REVIEW` and `APPROVED`, with what moves each one on. It marks the issues that wait on you and ends with your first action. It changes nothing.

## 2026-10-26

- `implement`: a build that would change or bend a line in the issue's `## Decisions` asks you through `prepare`. With `--afk`, it stops with an open question. The question names the line, the fact found, the question and a recommendation.
- `implement`: only builds. It no longer moves the issue to the in-progress status, asks through `prepare` before the build, reviews, or opens the PR: `foreman` does those steps. It fixes the review findings it gets, and `foreman` can call it.
- New: `foreman` does the next step for an issue, based on its status. It holds the order of the steps; the other skills each do one step. Without an issue, it picks the one closest to done. It refuses when the issue tracker docs don't map all 8 factory statuses.
- `merge`: refuses when the issue tracker docs map no `APPROVED`, also when an earlier run already merged the PR.
- `implement` and `merge`: when a stop can't move the issue because the docs map no `TO_CLARIFY`, they say the issue needs a manual move.
- `prepare`: leaves an issue in `BLOCKED`, or a closed issue such as a canceled one, in its status.
- `merge`: when the tests fail after the merge, the issue still moves to `DONE`, with the failing tests in its result. Before, it went back to the status for a stopped build.
- `implement`, `prepare` and `merge` name statuses with fixed UPPERCASE factory statuses, such as `BUSY`, which the issue tracker docs map to the tracker's own statuses. A stopped build moves the issue to `TO_CLARIFY`. A move to a status the docs don't map is skipped and reported at the end. `merge` refuses when the docs map no status to `APPROVED`.
- New: `merge` merges the PR of an approved issue with a rebase merge. When GitHub refuses, it rebases once onto the base branch; a conflict or a failure stops it with an open question. It tests the merged code, closes the issue with a result, and removes the worktree and the branch.
- `implement`: links the PR to the issue, as the issue tracker docs say.
- `draft-pr`: opens a new PR when the branch only has a closed or merged one.
- `draft-pr`: takes an optional list of seams that `tdd` picked itself, and writes them in a `## Seams I chose` section.
- `draft-pr`: goes back to the skill that called it, so `implement --afk` continues after the PR is open.
- `prepare` and `grilling`: you confirm the decisions once, when `prepare` shows the text it will write. `grilling` skips its closing question when the skill that called it asks for the confirmation itself.
- `draft-pr`: no longer runs its own quick review, which repeated the checks of `review`.
- `tdd`: a seam named in the issue's `## Decisions` counts as confirmed. It asks about other seams through `prepare`. With `--afk`, it picks them itself and `implement` lists them in the PR description.
- `implement --afk`: builds with nobody watching. It asks nothing and takes its own recommendation. It skips `prepare` and its own review: after the build it opens a draft PR and calls `ready-for-review --afk`. A decision that only the user can make goes in the issue's open question section, the issue moves to the status for a stopped build, and the build stops. When the issue still has an open question section from an earlier build, it does the same without building. When the tracker docs name no such section or status, it prints the question instead.
- `implement`: assigns the issue only when the issue tracker docs say issues have an assignee.
- New: `implement`, `tdd`, `prepare`, `grilling`, `codebase-design` and `draft-pr`.
- `draft-pr`: reads the project's own PR rules, from the doc that a `CLAUDE.md` or `AGENTS.md` in the repo or a folder above it names. It reads them after it checks the repo and before it pushes. They can change the description, not the git rules. It diffs against `origin/<base>`, so a local base that is behind adds no commits from others.
