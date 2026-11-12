#!/bin/sh
set -eu
html_file="$1"
markdown_file="$2"
osascript -l JavaScript - "$html_file" "$markdown_file" <<'JXA'
ObjC.import('AppKit');
function readText(path) {
  const text = $.NSString.stringWithContentsOfFileEncodingError(path, $.NSUTF8StringEncoding, null);
  if (text.isNil()) throw new Error('Cannot read ' + path + ' as UTF-8 text');
  return text.js;
}
function run(argv) {
  const html = '<meta charset="utf-8">' + readText(argv[0]);
  const markdown = readText(argv[1]);
  const pasteboard = $.NSPasteboard.generalPasteboard;
  pasteboard.clearContents;
  const copied = pasteboard.setStringForType(html, $.NSPasteboardTypeHTML)
    && pasteboard.setStringForType(markdown, $.NSPasteboardTypeString);
  if (!copied) throw new Error('The clipboard refused the text');
  return 'Copied to the clipboard as HTML and Markdown';
}
JXA
