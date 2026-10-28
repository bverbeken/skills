# development

Skills for building software with an agent, from an issue to a merged PR. Say `/foreman ACME-123` and Claude does the next step for that issue, based on its status. An issue to clarify gets your open decisions asked. A ready issue gets built test-first in its own git worktree, reviewed, and ends as a PR that is ready for review. An approved issue gets merged. Say `/foreman ACME-123 --afk` and Claude asks nothing: it keeps going until the issue waits on you.

## The skills

| Skill | What it does |
|---|---|
| `foreman` | Does the next step for an issue, based on its status: `prepare` for an issue to clarify, a build up to a PR that is ready for review, `ready-for-review` for new review threads, `merge` for an approved issue. With `--afk`, it asks nothing and keeps going until the issue waits on you. `/foreman` without an issue, or `/foreman status`, lists the issues in the pipeline and marks the ones that wait on you. |
| `implement` | Builds an issue or a spec with `tdd` in a separate worktree, one commit per step, and fixes the review findings it gets. It asks a new open decision through `prepare`. |
| `prepare` | Lists the decisions an issue leaves open, asks you about them with `grilling`, and writes your answers in the issue under `## Decisions`. |
| `grilling` | Asks you one question at a time, with a recommended answer, until every decision is settled. |
| `tdd` | The red → green loop: what a good test is, where tests go, and one commit per green cycle. |
| `codebase-design` | Shared words for designing deep modules: module, interface, depth, seam, adapter. |
| `draft-pr` | Pushes the branch and opens a draft PR, with a description written from the commits and the diff. |
| `merge` | Merges the PR of an approved issue with a rebase merge, tests the merged code, closes the issue with a result, and removes the worktree and the branch. |

`foreman` calls `review` and `ready-for-review`, from the [review](../review/) skills in this repo. Install those too.

## Install

Link the skill folders into `~/.claude/skills/`, together with the review skills. The steps are in the [README of this repo](../README.md#install). [`CHANGELOG.md`](CHANGELOG.md) lists what changed.

## Set up your project

The skills use the files that your project's `CLAUDE.md` or `AGENTS.md` points to. For example:

```markdown
## Agent skills

The issue tracker is described in `docs/agents/issue-tracker.md`.
The rules for pull requests are in `docs/agents/pull-requests.md`.
```

- `docs/agents/issue-tracker.md`: where issues live, how to read and change them, which of its statuses each [factory status](#factory-statuses) maps to, where a stopped build writes its open question, and where an issue's PR link lives. `foreman`, `implement`, `prepare`, `review`, `ready-for-review` and `merge` read it.
- `docs/agents/pull-requests.md` (optional): your own rules for PR descriptions, for example what the test steps look like per repo. `draft-pr` reads it.

## Factory statuses

The skills name statuses with fixed UPPERCASE names:

| Factory status | Meaning |
|---|---|
| `BACKLOG` | worth doing, not planned yet |
| `BLOCKED` | planned, but a blocker is not `DONE` yet |
| `TO_CLARIFY` | to prepare: open decisions, or an open question from a stopped build |
| `READY` | prepared, you give the go: it can be built |
| `BUSY` | being built, by you or by `foreman` |
| `REVIEW` | the PR is ready for your review |
| `APPROVED` | you approve the PR: it can be merged |
| `DONE` | merged |

Your tracker docs map each one to a status of your own, in any format. For example, a table with a column for the factory status:

| Factory | Status | Meaning |
|---|---|---|
| `BUSY` | `In Progress` | being built |

A mapping can carry a condition, for example `READY: Next Up, assigned to me`. A move to that status also sets the condition. An issue is only in that status when the condition holds. When two factory statuses map to the same tracker status, only the condition tells them apart, so a move between them changes the condition: with `TO_CLARIFY: Next Up, not assigned to me` and `READY: Next Up, assigned to me`, a move to `TO_CLARIFY` removes the assignee.

A status counts as mapped only when your docs map it, also when your tracker has a status with the same name. A tracker can leave a status out when you call the skills by hand. `foreman` needs all 8, and refuses when one is missing. A skill that would move an issue to that status leaves the issue where it is, and says so at the end. A skill that checks for that status stops and changes nothing: `merge` doesn't merge when your tracker has no `APPROVED`.

## Credits

`implement`, `tdd`, `grilling` and `codebase-design` come from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, © Matt Pocock), commit `49dd158` (2026-10-09). Each has Matt's license in its folder. `foreman`, `prepare`, `draft-pr` and `merge` are mine.

| Skill | Upstream path | Changes |
|---|---|---|
| codebase-design | skills/engineering/codebase-design | none |
| grilling | skills/productivity/grilling | asks one question at a time (most decisions depending on it first), not a full round; skips its closing question when the calling skill confirms itself |
| implement | skills/engineering/implement | only builds: `foreman` runs the review and the PR steps; fixes the review findings it gets; commits as it goes, one small commit per step, instead of once at the end; asks a new open decision through `prepare`; `--afk` builds without asking |
| tdd | skills/engineering/tdd | refers to `review` instead of `code-review`; adds the rule "commit on green" (one commit per cycle); takes confirmed seams from the issue's `## Decisions` and asks about others through `prepare`, or picks them itself with `--afk` |
