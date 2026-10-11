#!/usr/bin/env bash
# Coverage gate: every line of the app runs
# in the tests (unit, snapshot and UI tests
# all count). A file with untested lines
# fails, naming each function and the line
# it starts on.
set -euo pipefail

result="$1"
app=$(sed -n 's/^name: *//p' project.yml)
# The JSON report lists every file's
# functions with their line counts.
report=$(
  xcrun xccov view --report --json "$result"
)
# A jq function picking the app target.
pick="def app: .targets[]
  | select(.name == \"$app.app\");"

files=$(jq -r "$pick"' app | .files[]
  | [.path, .coveredLines,
     .executableLines] | @tsv' \
  <<<"$report")

# Prints each function in file $1 with
# untested lines.
gaps() {
  jq -r --arg path "$1" "$pick"'
    app | .files[]
    | select(.path == $path)
    | (.functions // [])[]
    | select(.coveredLines
      < .executableLines)
    | (.executableLines
      - .coveredLines) as $n
    | "\(.name) (line \(.lineNumber)): "
      + "\($n) untested"' \
    <<<"$report"
}

sum_cov=0
sum_all=0
failed=0
table="| File | Lines | Covered |\n"
table+="|---|---|---|\n"
while IFS=$'\t' read -r path covered total
do
  [ -n "$path" ] || continue
  name="${path#*/"$app"/}"
  sum_cov=$((sum_cov + covered))
  sum_all=$((sum_all + total))
  [ "$covered" -lt "$total" ] || continue
  failed=1
  table+="| $name | $total | $covered |\n"
  untested=$((total - covered))
  echo "::error file=$app/$name::$name" \
    "has $untested untested lines"
  while IFS= read -r gap; do
    [ -n "$gap" ] && echo "  $name: $gap"
  done < <(gaps "$path")
done <<<"$files"

{
  echo "### Coverage"
  echo "- App (gated at 100%):" \
    "$sum_cov/$sum_all lines"
  if [ "$failed" -ne 0 ]; then
    echo
    echo "Files with untested lines:"
    echo
    printf "%b" "$table"
  fi
} >> "${GITHUB_STEP_SUMMARY:-/dev/stdout}"

echo "Coverage: $sum_cov/$sum_all lines"
if [ "$failed" -ne 0 ] \
  || [ "$sum_all" -eq 0 ]; then
  echo "::error::Every line of the app" \
    "must run in tests (see untested lines" \
    "above)."
  exit 1
fi
