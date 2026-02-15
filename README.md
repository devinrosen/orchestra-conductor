# Orchestra Conductor

Orchestration workspace for coordinating parallel agent development on [Orchestra](https://github.com/devinrosen/orchestra), a desktop music library manager and device sync tool built with Tauri v2 (Rust + Svelte 5).

## Getting Started

1. Clone this repo and run `/init` to clone the [Orchestra](https://github.com/devinrosen/orchestra) repo into `main/` and install dependencies.

2. Enable [agent teams](https://code.claude.com/docs/en/agent-teams) in Claude Code — they are experimental and off by default. Add this to your `settings.json`:

   ```json
   {
     "env": {
       "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
     }
   }
   ```

## Workflow

This workspace uses [Claude Code](https://claude.ai/code) skills to run a semi-autonomous development cycle. The user acts as a team lead — selecting work, reviewing plans and implementations, and merging results — while agent teams handle the research, planning, and coding in parallel.

### 1. Select and build — `/implement-features`

Start a session by running `/implement-features`. The skill:

- Presents features from `main/docs/FEATURES.md` and pending cleanup actions from `ACTIONS.md` as interactive menus for you to select from
- Creates an isolated git worktree per feature (e.g., `feat-play-queue/`)
- Spawns **planner agents** in parallel — each researches the codebase in their worktree and writes a `PLAN.md`
- Presents each plan for your approval
- Spawns **implementer agents** for approved plans — each follows the plan, runs tests (`cargo test`, `npm run check`), and commits
- Wraps up with a summary of branches, commits, and test results

Small cleanup tasks can use **fast-track mode**, where a single agent plans and implements in one pass.

### 2. Review branches

After implementation, each feature lives on its own branch in a worktree. You can review at your own pace:

```bash
# See what branches are ready
cd main && git branch

# Check the diff for a feature
git log --oneline main..feat/play-queue
git diff main..feat/play-queue

# Run the app with a feature branch
cd ../feat-play-queue && npm run tauri dev

# Visual QA with screenshots
/ui-test
```

You can also use `/session-note` to record any manual fixes or observations you make while reviewing.

### 3. Merge — `/merge-feature`

When a branch looks good, run `/merge-feature <slug>`. The skill:

- Merges the branch into `main`
- Marks the feature as `[done]` in `FEATURES.md`
- Checks for manual commits not captured by agent postmortems and prompts you to document them
- Cleans up the worktree and branch

### 4. Extract learnings — `/review-postmortems`

Every agent (planners, implementers, and the lead) writes a postmortem at the end of each session. These collect in `postmortems/`. Running `/review-postmortems`:

- Reads all unprocessed postmortems
- Extracts actionable items (bug fixes, dead code, workflow improvements, documentation gaps)
- Classifies each as **orchestration** (workflow/skill changes) or **project** (code changes in `main/`)
- Appends them to `ACTIONS.md`, deduplicating and flagging items raised by multiple agents

These actions feed back into step 1 — the next `/implement-features` session offers them alongside new features, closing the loop.

### The cycle

```
/implement-features  →  review branches  →  /merge-feature  →  /review-postmortems
        ↑                                                              |
        └──────────────── ACTIONS.md + FEATURES.md ←───────────────────┘
```
