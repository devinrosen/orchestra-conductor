#!/usr/bin/env bash
set -euo pipefail

# Initialize the conductor workspace by cloning the Orchestra repo into main/
# and installing dependencies. Run after a fresh clone of the conductor repo.
# Usage: ./scripts/init.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"
MAIN_DIR="$WORKSPACE/main"

if [[ -d "$MAIN_DIR" ]]; then
  if [[ -d "$MAIN_DIR/.git" ]]; then
    echo "Already initialized: $MAIN_DIR"
    exit 0
  else
    echo "Error: $MAIN_DIR exists but is not a git repo."
    exit 1
  fi
fi

echo "Cloning Orchestra repo into main/..."
git clone git@github.com:devinrosen/orchestra.git "$MAIN_DIR"

echo "Installing npm dependencies..."
npm install --prefix "$MAIN_DIR"

if [[ -f "$MAIN_DIR/CLAUDE.md" ]]; then
  echo ""
  echo "Done. Workspace initialized at $MAIN_DIR"
else
  echo ""
  echo "Warning: clone succeeded but CLAUDE.md not found in $MAIN_DIR"
  exit 1
fi
