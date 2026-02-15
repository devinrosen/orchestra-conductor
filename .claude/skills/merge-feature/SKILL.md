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

### Step 2: Update FEATURES.md on the branch

1. Find the worktree for the branch (from `git worktree list`). If no worktree exists, create a temporary one.
2. Read `docs/FEATURES.md` in the worktree
3. Look for a feature entry whose title matches the branch slug (fuzzy match — e.g., branch `feat/eject-device-button` matches `**Eject/unmount device button**`)
4. If a match is found and its status is `[implemented]` or `[ ]`, update it to `[done]`
5. If a match is found and it's already `[done]`, skip — go straight to Step 3
6. If no match is found (e.g., a fix branch or ad-hoc work), skip — go straight to Step 3
7. If the match is ambiguous, show the candidates and ask the user which one
8. If FEATURES.md was changed, amend the branch's last commit: `git commit --amend --no-edit -- docs/FEATURES.md` (from the worktree)

### Step 2.5: Check for manual commits (user postmortem)

1. In the worktree, compare the branch commits to what agents authored. Run `git log --oneline --format="%h %s" main..<branch>` in the worktree to get all commits.
2. Cross-reference against agent postmortems in the most recent `postmortems/<timestamp>/` directory — agent postmortems mention their commit hash.
3. If there are commits **not** mentioned in any agent postmortem (i.e., the user made manual fixes), prompt the user:
   - "I see N commit(s) on this branch that weren't in the agent postmortems: `<hash> <message>`. Want to add a quick note about what you changed?"
   - If yes, ask for a brief description of what was fixed and why
   - Write `postmortems/<timestamp>/user-<slug>.md` with the standard user postmortem format (What Changed, Commits, Files Modified, Context)
4. If all commits are accounted for by agent postmortems, skip silently.

### Step 3: Merge

1. From `main/`, check if a GitHub PR exists for the branch: `gh pr view <branch> --json number,state`
2. **If a PR exists and is open:**
   - Merge via GitHub: `gh pr merge <branch> --merge --delete-branch` (from `main/`)
   - This merges the PR, deletes the remote branch, and records the merge on GitHub
   - Then pull locally: `git pull` (from `main/`)
3. **If no PR exists (or it was already closed):**
   - Fall back to local merge: `git merge <branch>` (from `main/`)
   - If there are merge conflicts:
     - Show the conflicted files to the user
     - Resolve each conflict, keeping changes from both sides where appropriate
     - Show the user what you resolved and ask for confirmation before completing the merge commit
   - If the merge is clean, it completes automatically
   - Push the merge to remote: `git push` (from `main/`)

### Step 4: Clean up git worktree

1. Run `git worktree list` to find any worktree associated with the branch
2. If a worktree exists, remove it: `git worktree remove <path>`
3. If the worktree directory still exists on disk (stale), remove it: `rm -rf <path>`
4. Run `git worktree prune` to clean up stale references
5. Delete the local branch if it still exists: `git branch -d <branch>`
6. Delete the remote branch if it still exists: `git push origin --delete <branch>` (skip if `gh pr merge --delete-branch` already removed it)

### Step 5: Clean up the orchestration directory

1. Check if a `feat-<slug>/` or `fix-<slug>/` directory exists at the orchestration workspace root (`../` relative to `main/`)
2. If it exists and is not a valid worktree (stale leftover), remove it

### Step 6: Summary

Report:
- Branch merged: `<branch>` → `main` (via PR #N / local merge)
- Conflicts: none / resolved (list files)
- Worktree cleaned: yes/no
- Directory cleaned: yes/no
- Remote branch cleaned: yes/no
- FEATURES.md updated: `<feature title>` → `[done]` / no match / already done
