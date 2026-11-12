---
name: copy
description: Copy text from this conversation to the macOS clipboard as rich text (HTML) and Markdown, ready to paste into a chat or an editor. Use when the user says "/copy", "copy this response", "copy that to my clipboard", "put the draft on my clipboard".
argument-hint: "[what to copy, e.g. this response | the table | the draft]"
---

# Copy to the clipboard

What to copy: `$ARGUMENTS`

1. **Pick the text.** Take the part of the conversation the user names. "This response", "that" or nothing means your last reply before this request. Copy it word for word, as the user saw it. Leave out any line you added about copying.
2. **Write two files** in a new temporary folder (`mktemp -d`):
   - `copy.md`: the text as Markdown.
   - `copy.html`: the same text as an HTML fragment. Use plain tags only: `p`, `br`, `strong`, `em`, `a`, `code`, `pre`, `ul`, `ol`, `li`, `h1` to `h3`, `blockquote`, `table`. Write no `style`, `class`, `<html>` or `<body>`.
3. **Copy them:** run `scripts/copy.sh <folder>/copy.html <folder>/copy.md` from this skill's folder. Done when it prints "Copied to the clipboard". Reply with one line that names what you copied.

Apps that take rich text paste the HTML with its formatting. Plain text fields paste the Markdown.
