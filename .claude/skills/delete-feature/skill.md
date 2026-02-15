---
name: delete-feature
description: Delete a feature or fix branch, clean up its worktree and directory, and reset FEATURES.md status. Use when you want to discard an implementation.
disable-model-invocation: true
argument-hint: [branch-name]
---

# /delete-feature

Discard a feature or fix branch and clean up all associated resources (worktree, directory, branch). No merge, no commit.

## Usage

```
/delete-feature <branch-name>
```

Branch name can be the full branch name (e.g., `feat/track-ratings`) or just the slug (e.g., `track-ratings`). The skill will resolve it.

## Workflow

### Step 1: Resolve the branch

1. Run `git branch --list` in `main/` to find the branch
2. If the user provided a slug, try `feat/<slug>` and `fix/<slug>` prefixes
3. If the branch doesn't exist, report the error and list available branches
4. Run `git log --oneline main..<branch>` to show what would be discarded

### Step 2: Confirm with the user

1. Show the commits that will be lost
2. Ask the user to confirm: "This will permanently delete branch `<branch>` and all its commits. Proceed?"

### Step 3: Reset FEATURES.md (on main)

1. Read `docs/FEATURES.md` in `main/`
2. Look for a feature entry whose title matches the branch slug (fuzzy match)
3. If a match is found and its status is `[implemented]` or `[designed]`, reset it to `[ ]`
4. If the status is already `[ ]` or `[done]`, skip
5. If no match is found (e.g., a fix branch), skip
6. Do NOT commit the FEATURES.md change — leave it as an unstaged modification for the user to review

### Step 4: Clean up git worktree

1. Run `git worktree list` to find any worktree associated with the branch
2. If a worktree exists, remove it: `git worktree remove --force <path>`
3. If the worktree directory still exists on disk (stale), remove it: `rm -rf <path>`
4. Run `git worktree prune` to clean up stale references
5. Force-delete the branch: `git branch -D <branch>`

### Step 5: Clean up the orchestration directory

1. Check if a `feat-<slug>/` or `fix-<slug>/` directory exists at the orchestration workspace root (`../` relative to `main/`)
2. If it exists, remove it: `rm -rf <path>`

### Step 6: Summary

Report:
- Branch deleted: `<branch>` (N commits discarded)
- Worktree cleaned: yes/no
- Directory cleaned: yes/no
- FEATURES.md reset: `<feature title>` → `[ ]` / no match / not changed
