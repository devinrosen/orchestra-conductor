#!/usr/bin/env bash
set -euo pipefail

# Fetch all open GitHub issues and create a markdown file for each in issues/.
# Usage: ./scripts/sync-issues.sh
#
# Each issue becomes issues/<number>.md with frontmatter-style metadata
# and the full body + comments.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"
MAIN_DIR="$WORKSPACE/main"
ISSUES_DIR="$WORKSPACE/issues"

mkdir -p "$ISSUES_DIR"

# Work from main repo so gh picks up the right remote
cd "$MAIN_DIR"

echo "Fetching open issues..."
NUMBERS=$(gh issue list --state open --limit 200 --json number --jq '.[].number')

# Clear stale issue files — remove any that no longer correspond to an open issue
for existing in "$ISSUES_DIR"/*.md; do
  [[ -e "$existing" ]] || continue
  num="$(basename "$existing" .md)"
  if [[ -z "$NUMBERS" ]] || ! echo "$NUMBERS" | grep -qx "$num"; then
    echo "Removing closed/stale issue: $existing"
    rm "$existing"
  fi
done

if [[ -z "$NUMBERS" ]]; then
  echo "No open issues found."
  exit 0
fi

for NUM in $NUMBERS; do
  echo "Fetching issue #$NUM..."
  JSON=$(gh issue view "$NUM" --json number,title,body,labels,assignees,state,createdAt,updatedAt,comments)

  TITLE=$(echo "$JSON" | jq -r '.title')
  CREATED=$(echo "$JSON" | jq -r '.createdAt')
  UPDATED=$(echo "$JSON" | jq -r '.updatedAt')
  LABELS=$(echo "$JSON" | jq -r '[.labels[].name] | join(", ")')
  ASSIGNEES=$(echo "$JSON" | jq -r '[.assignees[].login] | join(", ")')
  BODY=$(echo "$JSON" | jq -r '.body // ""')
  COMMENTS_JSON=$(echo "$JSON" | jq -r '.comments')

  FILE="$ISSUES_DIR/$NUM.md"

  {
    echo "# #$NUM — $TITLE"
    echo ""
    echo "- **State:** OPEN"
    echo "- **Created:** $CREATED"
    echo "- **Updated:** $UPDATED"
    [[ -n "$LABELS" ]] && echo "- **Labels:** $LABELS"
    [[ -n "$ASSIGNEES" ]] && echo "- **Assignees:** $ASSIGNEES"
    echo ""
    echo "## Description"
    echo ""
    echo "$BODY"

    # Append comments if any
    COMMENT_COUNT=$(echo "$COMMENTS_JSON" | jq 'length')
    if [[ "$COMMENT_COUNT" -gt 0 ]]; then
      echo ""
      echo "## Comments"
      for i in $(seq 0 $((COMMENT_COUNT - 1))); do
        AUTHOR=$(echo "$COMMENTS_JSON" | jq -r ".[$i].author.login")
        DATE=$(echo "$COMMENTS_JSON" | jq -r ".[$i].createdAt")
        CBODY=$(echo "$COMMENTS_JSON" | jq -r ".[$i].body")
        echo ""
        echo "### $AUTHOR ($DATE)"
        echo ""
        echo "$CBODY"
      done
    fi
  } > "$FILE"

  echo "  → $FILE"
done

echo ""
echo "Done. $(echo "$NUMBERS" | wc -l | tr -d ' ') issue(s) synced to $ISSUES_DIR/"
