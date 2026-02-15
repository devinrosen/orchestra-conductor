---
name: init
description: Initialize the conductor workspace by cloning the Orchestra repo into main/ and installing dependencies. Run this after a fresh clone of the conductor repo.
disable-model-invocation: true
---

# /init

Initialize the conductor workspace by cloning the Orchestra repo and installing dependencies.

## Steps

1. Check if `main/` already exists in the workspace root
   - If it exists and contains a git repo, skip cloning and report "Already initialized"
   - If it exists but is not a git repo, warn the user and stop
2. Clone the Orchestra repo:
   ```bash
   git clone git@github.com:devinrosen/orchestra.git main
   ```
3. Install npm dependencies:
   ```bash
   npm install --prefix main
   ```
4. Confirm success: verify `main/CLAUDE.md` exists and report ready
