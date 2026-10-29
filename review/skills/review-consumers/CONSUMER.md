# Check the consumers you got

Check the consumers you got, one after the other: each is a project that depends on the code the change touches, with its local checkout. Set the level of each finding by the "Blocking" section of `SKILL.md`, next to this file.

## 1. Check out its default branch

Check each consumer on its default branch, never on the branch the user has checked out:

1. `gh repo view <owner>/<consumer> --json defaultBranchRef -q .defaultBranchRef.name`
2. `git -C <consumerRoot> fetch origin <defaultBranch>`
3. `<consumerDir>` is `<consumerRoot>/../.review-worktrees/<consumer>-<defaultBranch>`. If it exists, remove it: `git -C <consumerRoot> worktree remove --force <consumerDir>`.
4. `git -C <consumerRoot> worktree add --detach <consumerDir> FETCH_HEAD`

When a step fails, return `not checked: <consumer> (<reason>)` for that consumer.

## 2. Search it

Search `<consumerDir>` for code that uses what the change touches, and decide whether it breaks.

## 3. Return

Report each break as a **BREAKS** finding with the consumer's path and line, in the form of step 4 of `STEPS.md`. Return `none` for a consumer without a break.
