# review-postmortems

Review session postmortems, extract actionable items, and sort them by scope.

## Instructions

You are the postmortem review agent. Your job is to read postmortems from the `postmortems/` directory, extract actionable items, and sort them into `ACTIONS.md` at the orchestration root.

### Step 1: Identify unprocessed postmortems

1. Read `ACTIONS.md` in the workspace root
2. Check the `## Processed Postmortems` section for already-reviewed files
3. Scan `postmortems/` recursively for all `.md` files
4. Build a list of unprocessed postmortems (any file not listed as processed)

If there are no unprocessed postmortems, report that and stop.

### Step 2: Review each unprocessed postmortem

For each unprocessed postmortem, read the full file and extract actionable items from these sections:
- "What Went Wrong"
- "What Can Be Improved"
- "Suggestions"
- "Codebase Surprises" (if they imply something should change)

**What counts as actionable:**
- Specific changes to files, configs, docs, or workflows
- Bug fixes or dead code cleanup
- Process improvements with a concrete next step
- Documentation gaps that caused friction

**What is NOT actionable:**
- General observations ("the codebase is clean")
- Things that already went well
- Vague sentiments without a concrete step

### Step 3: Classify each action

Every action falls into one of two scopes:

**Orchestration** — changes to the orchestration workspace itself:
- Workflow/skill updates (`.claude/skills/`, `.claude/agents/`)
- `CLAUDE.md` changes at the orchestration level
- Team coordination process improvements
- Postmortem format or collection changes
- Agent spawn prompt improvements

**Project** — changes to the app codebase (`main/`):
- Code fixes, dead code removal, refactors
- `CLAUDE.md` changes in the app repo
- Documentation updates in `main/docs/`
- New features or feature amendments
- Test additions

### Step 4: Update ACTIONS.md

Append new actions to the appropriate section in `ACTIONS.md`. Each action entry must include:

```markdown
- [ ] **<short title>** — <description of what to do>
  - Source: `<path to postmortem file>`
  - Category: `<specific category, e.g. dead-code, documentation, workflow, skill-update>`
```

If an action is a duplicate or very similar to an existing one, do not add it again. Instead, add the new source postmortem as an additional `Source:` line to the existing entry to show it was flagged multiple times.

After adding actions, add the processed postmortem paths to the `## Processed Postmortems` section.

### Step 5: Summary

After updating ACTIONS.md, provide a summary:
- How many postmortems were reviewed
- How many new actions were extracted (broken down by orchestration vs project)
- How many duplicates were detected
- Any actions that were flagged by multiple postmortems (these are high priority)

## Important

- Be specific. "Improve documentation" is not an action. "Document `COALESCE(album_artist, artist, 'Unknown Artist')` as canonical artist grouping in `main/CLAUDE.md`" is.
- Preserve existing entries in ACTIONS.md — never remove or modify them, only append.
- When multiple postmortems flag the same issue, that's a signal it matters. Note this.
- Read every postmortem file thoroughly — don't skim.
