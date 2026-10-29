#!/usr/bin/env python3
"""Fails on lines over 45 characters in docs,
YAML and scripts, so each diff line fits a
phone in portrait. Swift is checked by
SwiftLint.

Skipped: lines with a URL, a single word
that can't wrap, Markdown tables and code
blocks, pinned `uses:` lines in workflows,
and files Xcode owns (String Catalog,
privacy manifest, asset JSON).
"""
import re
import subprocess
import sys

LIMIT = 45
SUFFIXES = (".md", ".yml", ".yaml", ".sh",
            ".py")


def files():
    out = subprocess.run(
        ["git", "ls-files"],
        capture_output=True, text=True,
        check=True,
    ).stdout
    return [f for f in out.split()
            if f.endswith(SUFFIXES)]


def exempt(line, in_code):
    text = line.strip()
    return (
        in_code
        or "://" in text
        or " " not in text
        or text.startswith("|")
        or re.match(r"-? ?uses: \S+@", text)
    )


def check(path):
    bad = 0
    in_code = False
    is_md = path.endswith(".md")
    with open(path, encoding="utf-8") as f:
        for num, line in enumerate(f, 1):
            line = line.rstrip("\n")
            fence = line.strip().startswith(
                "```")
            if is_md and fence:
                in_code = not in_code
                continue
            if len(line) <= LIMIT:
                continue
            if exempt(line, in_code):
                continue
            bad += 1
            print(f"{path}:{num}: "
                  f"{len(line)} chars")
    return bad


def main():
    bad = sum(check(p) for p in files())
    if bad:
        print(f"{bad} lines over {LIMIT}.")
        sys.exit(1)


main()
