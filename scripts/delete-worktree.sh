#!/usr/bin/env bash
set -euo pipefail

# Delete a git worktree and its branch, undoing create-worktree.sh.
# Usage: ./scripts/delete-worktree.sh <slug>
#
# Examples:
#   ./scripts/delete-worktree.sh smart-playlists
#   ./scripts/delete-worktree.sh fix-scan-crash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"
MAIN_DIR="$WORKSPACE/main"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <slug>"
  echo "  slug: worktree name (e.g., smart-playlists, fix-scan-crash)"
  exit 1
fi

SLUG="$1"

# Determine branch and worktree dir (mirrors create-worktree.sh logic)
if [[ "$SLUG" == fix-* ]]; then
  BRANCH="fix/${SLUG#fix-}"
  WORKTREE_DIR="$WORKSPACE/$SLUG"
else
  CLEAN_SLUG="${SLUG#feat-}"
  BRANCH="feat/$CLEAN_SLUG"
  WORKTREE_DIR="$WORKSPACE/feat-$CLEAN_SLUG"
fi

if [[ ! -d "$WORKTREE_DIR" ]]; then
  echo "Error: worktree does not exist at $WORKTREE_DIR"
  exit 1
fi

echo "Removing worktree at $WORKTREE_DIR..."
cd "$MAIN_DIR"
git worktree remove "$WORKTREE_DIR"

echo "Pruning stale worktree references..."
git worktree prune

echo "Deleting branch $BRANCH..."
git branch -D "$BRANCH"

echo ""
echo "Done. Worktree and branch cleaned up."
