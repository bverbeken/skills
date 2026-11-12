#!/bin/sh
set -eu
html_file="$1"
markdown_file="$2"
osascript -l JavaScript - "$html_file" "$markdown_file" <<'JXA'
ObjC.import('AppKit');
function run(argv) {
  const read = path => $.NSString.stringWithContentsOfFileEncodingError(path, $.NSUTF8StringEncoding, null);
  const pasteboard = $.NSPasteboard.generalPasteboard;
  pasteboard.clearContents;
  pasteboard.setStringForType(read(argv[0]), $.NSPasteboardTypeHTML);
  pasteboard.setStringForType(read(argv[1]), $.NSPasteboardTypeString);
  return 'Copied to the clipboard as HTML and Markdown';
}
JXA
