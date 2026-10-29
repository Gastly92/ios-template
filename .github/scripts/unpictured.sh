#!/usr/bin/env bash
# Screen list gate: every line of view code
# must be drawn when the localization shard
# opens each ScreenID (one shard, one
# screen at a time), so every screen state
# has a snapshot. Lines no screen draws
# (what a tap does, a sheet's contents
# pictured as its own screen) are listed in
# .github/unpictured.txt by file and text.
# Fails on undrawn lines missing from the
# list, and on list entries that are drawn
# now or gone.
set -euo pipefail

result="$1"
list=".github/unpictured.txt"
app=$(sed -n 's/^name: *//p' project.yml)
# No list: no lines are expected undrawn.
if [ ! -f "$list" ]; then
  list=/dev/null
fi

report=$(
  xcrun xccov view --report --json "$result"
)
paths=$(jq -r --arg app "$app" '.targets[]
  | select(.name == $app + ".app")
  | .files[].path
  | select(contains(
    "/" + $app + "/Views/"))' \
  <<<"$report")

# "File.swift<TAB>text" for each undrawn
# line with any letter or digit, text
# trimmed.
found() {
  local path rel name
  while IFS= read -r path; do
    [ -n "$path" ] || continue
    rel="$app/${path#*/"$app"/}"
    name=$(basename "$path")
    xcrun xccov view --archive --json \
      --file "$path" "$result" \
      | jq -r '.[][]
        | select(.isExecutable
          and .executionCount == 0)
        | .line' \
      | while IFS= read -r line; do
        text=$(sed -n "${line}p" "$rel" \
          | sed -e 's/^ *//' -e 's/ *$//')
        # Brackets and quotes alone follow
        # the code around them.
        grep -q '[[:alnum:]]' <<<"$text" \
          || continue
        printf '%s\t%s\n' "$name" "$text"
      done
  done <<<"$paths"
}

# The same from the list: a file name line,
# then its lines indented. # starts a
# comment (the reason).
listed() {
  local name="" entry text
  while IFS= read -r entry; do
    text="${entry#"${entry%%[! ]*}"}"
    case "$text" in
      "" | "#"*) continue ;;
    esac
    case "$entry" in
      " "*)
        printf '%s\t%s\n' "$name" "$text" ;;
      *) name="$entry" ;;
    esac
  done < "$list"
}

# Guards against reading no coverage at
# all, which would pass everything.
lines=$(xcrun xccov view --archive --json \
  --file "$(head -n 1 <<<"$paths")" \
  "$result" | jq '[.[][]
  | select(.isExecutable)] | length')
if [ -z "$paths" ] || [ "$lines" -eq 0 ]
then
  echo "::error::No view coverage in" \
    "$result."
  exit 1
fi

have=$(found | sort -u)
want=$(listed | sort -u)
new=$(comm -23 <(echo "$have") \
  <(echo "$want") | sed '/^$/d')
stale=$(comm -13 <(echo "$have") \
  <(echo "$want") | sed '/^$/d')

failed=0
if [ -n "$new" ]; then
  failed=1
  echo "::error::View code no screen" \
    "draws. Add a ScreenID for its state," \
    "or list it in $list with why."
  echo "${new//$'\t'/: }"
fi
if [ -n "$stale" ]; then
  failed=1
  echo "::error::$list lists lines that" \
    "are drawn now or gone; remove them."
  echo "${stale//$'\t'/: }"
fi

count=$(echo "$want" | sed '/^$/d' \
  | wc -l | tr -d ' ')
{
  echo "### Screen list"
  echo "- Undrawn view lines listed as" \
    "expected: $count"
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

exit "$failed"
