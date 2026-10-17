#!/usr/bin/env bash
# Link every skill in this repo into the local skill directory used by Pi.
#
# The repo is CATEGORIZED (skills/<category>/<skill>); the destination is FLAT
# (one entry per skill), because that is what the agent harnesses expect.
# Entries are LINKS (junction on Windows, symlink elsewhere), so a `git pull`
# is all that is needed to keep installed skills up to date — nothing is copied.
#
# Usage:  bash link-skills.sh
# Env:    PI_SKILLS_DIR  override destination (default: ~/.pi/agent/skills)

set -uo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO/skills"
DST="${PI_SKILLS_DIR:-$HOME/.pi/agent/skills}"

[ -d "$SRC" ] || { echo "skills dir not found: $SRC"; exit 1; }
mkdir -p "$DST"

is_windows() {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

link_one() {
  local target="$1" linkpath="$2"
  # Remove any existing entry WITHOUT touching the target:
  #  - symlink  -> rm -f   (never rmtree a link)
  #  - junction -> rmdir   (only the reparse point)
  #  - copy     -> rm -rf
  if [ -L "$linkpath" ]; then
    rm -f "$linkpath"
  elif [ -e "$linkpath" ]; then
    if is_windows; then cmd //c rmdir "$(cygpath -w "$linkpath")" 2>/dev/null; fi
    [ -e "$linkpath" ] && rm -rf "$linkpath"
  fi

  if is_windows; then
    powershell -NoProfile -Command \
      "New-Item -ItemType Junction -Path '$(cygpath -w "$linkpath")' -Target '$(cygpath -w "$target")' | Out-Null"
  else
    ln -sfn "$target" "$linkpath"
  fi
}

count=0
fail=0
while IFS= read -r -d '' md; do
  skill_dir="$(dirname "$md")"
  name="$(basename "$skill_dir")"
  if link_one "$skill_dir" "$DST/$name"; then
    echo "  linked $name"
    count=$((count + 1))
  else
    echo "  FAILED $name"
    fail=$((fail + 1))
  fi
done < <(find "$SRC" -name SKILL.md -not -path '*/node_modules/*' -print0)

echo ""
echo "linked $count skills -> $DST"
[ "$fail" -eq 0 ] || { echo "($fail failed)"; exit 1; }
