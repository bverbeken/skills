#!/bin/sh
set -eu
html_file="$1"
markdown_file="${2:-}"
osascript -l JavaScript - "$html_file" "$markdown_file" <<'JXA'
ObjC.import('AppKit');
function readText(path) {
  const text = $.NSString.stringWithContentsOfFileEncodingError(path, $.NSUTF8StringEncoding, null);
  if (text.isNil()) throw new Error('Cannot read ' + path + ' as UTF-8 text');
  return text.js;
}
function formattedText(html) {
  const data = $(html).dataUsingEncoding($.NSUTF8StringEncoding);
  const text = $.NSAttributedString.alloc.initWithHTMLDocumentAttributes(data, null);
  if (text.isNil()) throw new Error('Cannot read the HTML');
  return text;
}
function run(argv) {
  const html = '<meta charset="utf-8">' + readText(argv[0]);
  const text = formattedText(html);
  const rtf = text.RTFFromRangeDocumentAttributes($.NSMakeRange(0, text.length), $.NSDictionary.dictionary);
  const plain = argv[1] ? readText(argv[1]) : text.string.js;
  const pasteboard = $.NSPasteboard.generalPasteboard;
  pasteboard.clearContents;
  const copied = pasteboard.setStringForType(html, $.NSPasteboardTypeHTML)
    && pasteboard.setDataForType(rtf, $.NSPasteboardTypeRTF)
    && pasteboard.setStringForType(plain, $.NSPasteboardTypeString);
  if (!copied) throw new Error('The clipboard refused the text');
  return 'Copied to the clipboard as HTML, RTF and ' + (argv[1] ? 'Markdown' : 'plain text');
}
JXA
