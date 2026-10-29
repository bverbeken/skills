---
name: review-dependencies
description: "Judge every dependency a change adds: why this one, is it maintained, can we trust it, is its license allowed, and what are the alternatives. One of the checks of `review`; run it alone for dependencies only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

This check has two parts. This file finds the new dependencies. `DEPENDENCY.md`, next to it, researches one dependency and returns its dependency line and findings. "Item agents" in step 4 of `../review/STEPS.md` (next to this skill's folder) says how the item agents start.

**Run alone:** read `../review/STEPS.md`. Run its steps 1 to 3, then the check below. Then start the item agents for the dependencies it finds, with `DEPENDENCY.md` as the check file. Wait until they have returned, then run steps 5 and 6 for this check only, with their dependency lines in the "New dependencies" section.
**Run by `review`:** run only the check below and return its list.

## Check

Find the new dependencies.

A **new dependency** is code from outside the repo that the base branch does not use anywhere. Look in every file the diff adds or changes, in any folder:

- Package manifests: `package.json`, `pom.xml`, `build.gradle(.kts)`, `go.mod`, `requirements*.txt`, `pyproject.toml`, `Gemfile`, `Cargo.toml`, `composer.json`, `*.csproj`, and the like.
- CI and build files: a GitHub Action in `uses:`, a Docker base image in `FROM`, a Maven or Gradle plugin.
- Scripts that download and run code: `curl … | sh`, a binary fetched by URL, `npx <package>`, `pip install` in a script.

A version bump of a dependency the base branch already has is not new. A dependency that another module or manifest in the repo already uses is not new either. Neither is a runtime version, such as the Node version in `setup-node`.

Return one line per new dependency: `<name> <version> (<ecosystem>) at <path:line>`, where the line is the one in the manifest or file that adds it. If there is no new dependency, return `none`.

## Blocking

These block, also in own mode:

- SUSPICIOUS, always.
- VULNERABLE, when the code can reach the vulnerable part. For a tool in the build, CI or tests, that means input from a PR or secrets in CI can reach it. When nothing can reach it, it is a suggestion: say why.
- LICENSE, when the dependency runs in the product.

Everything else is a suggestion.
