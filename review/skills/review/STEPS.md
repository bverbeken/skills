# Review steps

Shared by `review` and the eight check skills. Each skill says which steps it runs.

## 1. Resolve the target

The argument is a PR number, a GitHub PR link, an issue ID or link, a Linear review link, a branch name, or empty. Strip `--only …` first: only `review` uses it.

Resolve it to: the repo, the code to review (a ref), the base to diff against, the PR (if any) and the issue (if any). The issue tracker is the one the project's `CLAUDE.md` / `AGENTS.md` names. Use the tool or workflow it describes. If the project names none, look for issue IDs anyway and use whatever tracker tool matches them.

| Argument | Code | Base | PR | Issue |
|---|---|---|---|---|
| PR number or GitHub PR link | the PR's head | the PR's base branch | that PR | issue IDs in the PR title, body or branch name |
| Issue ID or link | the PR linked to the issue; without one, the issue's branch, if it exists | as for that PR or branch | the linked PR, if any | that issue |
| Linear review link (`linear.app/<workspace>/review/<slug>`) | `mcp__linear__get_diff` with the link gives the GitHub PR; then as for a PR | | | |
| Branch name | that branch | the default branch | the open PR for the branch, if any | issue IDs in the branch name or commit messages |
| Empty | the current branch, including uncommitted changes | the default branch | as for a branch name | as for a branch name |

For a PR, get its data once: `gh pr view <num> -R <owner>/<repo> --json title,body,author,state,isDraft,baseRefName,headRefName,additions,deletions,changedFiles,commits` and `gh pr checks <num> -R <owner>/<repo>`.

If the argument fits no row, or a ref does not resolve, stop and say what failed.

Then set the **mode**. It is **own** when there is no PR, or the PR's author is the user (`gh api user -q .login`). It is **colleague** otherwise. Own work is reviewed before anyone else sees it, so its bar is much higher: see step 4.

## 2. Find the repo and check out the code

The user should not have to `cd` into the right repo.

For an empty argument, a PR number or a branch name, the repo is the current one: `git rev-parse --show-toplevel`. For a link, a folder matches when `git -C <folder> remote get-url origin` points to `<owner>/<repo>`. Check, in order, and take the first match: the current repo, `./<repo>` and every direct subfolder, `../<repo>` and every direct subfolder of the parent, a folder named for this in `CLAUDE.md`. If nothing matches, stop and say the repo is not checked out nearby.

Review the current branch in place, when the target is the branch that is checked out: `<reviewDir>` is `pwd`. Anything else goes in a worktree, so the user's checkout stays as it is:

1. `<reviewDir>` is `<repoRoot>/../.review-worktrees/<repo>-<pr-<num> or branch name>`. If it exists, remove it: `git -C <repoRoot> worktree remove --force <reviewDir>`.
2. Fetch the code: `git -C <repoRoot> fetch origin pull/<num>/head` for a PR (works for forks too), `git -C <repoRoot> fetch origin <branch>` for a branch.
3. `git -C <repoRoot> worktree add --detach <reviewDir> FETCH_HEAD`.

Leave the worktree in place afterwards, for follow-up questions.

The diff command is `git -C <reviewDir> diff <merge-base>`, where `<merge-base>` is `git -C <reviewDir> merge-base origin/<base> HEAD`. In place, this includes uncommitted changes. Also note `git -C <reviewDir> log --oneline <merge-base>..HEAD`.

If the diff is empty, stop and say so.

Print one line so the user can check the target: `Reviewing <PR #<num> | branch <name>> in <owner/repo> (dir: <reviewDir>)`. Continue without waiting.

## 3. Gather the spec

There is always some spec: everything that says what the change should do. Collect all of it:

- The issue: its description, its comments, and its parent issue if it has one.
- Every link in those that you have a tool for: support conversations, docs, other issues, PRs, designs. Follow them one level deep.
- The PR description and the commit messages.

Write the sources and their content to `<contextFile>`, a file in a new temp folder (`mktemp -d`), together with the target, the mode, `<reviewDir>`, the diff command, the commit list, the PR data and the CI status. List each source by name or link at the top.

