---
name: review-dependencies
description: "Judge every dependency a change adds: why this one, is it maintained, can we trust it, is its license allowed, and what are the alternatives. One of the checks of `review`; run it alone for dependencies only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings and the dependency lines.

## Check

### 1. Find the new dependencies

A **new dependency** is code from outside the repo that the base branch does not use anywhere. Look in every file the diff adds or changes, in any folder:

- Package manifests: `package.json`, `pom.xml`, `build.gradle(.kts)`, `go.mod`, `requirements*.txt`, `pyproject.toml`, `Gemfile`, `Cargo.toml`, `composer.json`, `*.csproj`, and the like.
- CI and build files: a GitHub Action in `uses:`, a Docker base image in `FROM`, a Maven or Gradle plugin.
- Scripts that download and run code: `curl … | sh`, a binary fetched by URL, `npx <package>`, `pip install` in a script.

A version bump of a dependency the base branch already has is not new. A dependency that another module or manifest in the repo already uses is not new either. Neither is a runtime version, such as the Node version in `setup-node`.

If there is no new dependency, return `none`.

### 2. Research each one

For each new dependency, find out what it is and where it runs:

- **Runs in**: the product (shipped to users or servers), or only in the build, CI or tests. This sets the bar for the license and the security points below.
- **Pulls in**: the packages one machine installs from the lockfile. Count them, and name the ones with install scripts (`preinstall`, `postinstall`). An optional package per platform, such as `@squawk-cli/linux-x64`, counts once.

Then answer these five questions. Use the registry (`npm view <pkg> --json`, Maven Central, PyPI, pkg.go.dev, …), its source repo (`gh repo view`, `gh api repos/<owner>/<repo>`), and the web. Give a fact with a date or a number for each answer.

1. **Why this one.** The PR, the issue or the commits say why. The repo has nothing that does the same job: an existing dependency, the standard library, or a few lines of own code. The change uses enough of it to justify it, rather than one helper from a large library.
2. **Maintained.** Date of the last release and of the last commit. Number of people who released or committed in the past year. Open issues and pull requests, and whether someone answers them. Repo archived or marked deprecated.
3. **Trustworthy.** Who publishes it: a known organization or one person. Downloads per week and dependents. The registry package links to the source repo, and the source matches. A release built in CI with provenance (`npm view <pkg>@<version> dist.attestations`) counts in its favor, also for a package from one person. Look for signs of a supply chain attack: a name close to a popular package (typosquatting), a recent change of owner, a new install script, a version published after a long silence. Known vulnerabilities in the version the PR uses: query OSV (`curl -s https://api.osv.dev/v1/query -d '{"package":{"name":"<pkg>","ecosystem":"<npm|Maven|PyPI|Go|…>"},"version":"<version>"}'`) and the GitHub advisories (`gh api "/advisories?affects=<pkg>"`). An empty answer from both means no known vulnerabilities. The OpenSSF Scorecard of the source repo, if it has one (`curl -s https://api.securityscorecards.dev/projects/github.com/<owner>/<repo>`). The version is pinned, and the lockfile is updated.
4. **License allowed.** The license in the registry and in the source repo, and of the packages it pulls in. The project's `CLAUDE.md` or `AGENTS.md` may state which licenses are allowed. Without such a rule, use this default:
   - Allowed everywhere: MIT, BSD, ISC, Apache-2.0, and other permissive licenses.
   - Allowed in the product only as an unmodified library: MPL-2.0, LGPL, EPL.
   - Allowed only in the build, CI or tests: GPL, AGPL, SSPL, BUSL, and other copyleft or source-available licenses.
   - No license, or a custom one: not allowed until the user says where it may run.
5. **Alternatives.** Name up to three other options for the same job, including the standard library, own code, or the same tool installed another way (a GitHub Action, a release binary). Compare them on fit, maintenance, trust and license, in one line each. Name an alternative as better only when it wins on a point that matters here.

Do the research for several dependencies in parallel: start one `Agent` per dependency when there are more than two.

### 3. Return

Return one **dependency line** per new dependency, in this form:

```
- <name> <version> (<ecosystem>, <runs in>, +<n> packages) — why: <one phrase> · maintained: <last release, maintainers> · trust: <publisher, downloads, vulnerabilities> · license: <license, allowed or not> · alternatives: <names, or none better>
```

Turn every problem into a finding in the form of step 4 of `STEPS.md`, at the line in the manifest or file that adds the dependency:

- **VULNERABLE**: a known vulnerability in the version it uses, with no fix in that version.
- **SUSPICIOUS**: a sign of a supply chain attack from question 3.
- **LICENSE**: a license that is not allowed where the dependency runs.
- **UNMAINTAINED**: archived, deprecated, or no release and no answer to issues for over a year.
- **DUPLICATE**: the repo already has a dependency or own code that does the same job.
- **UNEXPLAINED**: the PR, issue and commits do not say why it is needed, and the reason is not clear from the code.
- **BETTER ALTERNATIVE**: an alternative wins on a point that matters here.
- **HEAVY**: it pulls in many packages, or install scripts, for a small part of what it offers.
- **UNPINNED**: no fixed version or no lockfile update, so a build can pull a different version.

## Blocking

These block, also in own mode:

- SUSPICIOUS, always.
- VULNERABLE, when the code can reach the vulnerable part. For a tool in the build, CI or tests, that means input from a PR or secrets in CI can reach it. When nothing can reach it, it is a suggestion: say why.
- LICENSE, when the dependency runs in the product.

Everything else is a suggestion.
