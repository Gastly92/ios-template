#!/usr/bin/env python3
"""Fails when the String Catalog
(<app>/Localizable.xcstrings) has a key
no Swift code uses any more, so leftover
entries (and their translations) don't pile
up. Without Xcode here nothing marks keys
stale, so this checks by hand.

A key is used when some string literal in
<app>/ reads the same once each
interpolation, like "\\(days) days", and
each format specifier in the key, like
"%lld days", count as one placeholder.
Multi-line literals are joined the way Swift
joins them.
"""
import glob
import json
import os
import re
import sys

SLOT = "\0"
SPEC = re.compile(
    r"%(\d+\$)?[-+ #0]*\d*(\.\d+)?"
    r"(lld|llu|ld|lu|d|i|u|f|lf|@)"
)
ESCAPES = {"n": "\n", "t": "\t", "r": "\r",
           "0": "\0", '"': '"', "'": "'",
           "\\": "\\"}


def skip_interpolation(src, i):
    """Index just past the `)` closing an
    interpolation whose `(` is at i - 1."""
    depth = 1
    while depth:
        c = src[i]
        if c == '"':
            _, i = literal(src, i)
            continue
        depth += {"(": 1, ")": -1}.get(c, 0)
        i += 1
    return i


def body(src, i, end):
    """Reads literal text from i up to the
    `end` delimiter; returns (text, index
    past the delimiter)."""
    out = []
    while not src.startswith(end, i):
        c = src[i]
        if c != "\\":
            out.append(c)
            i += 1
            continue
        nxt = src[i + 1]
        if nxt == "(":
            out.append(SLOT)
            i = skip_interpolation(
                src, i + 2)
        elif nxt == "\n":
            # Line continuation: no newline,
            # and the next line's indent is
            # stripped later.
            out.append("\\\n")
            i += 2
        elif nxt == "u":
            close = src.index("}", i)
            code = src[i + 3:close]
            out.append(chr(int(code, 16)))
            i = close + 1
        else:
            out.append(ESCAPES.get(nxt, nxt))
            i += 2
    return "".join(out), i + len(end)


def multiline(text):
    """Swift's rules for a `\"\"\"` literal:
    drop the first newline and the closing
    line, strip the closing line's indent,
    join `\\`-ended lines."""
    lines = text.split("\n")
    indent = lines[-1]
    kept = []
    for line in lines[1:-1]:
        if line.startswith(indent):
            line = line[len(indent):]
        kept.append(line)
    joined = "\n".join(kept)
    return joined.replace("\\\n", "")


def literal(src, i):
    """Reads the literal starting at i (a
    `"`); returns (text, index after it)."""
    if src.startswith('"""', i):
        text, i = body(src, i + 3, '"""')
        return multiline(text), i
    return body(src, i + 1, '"')


def literals(src):
    """Every string literal in Swift source,
    skipping comments."""
    found = []
    i = 0
    while i < len(src):
        if src.startswith("//", i):
            i = src.find("\n", i)
            if i < 0:
                break
        elif src.startswith("/*", i):
            i = src.index("*/", i) + 2
        elif src[i] == '"':
            text, i = literal(src, i)
            found.append(text)
        else:
            i += 1
    return found


def key_text(key):
    """A catalog key as code would write it:
    specifiers become placeholders."""
    text = SPEC.sub(SLOT, key)
    return text.replace("%%", "%")


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def app_name():
    """The app's name in project.yml."""
    lines = read("project.yml").split("\n")
    for line in lines:
        if line.startswith("name:"):
            return line[5:].strip()
    raise SystemExit("project.yml: no name")


def main():
    app = app_name()
    strings = f"{app}/Localizable.xcstrings"
    if not os.path.exists(strings):
        print(f"No {strings}.")
        return 0
    used = set()
    swift = glob.glob(
        f"{app}/**/*.swift", recursive=True
    )
    for path in swift:
        used.update(literals(read(path)))
    catalog = json.loads(read(strings))
    keys = catalog["strings"]
    unused = sorted(
        k for k in keys
        if key_text(k) not in used
    )
    for key in unused:
        print(f"Unused key in {strings}:"
              f" {key!r}")
    if unused:
        print("Delete these keys, or fix the"
              " code that should use them.")
        return 1
    print(f"All {len(keys)} catalog keys"
          " are used.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
