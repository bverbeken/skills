# skills

Claude Code skills I use. 

| Skill | What it does |
|---|---|
| [conference-notes](conference-notes/) | Live note-taking during conference talks: type short notes and snap slides from your phone, get structured Markdown notes. |
| [review-pr](review-pr/) | Review a GitHub pull request and get a GO / NO GO verdict. Checks the code that depends on it too, and never posts to the PR. |
| [second-brain/find-in-vault](second-brain/skills/find-in-vault/) | Find places in a notes vault by a `vault-ref` name in their frontmatter instead of a hard-coded path, so skills keep working when you move folders. |

## Install

### As a plugin

Grouped skills (like `second-brain/`) are Claude Code plugins:

```
/plugin marketplace add bverbeken/skills
/plugin install second-brain@bverbeken-skills
```

### By copying

Copy a skill folder into `~/.claude/skills/` (all projects) or `.claude/skills/` (one project):

```bash
git clone https://github.com/bverbeken/skills.git
cp -r skills/conference-notes ~/.claude/skills/
cp -r skills/second-brain/skills/find-in-vault ~/.claude/skills/
```
