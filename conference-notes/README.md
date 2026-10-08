# conference-notes

Take notes during conference talks without missing the talk. You type short, messy lines on your phone; Claude turns them into one structured Markdown note per talk.

Written for an Obsidian vault, but the notes are plain Markdown.

## What it does

- **One note per talk**, in a folder per conference and per day, plus an index note.
- **Looks up the talk.** Say "I'm now in the talk of <speaker>" and the title, speaker, room and abstract get filled in from the schedule (built in for [cfp.dev](https://cfp.dev) conferences like Devoxx, web search for the rest).
- **Fills in the blanks.** "Adam xxx said …" or "coined by XXX (paper from 1978)" gets completed from the talk context.
- **Cleans up slide photos**: straightens, crops away the room, embeds them in the note and transcribes the key points.
- **Follow-ups.** Type "FU <action>" and a `#followup` todo lands in the note. Afterwards, "list my follow-ups" gives you a todo list per talk.
- **(Brackets) are instructions** for Claude, not note content.

## Setup

1. Run Claude Code in your notes folder (e.g. your Obsidian vault) on your laptop.
2. Connect to it from your phone with [Remote Control](https://docs.claude.com/en/docs/claude-code/remote-control).
3. In the talk: "I'm in the talk about X", then type away.

Want the notes somewhere other than `Conferences/`? Say so in your project's `CLAUDE.md`, e.g. "Conference notes go in `Learning/Conferences/`."

## Requirements

- Python 3.9+
- For slide photos: `pip install pillow numpy`
