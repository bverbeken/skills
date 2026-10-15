---
name: review-performance
description: "Look for performance problems in a change: slow queries, wasted work, load on shared services. One of the checks of `review`; run it alone for performance only."
argument-hint: "[PR number | PR link | issue | branch | empty]"
disable-model-invocation: true
---

**Run alone:** read `../review/STEPS.md` (next to this skill's folder). Run its steps 1 to 3, then the check below, then steps 5 and 6 for this check only.
**Run by `review`:** run only the check below and return the findings.

## Check

Read the changed code and what it calls. Look for:

- **N+1**: a query or remote call inside a loop.
- **UNBOUNDED**: a query or read without a limit or pagination, on data that grows.
- **MISSING INDEX**: a new query that filters or sorts on columns with no index. Check the schema and migrations.
- **WASTED WORK**: the same work done twice, work inside a loop that could happen once, a whole table or file loaded to use a small part.
- **BLOCKING CALL**: a slow or remote call on a path that serves user requests, where the project does such work in the background.
- **COMPLEXITY**: a nested loop or a search on data that grows with customers, events or time.
- **LOAD**: code that runs on several servers or uses a shared service (database, cache, queue). Estimate what each server reads and writes per minute at the busiest moment. Count reads too.
- **LARGEST REQUEST**: the biggest single request the code allows, for example the longest date range or the largest page size. Estimate the rows and pages it reads with a cold cache, and whether an index alone can answer it. A rarely called endpoint can still be slow for the user who calls it.

Estimate data sizes from the code, the schema and the docs. Say what you assumed, for example "assuming 10,000 rows per customer".

## Blocking

A performance finding blocks when, at the expected production load, the code would fail, time out or overload a shared service. In colleague mode, everything else is a suggestion.
