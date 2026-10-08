---
name: conference-notes
description: Live note-taking during conference talks, written as Markdown notes (works well with an Obsidian vault). Use when the user says they're at a conference or in a talk and wants notes taken, "I'm in a talk about X", "I'm now in the talk of <speaker>", "/conference-notes", or sends photos of slides during a talk.
---

# Conference notes

The user is sitting in a talk, typing short notes on their phone (often through Remote Control). You write them into the notes right away. Speed matters, and so does their attention: they should be able to keep listening.

## Rules

- **Text in (brackets) = instruction for you**, never note content. "(look this up)", "(link to the previous talk)", etc.
- **Personal remarks** ("personal note: …", "I think …") go in a callout, not in the talk content:
  ```
  > [!note] Me
  > …
  ```
- **Language**: write the notes in the language the user types in.
- **Write immediately**, append each point as it comes. Keep their wording, just tidy it (grammar, typos). Don't add your own content, except things they ask you to look up (put those in a `> [!info]` callout).
- **Fill in the blanks**: "Adam xxx", "coined by XXX", half-remembered quotes and names. Fill them in when you're sure, from the talk context, the schedule or a web search. If there are several candidates (same talk given at two conferences, two people with that name), say so in one line instead of silently picking one.
- Fix obvious typos in names/commands, and mention it in one short line so they can correct you.
- Replies: one or two short lines. No summaries, they're reading on a phone during a talk.

## Structure

Default layout (if the project already has a conferences folder or conventions in its CLAUDE.md, use those instead):

```
Conferences/<Conf><YY>/                     e.g. Devoxx26
├── <Conf><YY>.md                           index note
├── attachments/                            all slide photos (shared)
└── YYYY-MM-DD Weekday/                     one folder per day
    └── <Short title> - <Speaker>.md        one note per talk
```

If the conference folder exists already, use it and its conventions. Create the day folder on the first talk of the day.

### Index note
```
---
tags: [<conf>, conference]
location: <city (venue)>
dates: YYYY-MM-DD – YYYY-MM-DD
---
# <Conference full name>

## Talks

### Monday 5 Oct

- 09:30 [[<Short title> - <Speaker>]] (<topic>, <session type>)
```
Add each talk under its day, sorted by time.

### Talk note
Filename: short title (part before the colon) + ` - ` + speaker, e.g. `From Developer to Builder - Simon Martinelli.md`. Avoid `:` `/` `?` in filenames.
```
---
tags: [<conf>, talk, <topic tags>]
event: "[[<Conf><YY>]]"
date: YYYY-MM-DD
time: HH:MM–HH:MM
room: <room>
type: <Deep Dive / Conference / Lunch Talk / …>
speaker: <Name> (<Company>)
link: <talk url>
---
# <Full official title>

**Speaker:** <Name> (<Company>)

> <2–3 sentence summary of the abstract>

```
After the summary: a `## Heading` per section/slide topic the user announces ("next slide: X"), bullets underneath. No `## Notes` wrapper heading; use `###` only for sub-sections. Numbered lists stay numbered. Quotes from the speaker in italics with quotes: `*"…"*`. **If the user uses quotation marks, it's a literal quote**: keep the wording verbatim.

When the user says which talk they're in ("I'm now in the talk of James Ward", "a talk about GitHub AI"), look it up (see below) and fill in the header before they've typed a single note. If you can't find it, make the note with what you have and fill it in later.

## Looking up talks

### cfp.dev conferences (Devoxx and many others)

Many conferences run their schedule on cfp.dev. The instance name is the subdomain, e.g. `dvbe26` for Devoxx Belgium 2026 (`dvbe26.cfp.dev`). For other events, guess (`dv<country><yy>` for Devoxx) and check with a request.

The scripts live in this skill's `scripts/` folder:

```bash
S=<this skill's folder>/scripts
python3 $S/schedule.py dvbe26 tuesday --q copilot --q github           # search by keyword (title/speaker/company)
python3 $S/schedule.py dvbe26 tuesday --after 13:00 --before 14:00     # what's on in a time window
python3 $S/schedule.py dvbe26 --talk 4098                              # details + abstract for one talk
```
Times are printed in the conference's time zone: `--tz` (default `Europe/Brussels`), e.g. `--tz Europe/London` for Devoxx UK. Use the current time + topic or speaker to find the talk they're in.

### Other conferences

Search the web for the schedule and fetch the talk page.

## Slide photos

The user sends photos of slides. For each one:

1. Look at it. If it's a generic file icon instead of an image, it didn't come through: ask them to paste it instead of dragging it.
2. Clean it up: rotate upright, perspective-correct to the slide, crop away the room/stage, enhance (needs Pillow + numpy).
   ```bash
   python3 $S/clean_photo.py <in.png> <tmp>/clean.png --rotate -90 --corners "x,y x,y x,y x,y" --trim 6
   ```
   - First run without `--corners` (only `--rotate` if needed) to get the size, then estimate the slide's corners (TL, TR, BR, BL) from the image.
   - **Look at the result.** Adjust corners if the slide is cut off or there's still a border.
   - Already-clean images (screenshots, book covers): just copy, no cleanup.
3. Save to `attachments/<speaker-lastname>-<slide-topic>.png` and embed under the matching section: `![[<file>.png]]`.
4. Transcribe the key content of the slide as bullets (so it's searchable), plus what the user says about it.

## Follow-ups

When the user says "FU", "follow-up", "follow-up action" etc., add it where it comes up in the note:
```
> [!todo] 🚀 Follow-up
> - [ ] <action> #followup
```
Afterwards, "list my follow-ups" → search the conference folder for `#followup` and show them grouped per talk (open `- [ ]` vs done `- [x]`). In Obsidian they're also findable with the search `tag:#followup`.

## Other inputs

- **Chat transcripts** (Slack etc.) about the talk: add a `## Team discussion (HH:MM)` section summarising per person, keep the good quotes.
- **Leaving early / verdict**: `## Rest of the talk` + a `> [!note] Me: verdict` callout.
