---
name: review-comments
description: "Find every code comment a change adds, and say which test, name or extracted method should replace it. One of the checks of `review`; run it alone for comments only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## The rule

Code has no comments. A comment is not compiled and not run, so it goes stale. A test or a name says the same thing and stays true.

A comment usually means one of these is missing:

- A test that shows the behavior the comment describes.
- A name: a variable, constant or method whose name says what the comment says.

Example:

```java
// 0 means the score has no end
if (score.end() == 0) { ... }
```

becomes a constant `Score.UNBOUNDED` and a test `aFlatScoreHasNoNaturalEnd`. The comment goes.

## Check

Read every line the diff adds or changes, in code and in tests. A comment that was already there and is not touched is not a finding.

For each added comment, report one of these types:

- **COMMENT → TEST**: the comment explains behavior, an edge case or a reason. Name the test that should show it, with a test name that says the same thing as the comment. If that test already exists, the fix is to delete the comment.
- **COMMENT → NAME**: the comment explains what a value, variable or expression means. Give the name that replaces it: a variable, a constant, a type.
- **COMMENT → EXTRACT**: the comment labels a block of code ("// build the request", "// given", "// step 2"). Give the method that block becomes, and its name.
- **COMMENT → DELETE**: the comment repeats the code, is a TODO, or is commented-out code.
- **ALLOWED COMMENT?**: the comment explains something the code cannot show, about code outside this repo. Example: `// Safari 17 drops the first pointer event, see https://bugs.webkit.org/show_bug.cgi?id=12345`. It needs a link to the bug or the source. Without a link it is not in this group.

Javadoc, JSDoc, docstrings and block comments are comments. A file header is a comment.

These are not comments, leave them out:

- Instructions for a tool: `eslint-disable`, `@ts-expect-error`, `noinspection`, `@formatter:off`, `# type: ignore`, `//go:build`, a shebang.
- License headers that the repo puts on every file.
- Strings: log messages, exception messages, test display names.
- Generated files.

## Blocking

ALLOWED COMMENT? is always a suggestion: the user decides whether to keep it.

In own mode, every other finding blocks.

In colleague mode, a finding blocks when the repo writes down a rule against comments. Quote the rule. Otherwise it is a suggestion.
