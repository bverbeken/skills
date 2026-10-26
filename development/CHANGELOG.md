# Changelog

Changes in what the development skills do, newest first. Wording-only changes are left out.

## 2026-10-26

- `implement`, `tdd`, `prepare`, `grilling`, `codebase-design` and `draft-pr` moved here from my private skills repo.
- `draft-pr`: reads the project's own PR rules, from the doc that a `CLAUDE.md` or `AGENTS.md` in the repo or a folder above it names. It reads them after it checks the repo and before it pushes. They can change the description, not the git rules. It diffs against `origin/<base>`, so a local base that is behind adds no commits from others.
