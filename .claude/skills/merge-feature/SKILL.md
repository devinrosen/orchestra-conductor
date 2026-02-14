---
name: merge-feature
description: Merge a feature or fix branch into main, clean up the worktree, and update FEATURES.md. Use when a feature implementation is complete and tested.
disable-model-invocation: true
argument-hint: [branch-name]
---

# /merge-feature

Merge a feature or fix branch into main, clean up the worktree, and update FEATURES.md.

## Usage

```
/merge-feature <branch-name>
```

Branch name can be the full branch name (e.g., `feat/eject-device-button`) or just the slug (e.g., `eject-device-button`). The skill will resolve it.

## Workflow

### Step 1: Resolve the branch

1. Run `git branch --list` in `main/` to find the branch
2. If the user provided a slug, try `feat/<slug>` and `fix/<slug>` prefixes
3. If the branch doesn't exist, report the error and list available branches
4. Run `git log --oneline main..<branch>` to show what will be merged

### Step 2: Merge

1. From `main/`, run `git merge <branch>`
2. If there are merge conflicts:
   - Show the conflicted files to the user
   - Resolve each conflict, keeping changes from both sides where appropriate
   - Show the user what you resolved and ask for confirmation before completing the merge commit
3. If the merge is clean, it completes automatically

### Step 3: Clean up git worktree

1. Run `git worktree list` to find any worktree associated with the branch
2. If a worktree exists, remove it: `git worktree remove <path>`
3. If the worktree directory still exists on disk (stale), remove it: `rm -rf <path>`
4. Run `git worktree prune` to clean up stale references
5. Delete the branch: `git branch -d <branch>`

### Step 4: Clean up the orchestration directory

1. Check if a `feat-<slug>/` or `fix-<slug>/` directory exists at the orchestration workspace root (`../` relative to `main/`)
2. If it exists and is not a valid worktree (stale leftover), remove it

### Step 5: Update FEATURES.md

1. Read `main/docs/FEATURES.md`
2. Look for a feature entry whose title matches the branch slug (fuzzy match — e.g., branch `feat/eject-device-button` matches `**Eject/unmount device button**`)
3. If a match is found and its status is `[implemented]` or `[ ]`, update it to `[done]`
4. If a match is found and it's already `[done]`, skip
5. If no match is found (e.g., a fix branch or ad-hoc work), inform the user — no update needed
6. If the match is ambiguous, show the candidates and ask the user which one

### Step 6: Summary

Report:
- Branch merged: `<branch>` → `main`
- Conflicts: none / resolved (list files)
- Worktree cleaned: yes/no
- Directory cleaned: yes/no
- FEATURES.md updated: `<feature title>` → `[done]` / no match / already done
