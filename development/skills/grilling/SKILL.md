---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a **design tree**: every decision branches into the decisions that hang off it.

Ask **one question at a time**. Never put two questions in one message. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask _now_ without guessing at answers you haven't heard yet. From the frontier, pick the single most important question, ask it with your recommended answer, and wait for the user's answer before asking the next one.

Pick the question with the most other decisions hanging off it first. Its answer prunes or reshapes the most of the tree.

Number questions across the whole session (Q1, Q2, Q3, …). Format each question like so:

```
❓ **Q<n>** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

Word each question so "yes" accepts your recommended answer.

Write every question in your visible reply, in the format above. The user can't see your thinking, so a question that is only in your thinking was never asked.

Write out each option in full in the question body, e.g. "A: core builds the HTML, the webapp shows it. B: the webapp builds the HTML." When you mention an option later, repeat what it says, not only its letter.

When you start a sub-agent, ask the question in the same message, before the tool call.

When you remind the user of an open question, repeat it in full.

Each answer reshapes the tree: a settled decision pushes the frontier outward, unblocks questions that depended on it, and can make other questions moot. Recompute the frontier after every answer, then ask the next question.

Finding _facts_ is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it; don't ask the user for anything you could look up yourself. Don't block on it: while the sub-agent runs, keep asking questions that don't depend on its result. The _decisions_ are the user's: put each to them and wait.

When the plan is code that runs on several servers at once, or depends on a shared service (a database, a cache, a queue), its tree always has these three branches. Visit each one, even when the simplest design looks done:

- **Same moment:** two servers run this at the same time. What do they lock, in what order, and what can they overwrite?
- **Outage:** the shared service is slow or down. What does each server do, and what data is lost?
- **Load:** what does each server read and write per minute, at the busiest moment? Count reads too, not only writes.

When the plan reads or groups data over a time range, its tree always has these three branches too:

- **Edges:** `from` or `to` falls inside a bucket. What do the first and the last bucket hold?
- **Now:** the range ends at the current moment. What does the bucket that is still filling show?
- **Largest request:** what is the longest range one request may ask for, and what does that one read cost? Decide this separately from how long the data is kept.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding. When the skill that called you says it asks for the confirmation itself, skip this question and hand back to it.
