#!/usr/bin/env bash
# Install (or refresh) this repo's skills into the pi agent skills dir.
# One-way: repo is the source of truth; installed copies are overwritten.
# Skills in ~/.pi/agent/skills that are NOT in this repo are left untouched.
#
# Usage: bash install.sh   (from anywhere)
set -uo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO/skills"
DST="${PI_SKILLS_DIR:-$HOME/.pi/agent/skills}"

[ -d "$SRC" ] || { echo "SKILLS dir not found: $SRC"; exit 1; }
mkdir -p "$DST"

echo "Install repo -> $DST"
FAIL=0
for s in "$SRC"/*/; do
    name="$(basename "$s")"
    rm -rf "$DST/$name"
    cp -r "$s" "$DST/$name"
    if diff -rq "$s" "$DST/$name" >/dev/null 2>&1; then
        echo "  installed $name"
    else
        echo "  DIFF after copy: $name"; FAIL=1
    fi
done

echo ""
echo "Extra skills in install dir (not from this repo, kept):"
for d in "$DST"/*/; do
    name="$(basename "$d")"
    [ -d "$SRC/$name" ] || echo "  $name"
done

[ "$FAIL" -eq 0 ] && echo "INSTALL OK" || { echo "INSTALL HAS DIFFS"; exit 1; }
