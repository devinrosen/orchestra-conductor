# Orchestra Conductor

Orchestration workspace for coordinating parallel agent development on [Orchestra](https://github.com/devinrosen/orchestra), a desktop music library manager and device sync tool built with Tauri v2 (Rust + Svelte 5).

## Requirements

- [Claude Code](https://claude.ai/code) — this workspace is driven by Claude Code and subagents

## Getting Started

Clone this repo and run `./scripts/init.sh` to clone the [Orchestra](https://github.com/devinrosen/orchestra) repo into `main/` and install dependencies.

## Design Philosophy

Repeatable, deterministic operations are **bash scripts** (`scripts/`). AI orchestration is reserved for steps that require **judgment** — selecting work, researching the codebase, writing plans, reviewing code, and synthesizing feedback.

| Layer | Examples | Lives in |
|-------|----------|----------|
| Scripts | Create worktree, push branch, open draft PR, sync issues | `scripts/` |
| AI workflows | Feature planning, implementation, merging, postmortem review | Agent instructions in `CLAUDE.md` |

When adding new automation, default to a script. Only use an AI workflow when the task genuinely requires reading code, making decisions, or interacting with the user.

## Scripts

All scripts live in `scripts/` and are run directly from the shell:

| Script | Purpose |
|--------|---------|
| `init.sh` | Clone repo and install deps |
| `create-worktree.sh <slug>` | Create a worktree and branch |
| `delete-worktree.sh <slug>` | Remove a worktree and branch |
| `push-branch.sh <path>` | Push a branch to origin |
| `create-draft-pr.sh <path>` | Push and open a draft PR |
| `init-session.sh` | Create a timestamped session directory |
| `sync-issues.sh` | Fetch open GitHub issues into `issues/` |

## AI Workflow

The user acts as lead — selecting work, reviewing plans and implementations, and merging results — while the AI agent and its subagents handle research, planning, and coding.

### 1. Select and build

Start a session by asking the agent to implement features. The agent:

- Presents features from `main/docs/FEATURES.md` and pending cleanup actions from `ACTIONS.md` for you to select
- Creates an isolated git worktree per feature via `scripts/create-worktree.sh`
- Spawns **planning subagents** in parallel — each researches the codebase and writes a `PLAN.md`
- Presents each plan for your approval
- Spawns **domain-aware implementation subagents** for approved plans — Rust subagent for backend, Svelte subagent for frontend, or both sequentially for cross-layer features
- Wraps up with a summary of branches, commits, test results, and PR links

Small cleanup tasks can use **fast-track mode**, where a single subagent plans and implements in one pass.

### 2. Review branches

After implementation, each feature lives on its own branch in a worktree. Review at your own pace:

```bash
# See what branches are ready
cd main && git branch

# Check the diff for a feature
git log --oneline main..feat/play-queue
git diff main..feat/play-queue

# Run the app with a feature branch
cd ../feat-play-queue && npm run tauri dev
```

### 3. Merge

When a branch looks good, ask the agent to merge it. The agent:

- Merges the branch into `main`
- Marks the feature as `[done]` in `FEATURES.md`
- Checks for manual commits not captured by agent postmortems and prompts you to document them
- Cleans up the worktree and branch via `scripts/delete-worktree.sh`

### 4. Extract learnings

The lead writes a session postmortem at the end of each session, synthesizing feedback from subagent completion reports. These collect in `postmortems/`. The agent reviews them and:

- Reads all unprocessed postmortems
- Extracts actionable items (bug fixes, dead code, workflow improvements, documentation gaps)
- Classifies each as **orchestration** (workflow/process changes) or **project** (code changes in `main/`)
- Appends them to `ACTIONS.md`, deduplicating and flagging items raised by multiple agents

These actions feed back into step 1 — the next session offers them alongside new features, closing the loop.

### The cycle

```
implement features  →  review branches  →  merge  →  review postmortems
        ↑                                                      |
        └──────────── ACTIONS.md + FEATURES.md ←───────────────┘
```
