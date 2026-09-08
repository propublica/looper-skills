#!/usr/bin/env bash
# Check, or record, the known differences between each Gem's files and the skill
# source they were copied from. See gems/README.md, "Evaluating a Gem".
#
#   ./gems/check-diffs.sh                       check every gem under gems/*/
#   ./gems/check-diffs.sh <gem-name>             check one gem
#   ./gems/check-diffs.sh --record               regenerate known-diffs.txt for every gem
#   ./gems/check-diffs.sh --record <gem-name>    regenerate known-diffs.txt for one gem
#
# Every directory under gems/ is treated as a gem and must hold two flat files:
#   diff-pairs.txt   hand-edited — which skill file maps to which Gem file
#   known-diffs.txt  script-generated — the exact `diff -u` output for each pair (or
#                     "(no differences)"), recorded the last time someone ran --record
#
# A gem directory with no diff-pairs.txt is a hard error, not a skip — a new gem
# that forgets to add one would otherwise pass an unchecked "ok" silently.
#
# Nothing is preprocessed before diffing. Each pair is compared exactly as the two
# files sit on disk, so everything — including structural differences like a stripped
# YAML frontmatter block — shows up as an ordinary hunk in known-diffs.txt. There's no
# special case that could hide a real change from the record.
#
# Checking recomputes each live diff from diff-pairs.txt and compares it byte-for-byte
# against known-diffs.txt. A mismatch means either the skill source changed and the
# Gem wasn't updated to match, or the Gem file changed without the change being
# recorded — either way, review it, then re-run with --record once the change is
# intentional and documented (add a line to the Gem's README too).
#
# This only catches undocumented TEXT drift. It says nothing about whether the Gem
# still behaves correctly — that's what each Gem's manual smoke test is for.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="check"

if [[ "${1:-}" == "--record" ]]; then
  MODE="record"
  shift
fi

# Renders one PAIR's block (header + diff-or-"no differences") to stdout, in the
# same format known-diffs.txt is written in, so a check is just a text comparison.
render_pair() {
  local skill_rel="$1" gem_rel="$2" gem_dir="$3"
  local skill_abs="$gem_dir/$skill_rel"
  local gem_abs="$gem_dir/$gem_rel"
  local diff_out

  if [[ ! -f "$skill_abs" ]]; then
    echo "error: skill file not found: $skill_abs (from $gem_dir/diff-pairs.txt)" >&2
    return 1
  fi
  if [[ ! -f "$gem_abs" ]]; then
    echo "error: gem file not found: $gem_abs (from $gem_dir/diff-pairs.txt)" >&2
    return 1
  fi

  echo "PAIR $skill_rel $gem_rel"
  if diff_out="$(diff -u --label "skill:$skill_rel" --label "gem:$gem_rel" "$skill_abs" "$gem_abs")"; then
    echo "(no differences)"
  else
    printf '%s\n' "$diff_out"
  fi
}

check_or_record_gem() {
  local gem_dir="$1"
  local pairs_file="$gem_dir/diff-pairs.txt"
  local manifest="$gem_dir/known-diffs.txt"
  local name
  name="$(basename "$gem_dir")"

  if [[ ! -f "$pairs_file" ]]; then
    echo "error: $name has no diff-pairs.txt to read file pairs from" >&2
    return 1
  fi

  local rendered
  rendered="$(mktemp "${TMPDIR:-/tmp}/check-diffs.XXXXXX")"
  local had_pairs=0
  while IFS= read -r line; do
    [[ -n "$line" && "$line" != \#* ]] || continue
    had_pairs=1
    read -r skill_rel gem_rel <<< "$line"
    if ! render_pair "$skill_rel" "$gem_rel" "$gem_dir" >> "$rendered"; then
      echo "error: $name — check diff-pairs.txt for a stale entry" >&2
      rm -f "$rendered"
      return 1
    fi
    echo >> "$rendered"
  done < "$pairs_file"

  if [[ "$had_pairs" -eq 0 ]]; then
    echo "warning: $name/diff-pairs.txt has no pairs listed" >&2
    rm -f "$rendered"
    return 0
  fi

  if [[ "$MODE" == "record" ]]; then
    cp "$rendered" "$manifest"
    echo "recorded: $name/known-diffs.txt"
    rm -f "$rendered"
    return 0
  fi

  if [[ ! -f "$manifest" ]]; then
    echo "error: $name has no known-diffs.txt — run: $0 --record $name" >&2
    rm -f "$rendered"
    return 1
  fi

  if diff -q "$manifest" "$rendered" > /dev/null; then
    echo "ok: $name"
    rm -f "$rendered"
    return 0
  else
    echo "DRIFT DETECTED: $name/known-diffs.txt no longer matches the live diff." >&2
    diff -u "$manifest" "$rendered" >&2 || true
    echo "  If this is intentional, run:" >&2
    echo "    $0 --record $name" >&2
    rm -f "$rendered"
    return 1
  fi
}

targets=()
if [[ $# -gt 0 ]]; then
  for n in "$@"; do
    [[ -d "$HERE/$n" ]] || { echo "error: no gems/$n directory" >&2; exit 1; }
    targets+=("$HERE/$n")
  done
else
  for d in "$HERE"/*/; do
    targets+=("${d%/}")
  done
fi

if [[ "${#targets[@]}" -eq 0 ]]; then
  echo "no gems with a diff-pairs.txt found under gems/" >&2
  exit 1
fi

status=0
for t in "${targets[@]}"; do
  check_or_record_gem "$t" || status=1
done
exit "$status"
