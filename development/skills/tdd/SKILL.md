---
name: tdd
description: Test-driven development. Use when the user wants to build features or fix bugs test-first, mentions "red-green-refactor", or wants integration tests.
---

# Test-Driven Development

TDD is the red → green loop. This skill is the reference that makes that loop produce tests worth keeping: what a good test is, where tests go, the anti-patterns, and the rules of the loop. Every section applies on every cycle: consult them before and during the loop, not after.

When exploring the codebase, read `GLOSSARY.md` (if it exists) so test names and interface vocabulary match the project's domain language, and respect ADRs in the area you're touching.

## What a good test is

Tests verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't. A good test reads like a specification: "user can checkout with valid cart" tells you exactly what capability exists, and it survives refactors because it doesn't care about internal structure.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Seams: where tests go

A **seam** is the public boundary you test at: the interface where you observe behavior without reaching inside. Tests live at seams, never against internals.

**Test only at pre-agreed seams.** Before writing any test, write down the seams under test and confirm them. No test is written at an unconfirmed seam. You can't test everything, so agreeing the seams up front is how testing effort lands on the critical paths and complex logic instead of every edge case.

A seam that the issue's `## Decisions` section names is confirmed. For every other seam, ask: "What's the public interface, and which seams should we test?" With an issue or spec, ask it through the Skill tool with "prepare", the issue reference or spec, `--keep-status` and the question. Without one, ask the user directly. Give each proposed seam a one-line note on what it catches and what it misses.

With `--afk`, pick those seams yourself and give the caller the list, one line per seam with what it catches.

When the shape of that interface is itself in question (how deep the module is, where the seam belongs, what the interface should expose), call the Skill tool with "codebase-design" for the vocabulary. It is the shared source of the module, interface, depth, seam, adapter, leverage and locality terms, and it is a reference to consult, not a session to run.

## Anti-patterns

- **Implementation-coupled**: mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). The tell: the test breaks when you refactor but behavior hasn't changed.
- **Tautological**: the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth: a known-good literal, a worked example, the spec.
- **Horizontal slicing**: writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead: one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.

## Test runs

Every test run has a time limit. The default is 10 minutes. A repo can set its own limit next to its test command, in its `README.md`, `CLAUDE.md` or `AGENTS.md`, for example "Full suite: `./gradlew test`, limit 30 minutes."

- A limit of 10 minutes or less: run the tests in the foreground, with the Bash tool's `timeout` set to the limit.
- A longer limit: run the tests in the background, inside `timeout -k 1m <limit>`, for example `timeout -k 1m 30m ./gradlew test`. With `-k 1m`, `timeout` kills the run one minute after the limit when a test ignores the stop signal. On macOS, `timeout` comes from `brew install coreutils`. When `timeout` is missing, the cause is outside the change, as below.

Wait for the notice that the run ended or hit its limit. A poll loop with `sleep` and no end can hold a build for hours.

When a run hits its limit, find the tests that hang. The last lines of output often name the tests that were still running. When they name none, run only the tests this change added or changed, with the same limit. When that run ends in time, the hang is in an existing test.

- Only tests this change added or changed: count it as a failing test, with the reason "timed out", and make it pass in the loop.
- An existing test, while the branch has no commits of its own and no uncommitted changes: the cause is outside the change.
- Any other existing test: run it once on the commit the branch started from, with the same limit, in a detached worktree, with the ignored setup files and the installs of steps 4 and 5 of `Worktree` in `implement`. When it passes there, the change made it hang: count it as a failing test, with the reason "timed out", and make it pass in the loop. When it hangs or fails there too, the cause is outside the change.

When the cause is outside the change, stop the loop. In a build, `implement` handles it as a setup failure. Called on its own, show the user the command, the limit and the last lines of output, and ask.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Commit on green.** Each cycle ends in its own commit: the new test plus the code that makes it pass.
- **Refactoring is not part of the loop.** It belongs to the review stage (see the `review` skill), not the red → green implementation cycle.
