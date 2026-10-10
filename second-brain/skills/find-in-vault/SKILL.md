---
name: find-in-vault
description: Find a fixed place in a notes vault (Obsidian or any Markdown folder) by its vault-ref name instead of a hard-coded path, so skills and instructions keep working when folders move. Use whenever a skill or instruction says to find something "with find-in-vault", names a vault-ref, or needs a folder or note in the vault whose location it doesn't know. Also use to list, add or check vault-refs.
---

# find-in-vault

Skills and instructions that work with a notes vault tend to hard-code paths: "write the entry to `Journal/2026/`". Move or rename one folder and every skill that knew the old path breaks without saying so.

This skill replaces paths with names. A folder or note gets a stable name in its frontmatter, and anything that needs that place looks it up by name, every time.

## The convention

A note carries a `vault-ref` in its frontmatter:

```yaml
---
vault-ref: reading-list
---
```

- **A note with a `vault-ref`** is that place. The ref names the note itself.
- **A folder note** (a note that describes its folder, usually named after the folder and stored inside it) with a `vault-ref` names the **folder it is in**. The ref then stands for both the note and its folder.
- A ref name is lowercase with dashes, says what the place *is* (`reading-list`, `meeting-notes`), and is unique in the vault.
- Everything inside a referenced folder moves with it. A skill may name sub-paths relative to a ref: "`archive/` inside `meeting-notes`".

## Where the vault is

This skill doesn't know where the vault is. Take the vault root from the environment: the project instructions, another skill, or the working directory. If none of those say, ask the user once. Don't search the whole disk.

## Find a ref

```bash
grep -rlE --include='*.md' '^vault-ref:[[:space:]]*"?reading-list"?[[:space:]]*$' "$VAULT"
```

- **One hit:** that file is the place. If it's a folder note, the place is its folder (`dirname`).
- **No hit:** stop. Tell the user which ref is missing and ask where that place is now. Don't guess from folder names, and don't create the place on your own.
- **More than one hit:** stop. Show the files and ask which one should keep the ref.

Look the ref up each time you need it. Don't remember paths between sessions or write them back into skills; that's the problem this skill exists to avoid.

Dot-folders (e.g. `.obsidian/`) are skipped by Obsidian; a plain `grep` still searches them, which is fine.

## List all refs

```bash
grep -rhoE --include='*.md' '^vault-ref:.*' "$VAULT" | sort | uniq -c
```

A count above 1 means a duplicate ref: report it.

## Add a ref

When the user wants a skill to use a place that has no ref yet:

1. Agree on a name with the user.
2. For a folder: put the ref in its folder note. If the folder has no folder note, create one (named after the folder, inside it) holding only the frontmatter. For a single note: add the ref to that note's frontmatter.
3. If the note already has frontmatter, add the line inside it. Otherwise add a frontmatter block at the very top. Leave the rest of the note untouched.
4. Check with "Find a ref" that it resolves to exactly one file.

## Writing skills that use refs

- Name the ref, never the path: "Add the entry to the `reading-list` (find it with find-in-vault)."
- Sub-paths are fine only relative to a ref: "save the image in `images/` inside `recipes`".
- If a skill needs a place that has no ref, add one first (see above) rather than writing a path.
