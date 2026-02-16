#!/usr/bin/env bash
set -euo pipefail

# Push the branch and create a draft PR from a worktree.
# Reads PLAN.md in the worktree for the PR body if available.
# Usage: ./scripts/create-draft-pr.sh <worktree-path> [title]
#
# Examples:
#   ./scripts/create-draft-pr.sh feat-smart-playlists
#   ./scripts/create-draft-pr.sh feat-smart-playlists "Smart Playlists"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <worktree-path> [title]"
  exit 1
fi

WORKTREE="$1"
TITLE="${2:-}"

# Resolve relative paths against workspace root
if [[ "$WORKTREE" != /* ]]; then
  WORKTREE="$WORKSPACE/$WORKTREE"
fi

if [[ ! -d "$WORKTREE" ]]; then
  echo "Error: directory not found: $WORKTREE"
  exit 1
fi

BRANCH=$(git -C "$WORKTREE" rev-parse --abbrev-ref HEAD)

# Default title from branch name: feat/smart-playlists → smart-playlists → Smart Playlists
if [[ -z "$TITLE" ]]; then
  SLUG="${BRANCH#feat/}"
  SLUG="${SLUG#fix/}"
  TITLE=$(echo "$SLUG" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
fi

# Build PR body from PLAN.md if it exists
PLAN_FILE="$WORKTREE/PLAN.md"
if [[ -f "$PLAN_FILE" ]]; then
  # Extract the Scope and Layer lines, plus the first paragraph after ## Scope or the top-level description
  SCOPE=$(grep -m1 '^\*\*Scope\*\*' "$PLAN_FILE" 2>/dev/null || echo "")
  LAYER=$(grep -m1 '^\*\*Layer\*\*' "$PLAN_FILE" 2>/dev/null || echo "")

  BODY="## Plan Summary"$'\n\n'
  [[ -n "$SCOPE" ]] && BODY+="- $SCOPE"$'\n'
  [[ -n "$LAYER" ]] && BODY+="- $LAYER"$'\n'
  BODY+=$'\n'"Full plan in \`PLAN.md\` on this branch."
else
  BODY="Implementation for branch \`$BRANCH\`."
fi

# Push branch first
echo "Pushing branch $BRANCH..."
git -C "$WORKTREE" push -u origin "$BRANCH"

# Create draft PR from main/ (so gh picks up the right repo)
MAIN_DIR="$WORKSPACE/main"
echo "Creating draft PR..."
PR_URL=$(gh pr create \
  --repo "$(git -C "$MAIN_DIR" remote get-url origin)" \
  --head "$BRANCH" \
  --base main \
  --draft \
  --title "$TITLE" \
  --body "$(cat <<EOF
$BODY
EOF
)")

echo ""
echo "Done. Draft PR created:"
echo "$PR_URL"
