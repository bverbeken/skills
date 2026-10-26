# skills

Claude Code skills I use. 

| Skill | What it does |
|---|---|
| [conference-notes](conference-notes/) | Live note-taking during conference talks: type short notes and snap slides from your phone, get structured Markdown notes. |
| [development](development/) | From an issue to a draft PR: asks you every open decision, builds the change test-first in its own worktree, reviews it and opens a draft PR. |
| [review](review/) | A full code review: eleven checks in parallel (tests, spec, bugs, performance, style, comments, refactoring, architecture, consumers, dependencies, description) and a GO / NO GO verdict. Never posts. |
| [second-brain/find-in-vault](second-brain/skills/find-in-vault/) | Find places in a notes vault by a `vault-ref` name in their frontmatter instead of a hard-coded path, so skills keep working when you move folders. |

## Install

Clone the repo and link the skill folders you want into `~/.claude/skills/`. A `git pull` then updates them.

```bash
git clone https://github.com/bverbeken/skills.git ~/skills
mkdir -p ~/.claude/skills
ln -s ~/skills/conference-notes ~/.claude/skills/
for skill in ~/skills/development/skills/* ~/skills/review/skills/*; do
  ln -s "$skill" ~/.claude/skills/
done
```

Link all of `review/skills/` together: the review skills need each other. The development skills need the review skills.

`second-brain` is a Claude Code plugin:

```
/plugin marketplace add bverbeken/skills
/plugin install second-brain@bverbeken-skills
```