If there is no issue, the spec is the PR description and the commit messages. Say so at the top of `<contextFile>`.

## 4. Findings

Report every finding in this form:

```
- check: <tests | spec | bugs | performance | style | refactoring | architecture | consumers>
  level: <blocking | suggestion>
  type: <short label in caps, e.g. MISSING TEST, N+1, DUPLICATION, WRONG LAYER>
  location: <path:line, or the consumer repo and path:line>
  finding: <one sentence: what goes wrong>
  fix: <optional, one sentence>
  evidence: <what you saw that proves it: the code, the spec line, the caller>
  verified: <yes, only when the check's own tool already verified it>
```

**Blocking** means: merging this as it is causes wrong behavior, data loss, a security hole, a broken dependent project, or a spec requirement that is missing without explanation. Breaking a **written repo rule** (a rule in the repo's `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, coding standards, or the files they import) also blocks: quote the rule. Each check skill says which of its other findings can block. Everything else is a suggestion.

Test: if you would tell the user to fix it before merging, it is blocking.

In **own** mode, the check skills' blocking rules are only the floor. A finding also blocks when a careful colleague would comment on it in review: a missing or wrong-level test, an unhandled edge of the input, a query nobody has costed, a spec question, an unclear name. Only pure taste, where a colleague would let it pass, stays a suggestion. Rules like "test findings never block" apply in **colleague** mode only.

Leave out nits: pure polish that changes nothing for the reader or for the behavior.

Judge by what the code will do in production. Check claims in the PR description against the diff.

## 5. Verify blocking findings

For each blocking finding without `verified: yes`, start one `Agent`, all in one message, in the foreground. Give it `<contextFile>` and the finding, and this brief: "Try to prove this finding wrong. Read the code in `<reviewDir>`, the callers and the tests. Answer `REJECTED` only when the failure it describes cannot happen, or, for a finding that is not about a failure (a broken repo rule, a missing test), when what it describes is not true of the code. How likely or how bad the failure is was already decided by the check: leave that alone. Otherwise answer `CONFIRMED`. Add one sentence why."

A confirmed finding stays blocking. A rejected one moves to "Dropped in verification", with the reason.

Wait until every verification agent has answered before you write the report.

## 6. Report

Print the report in the terminal. Post nothing: no `gh pr review`, `gh pr comment`, `gh pr approve`, no tracker comments, no diff review tools. Change no code.

```
## PR #<num>: <title>      (or: ## Branch <name>)
<owner/repo> · +<adds>/-<dels> across <N> files · base: <base> · mode: <own (strict) | colleague>
Spec: <the sources, e.g. ISSUE-12 + 1 support conversation, or: PR description and commits only>
CI: <status from gh pr checks, or: no PR yet>

**Blocking** (verified)
- [<check>] <TYPE> `<location>` — <finding>. Fix: <fix>.

**Suggestions**
- [<check>] <TYPE> `<location>` — <finding>. Fix: <fix>.

**Dropped in verification**
- [<check>] `<location>` — <finding> — <why it was wrong>.

**Checks**: tests <n> · spec <n> · bugs <n> · performance <n> · style <n> · refactoring <n> · architecture <n> · consumers <n> (<what was not checked>)

# GO      (or: # NO GO)
<one line: why>
```

- Merge findings from different checks about the same problem into one line, with all their checks: `[bugs, spec]`. Count it once per check on the "Checks" line.
- Sort blocking findings first, then suggestions, each grouped by check.
- One sentence per finding, plus the optional `Fix:` sentence. The details stay in `evidence`.
- Leave out empty sections, but always print the "Checks" line, with 0 for a check that found nothing.
- `GO` means merge it. `NO GO` means at least one confirmed blocking finding. There is nothing in between.
- The verdict line only says why: the worst blocking finding for NO GO, or that none survived for GO. It gives no advice.
- No praise, no summary beyond the verdict line.
- A check run on its own lists only its own count on the "Checks" line, and ends with `# GO (<check> only)` or `# NO GO (<check> only)`.

Be direct. When you are not sure, say "I'm not sure" and why.
