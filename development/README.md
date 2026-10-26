# development

Skills for building software with an agent, from an issue to a draft PR. Say `/implement ACME-123` and Claude asks you every open decision, builds the change test-first in its own git worktree, reviews it, and opens a draft PR.

## The skills

| Skill | What it does |
|---|---|
| `implement` | Builds an issue or a spec: asks its questions through `prepare`, builds with `tdd` in a separate worktree, runs `review`, and ends with `draft-pr`. |
| `prepare` | Lists the decisions an issue leaves open, asks you about them with `grilling`, and writes your answers in the issue under `## Decisions`. |
| `grilling` | Asks you one question at a time, with a recommended answer, until every decision is settled. |
| `tdd` | The red → green loop: what a good test is, where tests go, and one commit per green cycle. |
| `codebase-design` | Shared words for designing deep modules: module, interface, depth, seam, adapter. |
| `draft-pr` | Pushes the branch and opens a draft PR, with a description written from the commits and the diff. |

`implement` and `tdd` call `review`, from the [review](../review/) skills in this repo. Install those too.

## Install

Clone the repo and link each skill folder into `~/.claude/skills/`, together with the review skills:

```bash
git clone https://github.com/bverbeken/skills.git ~/skills
mkdir -p ~/.claude/skills
for skill in ~/skills/development/skills/* ~/skills/review/skills/*; do
  ln -s "$skill" ~/.claude/skills/
done
```

A `git pull` then updates the skills. [`CHANGELOG.md`](CHANGELOG.md) lists what changed.

## Set up your project

The skills use the files that your project's `CLAUDE.md` or `AGENTS.md` points to. For example:

```markdown
## Agent skills

The issue tracker is described in `docs/agents/issue-tracker.md`.
The rules for pull requests are in `docs/agents/pull-requests.md`.
```

- `docs/agents/issue-tracker.md`: where issues live, how to read and change them, and which status means "in progress" and "ready". `implement`, `prepare` and `review` read it.
- `docs/agents/pull-requests.md` (optional): your own rules for PR descriptions, for example what the test steps look like per repo. `draft-pr` reads it.

## Credits

`implement`, `tdd`, `grilling` and `codebase-design` come from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT, © Matt Pocock), commit `49dd158` (2026-10-09). Each has Matt's license in its folder. `prepare` and `draft-pr` are mine.

| Skill | Upstream path | Changes |
|---|---|---|
| codebase-design | skills/engineering/codebase-design | none |
| grilling | skills/productivity/grilling | asks one question at a time (most decisions depending on it first), not a full round |
| implement | skills/engineering/implement | calls `review` instead of `code-review`, and fixes its blocking findings; commits as it goes, one small commit per step, instead of once at the end; asks its questions through `prepare` |
| tdd | skills/engineering/tdd | refers to `review` instead of `code-review`; adds the rule "commit on green" (one commit per cycle) |
