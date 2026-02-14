---
name: session-note
description: Add a postmortem note for manual work done in a worktree (bug fixes, tweaks, testing observations). Use after making changes that agents won't capture.
disable-model-invocation: true
argument-hint: [branch-slug] [description]
---

# /session-note

Add a postmortem entry for manual work done in a feature worktree. Use this when you've jumped into a worktree to fix bugs, tweak behavior, or make changes that the agent didn't capture in its postmortem.

## Usage

```
/session-note <branch-slug> <description>
```

Examples:
```
/session-note playback-visualization Fixed z-index overlap between visualizer and queue panel
/session-note ui-skins Adjusted light theme contrast for sidebar text
```

If no arguments are provided, prompt the user interactively.

## Workflow

### Step 1: Resolve the session directory

1. Find the most recent postmortem session directory by listing `postmortems/` and sorting by timestamp
2. If multiple sessions exist from today, use the most recent one
3. Confirm the session with the user: "Adding note to session `<timestamp>` — is this correct?"
4. If the user says no, list available sessions and let them pick

### Step 2: Gather details

If description was provided as an argument, use it. Otherwise, ask the user:

1. **What did you change?** — Brief description of the fix/tweak
2. **Which files were modified?** — Auto-detect from `git diff` or `git log` in the worktree if possible
3. **Why?** — What was wrong or what triggered the change (optional)

### Step 3: Check for new commits

Look at the worktree for the branch slug (try `feat-<slug>/` and `fix-<slug>/`):
1. Run `git log --oneline` in the worktree to find commits not authored by an agent
2. Include commit hashes and messages in the postmortem note

### Step 4: Write the postmortem note

Create `postmortems/<timestamp>/user-<slug>.md` with this structure:

```markdown
# User Postmortem: <slug>

## What Changed
<description from user or arguments>

## Commits
<list of manual commits with hashes, if any>

## Files Modified
<list of files changed>

## Context
<why the change was needed — what bug was found, what didn't look right, etc.>
```

### Step 5: Confirm

Show the user what was written and where.
