# Changelog

Changes in what the review skills do, newest first. Wording-only changes are left out.

## 2026-10-15

- `review`: handles PRs that already have comments. On your own PR it checks every open thread against the code and drafts a reply, and checks resolved threads again. On a colleague's PR it rechecks your answered threads and answered bot threads, and drops findings that were already settled. Findings already in a thread are not reported twice.
- `review`: drafts paste-ready replies for threads, and on a colleague's PR a comment for each new finding.
- `re-review`: removed. `review` does what it did.
- `ready-for-review`: new skill. It takes your own draft PR out of draft, only when the strict review finds nothing at all and CI, conflicts, review threads and local changes are clean.
- `review`: own work is now reviewed strictly. When the PR is yours, or there is no PR, anything a careful colleague would comment on results in **NO GO**. A colleague's PR keeps the normal bar.
- `review`: breaking a written repo rule (in `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md` or the coding standards) now blocks, in both modes. The finding quotes the rule.
- `review`: the report header shows the mode: `own (strict)` or `colleague`.
- `review-tests`: WRONG LEVEL now follows the repo's written testing rule first. That rule wins over the existing tests and over the issue text. A test at the wrong level blocks.
- `review-style`: STANDARD findings now block.
- `review-bugs`: test findings from `/code-review` are kept and reported under `tests`. Before, they were dropped.
- `review-performance`: new check, LARGEST REQUEST. It estimates what the biggest single request the code allows reads, for example the longest date range.

## 2026-10-14

- `re-review`: new skill. After you reviewed a PR and the author answered, it checks only the answered threads and ends with GO / NO GO.
- `review`: points you to `re-review` when you reviewed the PR before.
- `review`: replaces `review-pr`. Eight checks run in parallel, every blocking finding is verified by a separate agent, and the report ends with GO / NO GO.
