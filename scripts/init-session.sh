#!/usr/bin/env bash
set -euo pipefail

# Create a timestamped session directory under postmortems/.
# Usage: ./scripts/init-session.sh
#
# Prints the timestamp and created directory path.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE="$(dirname "$SCRIPT_DIR")"

TIMESTAMP="$(date +%Y-%m-%dT%H-%M)"
SESSION_DIR="$WORKSPACE/postmortems/$TIMESTAMP"

if [[ -d "$SESSION_DIR" ]]; then
  echo "Session directory already exists: $SESSION_DIR"
  echo "$TIMESTAMP"
  exit 0
fi

mkdir -p "$SESSION_DIR"

echo "Session initialized: $SESSION_DIR"
echo "$TIMESTAMP"
