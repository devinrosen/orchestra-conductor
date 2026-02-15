# Conductor

This is the orchestration workspace for the Orchestra app. It contains:

- `main/` — the primary repository (Tauri v2 app: Rust backend + Svelte 5 frontend)
- `feat-<slug>/` or `fix-<slug>/` — git worktrees for feature and fix branches

## Architecture

See `main/CLAUDE.md` for full app architecture, build commands, and conventions.

## Subagent Workflow

This workspace uses subagents (not agent teams) for parallel development. The lead runs from this directory and orchestrates subagents working in isolated git worktrees.

### Creating worktrees

From this workspace root:

```bash
cd main && git branch feat/<slug> main && git worktree add ../feat-<slug> feat/<slug>
npm install --prefix ../feat-<slug>
```

### Planning phase (parallel subagents)

1. Read `main/docs/FEATURES.md` for the feature list
2. Create a worktree per selected feature
3. Spawn one planning subagent per worktree in parallel (via `Task` tool with `run_in_background: true`)
4. Each planner researches the codebase and writes `PLAN.md` with Scope, Layer, Dead Code, Test Cases, and Known Risks sections
5. Lead reviews and approves/rejects each plan

### Implementation phase (domain-aware subagents)

Plans include a `Layer` field (`backend-only`, `frontend-only`, `cross-layer`, `full-stack`) that determines which subagents to spawn:
- **Backend-only**: Rust subagent (works in `src-tauri/`, runs `cargo test`)
- **Frontend-only**: Svelte subagent (works in `src/`, runs `npm run check`)
- **Cross-layer**: Rust subagent first, then Svelte subagent (sequential)
- **Full-stack**: single subagent handling both layers

### Merging

Use `/merge-feature <slug>` to merge, clean up worktrees/branches, and update FEATURES.md.

## Postmortem Review

Session postmortems collect in `postmortems/`. Use `/review-postmortems` to extract actionable items.

The skill reads unprocessed postmortems, extracts actions, classifies them as **orchestration** (workflow/skill/process changes) or **project** (code/docs/test changes in `main/`), and appends them to `ACTIONS.md`.

- `ACTIONS.md` — the living backlog of extracted actions, organized by scope
- Run the agent after each session or before starting a new planning phase
- Actions flagged by multiple postmortems are high priority
