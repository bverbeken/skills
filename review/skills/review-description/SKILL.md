---
name: review-description
description: "Let an agent read a PR description or an issue cold, with nothing else, and find what a teammate would misread or miss. One of the checks of `review`; other skills run it on a text before it goes out."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below with the PR's title and body as the text, then step 6 for this check only. Without a PR there is no description: stop and say so.
**Run by `review`:** `review` starts the cold read with the other checks, and compares the answer itself. See `../review/SKILL.md`.
**Run by another skill:** that skill wrote the text. It runs the check below on it, including the fix step.

## Check

The text of a PR is its title and body, without the TODO list between the `<!-- ready-for-review:todo -->` markers: `ready-for-review` keeps its working list there.

There are two roles. The **caller** knows the change: the session that wrote the text, or `review` with `<contextFile>`. The **cold reader** is an agent that gets only the text.

1. **Cold read.** Start one `Agent` (general-purpose) and give it only the text: no diff, no issue, no file paths, nothing from the session. The brief: "You are <the reader; default: a developer on this team who knows the system but did not work on this change>. Read the text below. Use no tools. In your own words, say what was wrong or missing, why, and what changes. Then list each sentence you had to read twice, and each fact you needed but did not get." Put the text below the brief.
2. **Compare.** The caller compares the answer with what it knows. Each of these is a finding:
   - **MISREAD**: the reader's explanation differs from what really happens.
   - **GAP**: a fact the reader needed and did not get, or had to guess. A point the reader got right, but only in vague words, is a GAP too.
   - **HARD TO READ**: a sentence the reader had to read twice.
3. **Fix**, only when the caller wrote the text: change the text so each finding goes away. Then run steps 1 and 2 once more on the new text, with a new agent. Report the findings that are left.

Fix a finding in the text, never in the brief: the reader stands for the people who will read the text.

## PR material

Only for a PR's text. The caller checks it against the diff; the cold reader plays no part.

- **NO TEST STEPS**: a person can see or call the change (a UI, an API, a CLI, an email), and the body has no steps to try it. A refactor, a test-only change, a dependency bump with no visible change, or internal code with no entry point a reviewer can reach needs no steps. Automated tests are not test steps.
- **UNCLEAR TEST STEPS**: the steps are not numbered with one action each, do not say where to start (a link, a URL or a command), or do not end with what the reader should see.
- **NO SCREENSHOT**: the diff changes what a user sees (layout, styling, copy on screen, a new or changed UI element, a rendered chart or email), and the body has no image or video: a GitHub attachment, `![...]`, `<img>`, or an `.mp4`/`.mov` link. Behavior that only shows in motion, like dragging or an animation, needs a video.
- **NO BEFORE/AFTER**: the diff changes an existing UI, and the body shows only one side. A new UI needs only the after.

When another skill runs the check on a text it wrote before the PR exists, it fixes the test step findings in the text, and reports screenshot findings to the user as a reminder. The text gets no placeholder for a screenshot.

## Findings

Location: `PR description` or `issue <ID>`. Evidence: the reader's own words, or for PR material the file in the diff that shows the change is visible or callable. Set `verified: yes`: the cold read or the diff is the proof.

## Blocking

A MISREAD blocks: the reader will understand the change wrong. A GAP or HARD TO READ blocks only when the reader then guesses wrong about how the change behaves. Example: the reader can't tell how many points the graph leaves out at its end. A missing issue ID or a long list is a suggestion.

In own mode, every PR material finding blocks: a PR goes public with its screenshots and test steps. In colleague mode, they are suggestions.

Fix a description finding with a direct edit of the PR description. It needs no commit.
