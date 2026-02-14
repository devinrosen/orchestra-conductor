# Music Management Workspace

This is the orchestration workspace for the music-management app. It contains:

- `main/` — the primary repository (Tauri v2 app: Rust backend + Svelte 5 frontend)
- `feat-<slug>/` — git worktrees for feature branches, one per feature

## Architecture

See `main/CLAUDE.md` for full app architecture, build commands, and conventions.

## Agent Team Workflow

This workspace is designed for agent teams. The team lead runs from this directory and coordinates teammates working in isolated git worktrees.

### Creating worktrees

From this workspace root:

```bash
cd main && git branch feat/<slug> main && git worktree add ../feat-<slug> feat/<slug>
npm install --prefix ../feat-<slug>
```

### Spawning teammates

Each teammate should be assigned to ONE worktree. Include in their spawn prompt:
- The full path to their worktree: `./feat-<slug>/`
- The feature they're implementing (title + description from `main/docs/FEATURES.md`)
- Instruction to read `CLAUDE.md` in their worktree for project context
- Their specific role (planner or implementer)

### Planning phase

1. Read `main/docs/FEATURES.md` for the feature list
2. Create a worktree per selected feature
3. Spawn a planning teammate per worktree with plan approval required
4. Each planner researches the codebase in their worktree and writes `PLAN.md`
5. Lead reviews and approves/rejects plans before implementation

### Implementation phase

1. For each approved plan, spawn an implementation teammate in the same worktree
2. Implementer reads `PLAN.md` and follows it strictly
3. Implementer runs `cargo test` (from src-tauri/) and `npm run check` before committing
4. Lead verifies results after implementation

### Merging

When a feature is complete:
```bash
cd main && git merge feat/<slug>
git worktree remove ../feat-<slug>
git branch -d feat/<slug>
```

## Postmortem Review

Session postmortems collect in `postmortems/`. Use `/review-postmortems` to extract actionable items.

The skill reads unprocessed postmortems, extracts actions, classifies them as **orchestration** (workflow/skill/process changes) or **project** (code/docs/test changes in `main/`), and appends them to `ACTIONS.md`.

- `ACTIONS.md` — the living backlog of extracted actions, organized by scope
- Run the agent after each session or before starting a new planning phase
- Actions flagged by multiple postmortems are high priority
