---
name: copy-formatted
description: Copy text from this conversation to the macOS clipboard as rich text (HTML and RTF) and Markdown, ready to paste into a chat or an editor. Copies the latest draft by default. Use when the user says "/copy-formatted", "copy the draft", "copy this response formatted", "copy that to my clipboard".
argument-hint: "[what to copy, e.g. the table | this response; default: the latest draft]"
---

# Copy to the clipboard

What to copy: `$ARGUMENTS`

1. **Pick the text.**
   - With an argument, take the part of the conversation the user names. "This response" or "that" means your last reply before this request.
   - Without an argument, take the latest draft: the most recent text you wrote for the user to send to someone else, such as a customer reply, a PR comment or a Slack message. Take only the draft itself, without its heading or quote markers. When you built a version to send with links (for example an HTML version for the clipboard), copy that version. When the conversation has no draft, take your last reply before this request.
   - Copy the text word for word. Leave out any line you added about copying.
2. **Write two files** in a new temporary folder (`mktemp -d`):
   - `copy.md`: the text as Markdown.
   - `copy.html`: the same text as an HTML fragment. Use plain tags only: `p`, `br`, `strong`, `em`, `a`, `code`, `pre`, `ul`, `ol`, `li`, `h1` to `h3`, `blockquote`, `table`. Write no `style`, `class`, `<html>` or `<body>`.
3. **Copy them:** run `scripts/copy.sh <folder>/copy.html <folder>/copy.md` from this skill's folder. Done when it prints "Copied to the clipboard". Reply with one line that names what you copied. When no draft was found, start that line with "No draft found, copied your last reply."

The script also makes an RTF version from the HTML, for clipboard managers like Clipy that keep RTF but not HTML. Apps that take rich text paste the formatting. Plain text fields paste the Markdown. Without a Markdown file, the script makes plain text from the HTML.
