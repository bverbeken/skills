# Changelog

Changes in what the development skills do, newest first. Wording-only changes are left out.

## 2026-10-26

- `prepare` and `grilling`: you confirm the decisions once, when `prepare` shows the text it will write. `grilling` skips its closing question when the skill that called it asks for the confirmation itself.
- `draft-pr`: no longer runs its own quick review, which repeated the checks of `review`. The cold read of the description finds `review-description` again: its path pointed to a folder that no longer exists.
- `tdd`: a seam named in the issue's `## Decisions` counts as confirmed. It asks about other seams through `prepare`. With `--afk`, it picks them itself and `implement` lists them in the PR description.
- `implement --afk`: builds with nobody watching. It asks nothing and takes its own recommendation. It skips `prepare` and its own review: after the build it opens a draft PR and calls `ready-for-review --afk`. A decision that only the user can make goes in the issue's open question section, and the build stops.
- `implement`: assigns the issue only when the issue tracker docs say issues have an assignee.
- New: `implement`, `tdd`, `prepare`, `grilling`, `codebase-design` and `draft-pr`.
- `draft-pr`: reads the project's own PR rules, from the doc that a `CLAUDE.md` or `AGENTS.md` in the repo or a folder above it names. It reads them after it checks the repo and before it pushes. They can change the description, not the git rules. It diffs against `origin/<base>`, so a local base that is behind adds no commits from others.
