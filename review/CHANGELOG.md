# Changelog

Changes in what the review skills do, newest first. Wording-only changes are left out.

## 2026-10-26

- `ready-for-review`: a human thread with a DISCUSS or CLARIFY verdict is a problem, also when it is a review body or a PR comment, so it never goes ready unanswered.
- `ready-for-review`: answers a review body or a PR comment with a PR comment, since those have no thread to reply in.
- `ready-for-review`: takes an issue as an argument. When it marks a PR ready, it moves that issue, or the PR's issue, to the review status that the issue tracker docs name.
- `ready-for-review --afk`: makes a PR ready with nobody watching. It asks nothing and takes its own recommendation. It rebases on merge conflicts and pushes with `--force-with-lease`. It answers your threads, and resolves the ones that are already fixed, each reply starting with `🤖 `. Suggestions it skips, suggestions outside the PR and suggestions from its last review round go to a `## Skipped: your call` section. What only you can decide is skipped, so the PR stays in draft as NOT READY.
- `review-dependencies`: a dependency without a license, or with a custom one, gets a LICENSE finding instead of a question to you. It blocks when the dependency runs in the product.
- `review`: a PR comment under your login that starts with `🤖 ` is the build's, not yours. On your own PR, a thread where the build has the last word waits for you. When you answer, it goes back to triage.
- No longer a Claude Code plugin. Install the skills by linking their folders into `~/.claude/skills/`, see the README. The skill names lose their `review:` prefix: `/review 142` instead of `/review:review 142`.

## 2026-10-24

- `review-dependencies`: a new check. For each dependency a change adds, in any manifest, CI file or script, it says why this one, whether it is maintained, whether it can be trusted, whether its license is allowed, and which alternatives exist. The report lists each new dependency on one line. A sign of a supply chain attack, a known vulnerability the code can reach, or a license that is not allowed in the product blocks, also in own mode. A version bump is not a new dependency.

## 2026-10-16

- `review-description`: checks a PR for screenshots and test steps. A visible UI change needs a screenshot, with a before and an after when it changes an existing UI. A change a person can see or call needs numbered test steps with a place to start and a result to see. On your own PR these findings block, so the PR goes public with them.
- `ready-for-review`: asks you when a fix needs something only you can make, such as a screenshot.
- Rules in force: a `CLAUDE.md` or `AGENTS.md` in a folder above the repo now counts too, for example a workspace that holds many repos.
- `review-tests`: a new finding, MISSING LEVEL. The repo's written rule asks for a test at a certain level, for example an end-to-end test for a UI change, and the diff has none. It is always a suggestion.
- `review-style`: a new finding, DEBUG LEFTOVER: an added `console.log`, `debugger`, `print` or focused test (`.only`, `fit`). It always blocks.
- `review-bugs`: looks for hardcoded secrets in every added line. A SECRET always blocks.
- `ready-for-review`: now fixes what the review finds. It writes a TODO checklist in the PR description, fixes the items one by one (blocking first), and asks you when a fix needs your choice. Before marking the PR ready, it removes the ticked items, so the public description shows only the change.
- `ready-for-review`: replies briefly to each open Copilot thread and resolves it, also when the comment is not worth fixing. Only Copilot comments worth fixing keep the PR in draft. Open threads from people still do.
- `review-description`: skips the TODO list that `ready-for-review` keeps in the PR description.
- `review-comments`: a new check. It lists every comment a change adds and says which test, name or extracted method should replace it. Only a comment about code outside the repo, with a link (for example a browser bug), can stay, and you decide. On your own work every other comment blocks.
- `review-style`: leaves comments to `review-comments`.

## 2026-10-15

- `review-description`: a new check. An agent reads the PR description with nothing else, and says in its own words what was wrong, why, and what changes. What it misreads or misses becomes a finding. `review` runs it only on a PR. Other skills can run it on a text they wrote, such as a PR description or an issue.
- `ready-for-review`: also runs `review-description`. On your own PR every finding counts, so a description a teammate would misread or find unclear keeps the PR in draft.
- `ready-for-review`: Claude can now start it on its own, for example when you say a PR is ready. Before, only `/ready-for-review` started it.
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
