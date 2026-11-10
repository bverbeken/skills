# development

Skills for building software with an agent, from an issue to a draft PR. `prepare` asks you every open decision of an issue and writes your answers in it. `implement` builds the issue test-first in its own git worktree. `draft-pr` pushes the branch and opens a draft PR. Call them one by one, or from your own skill.

## The skills

| Skill | What it does |
|---|---|
| `implement` | Builds an issue or a spec with `tdd` in a separate worktree, one commit per step, and fixes the review findings it gets. Before it creates a worktree, it removes the local branches whose PR is merged, with their worktrees. It asks a new open decision through `prepare`. It stops when a test fails or hangs for a reason outside the change, such as a database version, and never works around it. |
| `prepare` | Lists the decisions an issue leaves open, asks you about them with `grilling`, and writes your answers in the issue under `## Decisions`. |
| `grilling` | Asks you one question at a time, with a recommended answer, until every decision is settled. |
| `tdd` | The red → green loop: what a good test is, where tests go, one commit per green cycle, and a time limit on every test run. |
| `codebase-design` | Shared words for designing deep modules: module, interface, depth, seam, adapter. |
| `draft-pr` | Pushes the branch and opens a draft PR, with a description written from the commits and the diff. |

`draft-pr` uses `review-description`, from the [review](../review/) skills in this repo. Install those too.

## Install

Link the skill folders into `~/.claude/skills/`, together with the review skills. The steps are in the [README of this repo](../README.md#install). [`CHANGELOG.md`](CHANGELOG.md) lists what changed.

## Set up your project

The skills use the files that your project's `CLAUDE.md` or `AGENTS.md` points to. For example:

```markdown
## Agent skills

The issue tracker is described in `docs/agents/issue-tracker.md`.
The rules for pull requests are in `docs/agents/pull-requests.md`.
The review settings are in `docs/agents/review-settings.md`.
```

- `docs/agents/issue-tracker.md`: where issues live, how to read and change them, which of its statuses each [Faber status](#faber-statuses) maps to, where a stopped build writes its open question, where an issue's PR link lives, which issues are Faber's, and who reviews your PRs (`Reviewer: me` or `Reviewer: team`). When the docs don't say which issues are Faber's, every issue is. `implement`, `prepare`, `review` and `ready-for-review` read it.
- `docs/agents/pull-requests.md` (optional): your own rules for PR descriptions, for example what the test steps look like per repo. `draft-pr` reads it.
- `docs/agents/review-settings.md` (optional): review settings, one `key: value` per line. With `screenshots: required`, a missing screenshot, before/after or video blocks your own PRs. Without it, they are suggestions. `review-description` reads it.

### Test time limit

`tdd` and `implement` stop every test run after 10 minutes, so a hanging test can't hold a build for hours. When your tests need longer, set your own limit next to the test command, in your `README.md`, `CLAUDE.md` or `AGENTS.md`:

```markdown
Full suite: `./gradlew test`, limit 30 minutes.
```

A limit over 10 minutes runs the tests in the background inside `timeout`. On macOS, install it with `brew install coreutils`. Without it, such a run stops the build as a setup failure.

Finding a hanging test takes at most three runs at the limit: the run that hangs, a run of only the tests the change added or changed when the output names no test, and a run on the base for an existing test. A hang outside the change then stops the build. A hang the change caused is a failing test, and `tdd` fixes it like any other.

## Faber statuses

The skills name statuses with fixed UPPERCASE names:

| Faber status | Meaning |
|---|---|
| `USEFUL` | worth doing, not planned yet |
| `BLOCKED` | planned, but a blocker is not `MERGED` or `DONE` yet |
| `TO_CLARIFY` | to prepare: open decisions, or an open question from a stopped build |
| `NEXT_UP` | prepared, you give the go: it can be built |
| `BUSY` | being built: by an agent, by you or by a teammate |
| `READY_FOR_REVIEW` | the PR is ready for your review |
| `READY_TO_MERGE` | you approved the PR: you merge it on GitHub |
| `MERGED` | merged: the docs, changelog and release are left |
| `DONE` | done: merged, with the docs, changelog and release |

Your tracker docs map each one to a status of your own, in any format. For example, a table with a column for the Faber status:

| Faber | Status | Meaning |
|---|---|---|
| `BUSY` | `In Progress` | being built |

A mapping can carry a condition, for example `NEXT_UP: Todo, assigned to me`. A move to that status also sets the condition. An issue is only in that status when the condition holds. When two Faber statuses map to the same tracker status, only the condition tells them apart, so a move between them changes the condition: with `TO_CLARIFY: Todo, not assigned to me` and `NEXT_UP: Todo, assigned to me`, a move to `TO_CLARIFY` removes the assignee.

A status counts as mapped only when your docs map it, also when your tracker has a status with the same name. A tracker can leave a status out when you call the skills yourself. A skill that would move an issue to that status leaves the issue where it is, and says so at the end. A skill that checks for that status stops and changes nothing.

## Credits

`implement`, `tdd`, `grilling` and `codebase-design` come from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, © Matt Pocock), commit `49dd158` (2026-10-09). Each has Matt's license in its folder. `prepare` and `draft-pr` are mine.

| Skill | Upstream path | Changes |
|---|---|---|
| codebase-design | skills/engineering/codebase-design | none |
| grilling | skills/productivity/grilling | asks one question at a time (most decisions depending on it first), not a full round; skips its closing question when the calling skill confirms itself |
| implement | skills/engineering/implement | only builds: the review and the PR are separate steps; fixes the review findings it gets; removes the local branches whose PR is merged, with their worktrees, before it creates a worktree; commits as it goes, one small commit per step, instead of once at the end; asks a new open decision through `prepare`; stops on a setup failure, or an existing test that also hits its time limit on the base, and never works around it; `--afk` builds without asking |
| tdd | skills/engineering/tdd | refers to `review` instead of `code-review`; adds the rule "commit on green" (one commit per cycle); takes confirmed seams from the issue's `## Decisions` and asks about others through `prepare`, or picks them itself with `--afk`; runs every test run with a time limit |
