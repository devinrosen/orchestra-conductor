# Conductor

This is the orchestration workspace for the Orchestra app. It contains:

- `main/` — the primary repository (Tauri v2 app: Rust backend + Svelte 5 frontend)
- `feat-<slug>/` or `fix-<slug>/` — git worktrees for feature and fix branches

## Architecture

See `main/CLAUDE.md` for full app architecture, build commands, and conventions.

## Scripts vs AI Workflows

Repeatable, deterministic operations live in `scripts/` as bash scripts. AI orchestration is reserved for steps that require judgment — selecting work, researching the codebase, writing plans, reviewing code, and synthesizing feedback.

**Scripts** (`scripts/`): Run directly from the shell. No AI needed.
- `init.sh` — clone repo and install deps
- `create-worktree.sh <slug>` — create a worktree and branch
- `delete-worktree.sh <slug>` — remove a worktree and branch
- `push-branch.sh <worktree-path>` — push a branch to origin
- `create-draft-pr.sh <worktree-path>` — push and open a draft PR
- `init-session.sh` — create a timestamped session directory in `postmortems/`
- `sync-issues.sh` — fetch open GitHub issues into `issues/`

**AI workflows**: Driven by the lead agent following the instructions below. These require codebase research, user interaction, and judgment calls that can't be scripted.
- Feature implementation (planning + domain-aware subagents)
- Merging (conflict resolution, FEATURES.md updates, manual commit review)
- Postmortem review (extracting and classifying actions from free-text reports)

When adding new automation, default to a script. Only use an AI workflow when the task genuinely requires reading code, making decisions, or interacting with the user.

## Subagent Workflow

This workspace uses subagents (not agent teams) for parallel development. The lead runs from this directory and orchestrates subagents working in isolated git worktrees.

### Creating worktrees

Use the script from this workspace root:

```bash
./scripts/create-worktree.sh <slug>
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

The lead agent handles merging: merge the branch into `main`, mark the feature as `[done]` in `FEATURES.md`, check for manual commits, and clean up using `./scripts/delete-worktree.sh <slug>`.

## Postmortem Review

Session postmortems collect in `postmortems/` (use `./scripts/init-session.sh` to create a new session directory). The lead agent reviews unprocessed postmortems, extracts actions, classifies them as **orchestration** (workflow/process changes) or **project** (code/docs/test changes in `main/`), and appends them to `ACTIONS.md`.

- `ACTIONS.md` — the living backlog of extracted actions, organized by scope
- Run postmortem review after each session or before starting a new planning phase
- Actions flagged by multiple postmortems are high priority
