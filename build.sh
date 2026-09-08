#!/usr/bin/env bash
# Build a .skill file for each skill in skills/.
#
# A .skill file is a zip whose single top-level entry is the skill directory.
# Run this after editing a skill, or let the release workflow do it on tag push.
#
#   ./build.sh            build everything into dist/
#   ./build.sh <name>     build one skill
#
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST="$HERE/dist"
mkdir -p "$DIST"

build_one() {
  local name="$1"
  local src="$HERE/skills/$name"

  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "error: $src/SKILL.md not found" >&2
    return 1
  fi

  # The frontmatter name and the directory name must match or the skill
  # will not load. Catch it here rather than in a reporter's Claude app.
  local declared
  declared="$(sed -n 's/^name:[[:space:]]*//p' "$src/SKILL.md" | head -1 | tr -d '[:space:]')"
  if [[ "$declared" != "$name" ]]; then
    echo "error: skills/$name/SKILL.md declares name '$declared'" >&2
    echo "       the directory and the frontmatter name must match." >&2
    return 1
  fi

  # Skill names are validated as lowercase kebab-case.
  if ! [[ "$declared" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "error: '$declared' is not lowercase kebab-case" >&2
    return 1
  fi

  local out="$DIST/$name.skill"
  rm -f "$out"
  ( cd "$HERE/skills" && zip -r -q "$out" "$name" \
      -x '*.DS_Store' -x '*__MACOSX*' -x '*.swp' -x '*~' )
  echo "built dist/$name.skill"
}

if [[ $# -gt 0 ]]; then
  build_one "$1"
else
  found=0
  for d in "$HERE"/skills/*/; do
    [[ -f "$d/SKILL.md" ]] || continue
    build_one "$(basename "$d")"
    found=1
  done
  [[ "$found" == 1 ]] || { echo "no skills found under skills/" >&2; exit 1; }
fi
