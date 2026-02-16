#!/usr/bin/env bash
set -euo pipefail

# Create a git worktree for a feature or fix branch.
# Usage: ./scripts/create-worktree.sh <slug> [base-branch]
#
# Examples:
#   ./scripts/create-worktree.sh smart-playlists        # creates feat-smart-playlists/
#   ./scripts/create-worktree.sh fix-scan-crash          # creates fix-scan-crash/
#
# The slug determines the branch prefix:
#   fix-*  → fix/<slug>  branch
#   *      → feat/<slug> branch

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"
MAIN_DIR="$WORKSPACE/main"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <slug> [base-branch]"
  echo "  slug:        worktree name (e.g., smart-playlists, fix-scan-crash)"
  echo "  base-branch: branch to base off (default: main)"
  exit 1
fi

SLUG="$1"
BASE="${2:-main}"

# Determine branch prefix from slug
if [[ "$SLUG" == fix-* ]]; then
  BRANCH="fix/${SLUG#fix-}"
  WORKTREE_DIR="$WORKSPACE/$SLUG"
else
  # Strip feat- prefix if user included it
  CLEAN_SLUG="${SLUG#feat-}"
  BRANCH="feat/$CLEAN_SLUG"
  WORKTREE_DIR="$WORKSPACE/feat-$CLEAN_SLUG"
fi

if [[ -d "$WORKTREE_DIR" ]]; then
  echo "Error: worktree already exists at $WORKTREE_DIR"
  exit 1
fi

echo "Creating branch $BRANCH from $BASE..."
cd "$MAIN_DIR"
git branch "$BRANCH" "$BASE"

echo "Creating worktree at $WORKTREE_DIR..."
git worktree add "$WORKTREE_DIR" "$BRANCH"

echo "Installing npm dependencies..."
npm install --prefix "$WORKTREE_DIR"

echo ""
echo "Done. Worktree ready at: $WORKTREE_DIR"
echo "Branch: $BRANCH"
