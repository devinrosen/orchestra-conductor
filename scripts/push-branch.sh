#!/usr/bin/env bash
set -euo pipefail

# Push the current branch of a worktree to origin with tracking.
# Usage: ./scripts/push-branch.sh <worktree-path>
#
# Examples:
#   ./scripts/push-branch.sh feat-smart-playlists
#   ./scripts/push-branch.sh /Users/me/orchestra-conductor/feat-smart-playlists

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <worktree-path>"
  exit 1
fi

WORKTREE="$1"

# Resolve relative paths against workspace root
if [[ "$WORKTREE" != /* ]]; then
  WORKTREE="$WORKSPACE/$WORKTREE"
fi

if [[ ! -d "$WORKTREE" ]]; then
  echo "Error: directory not found: $WORKTREE"
  exit 1
fi

BRANCH=$(git -C "$WORKTREE" rev-parse --abbrev-ref HEAD)

echo "Pushing branch $BRANCH from $WORKTREE..."
git -C "$WORKTREE" push -u origin "$BRANCH"

echo "Done. Branch $BRANCH pushed to origin."
