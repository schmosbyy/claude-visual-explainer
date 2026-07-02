#!/usr/bin/env bash
# open-explainer.sh — copy a self-contained explainer HTML into the FIXED cache dir
# (~/.cache/claude-explainers) and open it in the user's default browser. NOT a temp dir:
# the path must be stable so SKILL.md's pre-approved Write/open rules keep matching.
#
# Usage:
#   open-explainer.sh <path-to-html>
#
# Env:
#   OPENER   override the browser-opening command (receives the file path).
set -euo pipefail

SRC="${1:-}"

if [[ -z "$SRC" ]]; then
  echo "usage: open-explainer.sh <path-to-html>" >&2
  exit 2
fi
if [[ ! -f "$SRC" ]]; then
  echo "error: file not found: $SRC" >&2
  exit 2
fi

DEST_DIR="${HOME}/.cache/claude-explainers"
mkdir -p "$DEST_DIR"
BASENAME="$(basename "$SRC")"
DEST="$DEST_DIR/$BASENAME"
if [[ ! "$SRC" -ef "$DEST" ]]; then
  cp "$SRC" "$DEST"
fi

open_cmd=""
if [[ -n "${OPENER:-}" ]]; then
  open_cmd="${OPENER}"
elif command -v open >/dev/null 2>&1; then
  open_cmd="open"
elif command -v xdg-open >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
  open_cmd="xdg-open"
elif command -v wslview >/dev/null 2>&1; then
  open_cmd="wslview"
fi

if [[ -n "$open_cmd" ]]; then
  if $open_cmd "$DEST" >/dev/null 2>&1; then
    echo "opened: $DEST"
    exit 0
  fi
fi

echo "could not auto-open a browser (headless or no opener)." >&2
echo "open this file in your browser:" >&2
echo "file: $DEST"
exit 0
