#!/usr/bin/env python3
"""Look up talks on a cfp.dev conference schedule (Devoxx & friends).

Usage:
  schedule.py <conf> <day> [--q KEYWORD]... [--before HH:MM] [--after HH:MM] [--tz ZONE]
  schedule.py <conf> --talk <id> [--tz ZONE]

  <conf>  cfp.dev instance, e.g. dvbe26 (Devoxx Belgium 2026)
  <day>   monday, tuesday, ... (weekday name as used by the API)

Times are printed in the conference's local time (--tz, default Europe/Brussels). --before/--after filter on local start time.
Keywords match title, speaker names and company (case-insensitive, any keyword matches).
"""
import argparse, json, re, sys, urllib.request
from datetime import datetime
from zoneinfo import ZoneInfo

TZ = ZoneInfo("Europe/Brussels")  # overridden by --tz

def get(url):
    with urllib.request.urlopen(url, timeout=20) as r:
        return json.load(r)

def local(iso):
    return datetime.fromisoformat(iso.replace("Z", "+00:00")).astimezone(TZ)

def strip(html):
    s = re.sub(r"<[^>]+>", " ", html or "")
    for a, b in [("&quot;", '"'), ("&#39;", "'"), ("&amp;", "&"), ("&nbsp;", " ")]:
        s = s.replace(a, b)
    return re.sub(r"\s+", " ", s).strip()

def talk(conf, tid):
    p = get(f"https://{conf}.cfp.dev/api/public/talks/{tid}")
    print("TITLE:", p["title"])
    for s in p.get("speakers", []):
        print("SPEAKER:", s["fullName"], "|", s.get("company") or "")
    for t in p.get("timeSlots", []) or []:
        print("SLOT:", local(t["fromDate"]).strftime("%Y-%m-%d %H:%M"), "–",
              local(t["toDate"]).strftime("%H:%M"), "|", t.get("roomName", ""))
    if (p.get("sessionType") or {}).get("name"):
        print("TYPE:", p["sessionType"]["name"])
    print("LINK:", f"https://{conf}.cfp.dev/api/public/talks/{tid}")
    print("DESCRIPTION:", strip(p.get("description")))

def day(conf, d, qs, before, after):
    rows = []
    for s in get(f"https://{conf}.cfp.dev/api/public/schedules/{d}"):
        p = s.get("proposal") or {}
        if not p:
            continue
        start, end = local(s["fromDate"]), local(s["toDate"])
        hm = start.strftime("%H:%M")
        if before and hm >= before: continue
        if after and hm < after: continue
        spk = ", ".join(f'{x["fullName"]} ({x.get("company") or "-"})' for x in p.get("speakers", []))
        hay = f'{p.get("title","")} {spk}'.lower()
        if qs and not any(q.lower() in hay for q in qs):
            continue
        rows.append((start, f'{hm}–{end.strftime("%H:%M")} | {(s.get("room") or {}).get("name","")} | '
                            f'{p.get("title")} | {spk} | {(p.get("sessionType") or {}).get("name")} | id {p.get("id")}'))
    for _, r in sorted(rows):
        print(r)
    if not rows:
        print("(no matches)")

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("conf"); ap.add_argument("day", nargs="?")
    ap.add_argument("--q", action="append", default=[])
    ap.add_argument("--before"); ap.add_argument("--after")
    ap.add_argument("--talk", type=int)
    ap.add_argument("--tz", default="Europe/Brussels", help="conference time zone, e.g. Europe/London")
    a = ap.parse_args()
    TZ = ZoneInfo(a.tz)
    if a.talk:
        talk(a.conf, a.talk)
    elif a.day:
        day(a.conf, a.day.lower(), a.q, a.before, a.after)
    else:
        sys.exit("need <day> or --talk <id>")
