---
name: implement-features
description: Plan and implement features using subagents with isolated git worktrees. Use when starting a new development session to build features from FEATURES.md.
disable-model-invocation: true
argument-hint: [feature-names]
---

# /implement-features

Plan and implement features using parallel planning subagents and domain-aware implementation subagents, each in an isolated git worktree.

## Usage

```
/implement-features <feature1>, <feature2>, ...
```

Features can be names from `main/docs/FEATURES.md` or freeform descriptions.

## Workflow

### Phase 1: Setup

1. Read `main/docs/FEATURES.md` and match requested features
2. Read `ACTIONS.md` and check for pending project-level actions (items under `## Project` that are unchecked).
3. **Interactive feature selection** — Use `AskUserQuestion` to present multi-select menus. The tool supports up to 4 questions (each with 2-4 options) per call, so organize by section:
   - **One question per FEATURES.md section** with available features (status `[ ]`). Each option label is the feature name, description is a one-line summary. Group sections into calls of up to 4 questions each. Skip sections with no available features. If the user passed feature names as arguments, skip the feature menus and use those.
   - **Separate call for project actions**: Multi-select of pending project actions from ACTIONS.md (if any exist). Each option label is the action name, description is a one-line summary. Include a "None" option.
4. **Pre-check cleanup items** — If the user chose to bundle cleanup actions, verify each one is still relevant before creating a worktree. For each unchecked project action, run a quick grep in `main/` to check if the target symbol/file still exists. Mark any already-resolved items as `[x]` in `ACTIONS.md` with a note, and drop them from the cleanup bundle. Report what was dropped to the user.
5. Generate a session timestamp: `YYYY-MM-DDTHH-MM` (e.g., `2026-02-13T15-04`)
6. For each feature, create a git worktree and install dependencies:
   ```bash
   cd main && git branch feat/<slug> main && git worktree add ../feat-<slug> feat/<slug>
   npm install --prefix ../feat-<slug>
   ```
7. Create a session postmortem directory: `postmortems/<timestamp>/`

### Phase 1.5: Fast-Track Check

Evaluate **each worktree independently** for fast-track eligibility. A session can mix fast-track and standard worktrees.

**Fast-track criteria** (ALL must be true):
- Work is purely mechanical: documentation changes, dead code removal, import cleanup, convention updates, small bug fixes with obvious solutions
- No architectural decisions or design choices required
- Scope is small enough for one agent to hold in context (roughly ≤3 files changed)

**Per-worktree evaluation:**
1. Classify each worktree as **fast-track** or **standard**
2. If ANY are fast-track eligible, ask the user to confirm: "These items look like small cleanup work — use fast-track mode? [list items]"

**Fast-track flow** (for eligible worktrees only):
1. Spawn one `general-purpose` subagent per fast-track worktree via `Task` tool with `mode: "bypassPermissions"` and `model: "sonnet"`
2. Agent writes a brief PLAN.md, implements immediately, runs tests, and commits
3. Lead reviews the commit diff (not a separate plan review step)

Standard worktrees proceed through Phase 2 and Phase 3 as normal. Fast-track subagents run in parallel with planning subagents.

### Phase 2: Planning (parallel subagents)

Spawn one `general-purpose` subagent per feature using the `Task` tool, **all in parallel** with `run_in_background: true` and `model: "sonnet"`.

Each planner subagent's prompt must include:
- Their worktree path
- The feature description from FEATURES.md
- Instruction to read `CLAUDE.md` in their worktree for project context
- Instruction to **only research and write PLAN.md** — no implementation
- PLAN.md required sections:
  - **Scope**: `S` (single-file, no arch decisions), `M` (2-5 files, some design choices), or `L` (6+ files, architectural decisions)
  - **Layer**: `backend-only`, `frontend-only`, `cross-layer`, or `full-stack`. For `cross-layer`, split into `## Backend`, `## Frontend`, and `## Shared Interface` (with exact Tauri command signatures)
  - **Dead Code**: functions that become unused (table for cleanup tasks: function, file, reason). `"None."` for S-scope if empty
  - **Test Cases**: exact test scenarios for new functions/commands
  - **Known Risks / Blockers**: technical uncertainties, external dependencies. `"None identified."` for S-scope if empty
- Plan quality rules:
  - Reference existing patterns by name for each new component (e.g., "model: follow `profile.rs`, store: follow `profilesStore`")
  - For uncertain fixes, use **"try A; if that doesn't work, fallback to B"** format
  - Be concise — cap reasoning sections at ~20 lines
  - When noting code duplication, include exact counts and list specific functions involved
  - New types/structs must note which are actually consumed vs. speculative
  - Bulk replacements must include a verification grep step
  - New conventions must include a **Fix Existing Violations** section
  - New model fields must grep for ALL files that construct/map the model (include the grep command)
  - New interactive elements near existing ones must flag HTML nesting constraints
  - TypeScript typed arrays / browser APIs must note explicit generic types
- End with a brief report: what worked, what was confusing or missing, any codebase surprises

**On planner completion:**
1. Read the PLAN.md from their worktree (verify it exists on disk)
2. Review the plan against the codebase (spot-check key files mentioned)
3. Present the plan to the user for approval

### Phase 3: Implementation (sequential domain-aware subagents)

For each approved plan, read the `## Layer` field and spawn subagents accordingly:

| Layer | Subagents | Order |
|-------|-----------|-------|
| `backend-only` | 1 Rust subagent | — |
| `frontend-only` | 1 Svelte subagent | — |
| `cross-layer` | 1 Rust + 1 Svelte | Rust first, then Svelte |
| `full-stack` | 1 general subagent | — |

All implementation subagents use `mode: "bypassPermissions"` and `model: "sonnet"`.

**Rust subagent prompt:**
- Read `CLAUDE.md` and the **Backend** section of PLAN.md
- Work in `src-tauri/` directory
- Run `cargo test` before committing
- Stage specific files by name — never `git add -A` or `git add .`
- Commit with a clear message on the current branch

**Svelte subagent prompt:**
- Read `CLAUDE.md` and the **Frontend** section of PLAN.md
- Work in `src/` directory
- Run `npm run check` before committing
- Stage specific files by name — never `git add -A` or `git add .`
- Commit with a clear message on the current branch

**Full-stack subagent prompt:**
- Read `CLAUDE.md` and all of PLAN.md
- Run both `cargo test` (from src-tauri/) and `npm run check` before committing
- Stage specific files by name — never `git add -A` or `git add .`
- Commit with a clear message on the current branch

**All implementation subagents must also:**
- Follow the plan strictly
- Mark the feature as `[implemented]` in `docs/FEATURES.md` (change `- [ ]` to `- [implemented]`) if it matches an entry. Do NOT mark as `[done]`
- Push the branch: `git push -u origin <branch>`
- End with a brief report: what worked, what was confusing or missing, any codebase surprises

**On implementer completion:**
1. Review the results (check test output, read the diff)
2. Create a draft PR from `main/`:
   ```bash
   gh pr create --draft --title "<feature name>" --body "<plan summary + test results>"
   ```
3. Move to the next approved plan

### Phase 4: Wrap-Up

1. Check `ACTIONS.md` for any items resolved by this session's work. Mark them `[x]`.
2. Write ONE session postmortem to `postmortems/<timestamp>/session.md` synthesizing all subagent completion reports. Include:
   - **Goal**: What the session was trying to accomplish
   - **Results**: Table of features, branches, commits, test results, PR links
   - **Agent Feedback**: Key themes from subagent reports (issues, codebase surprises, suggestions)
3. Present a final summary table to the user with branches, commits, test results, and PR links
4. Remind the user they can merge with `/merge-feature <branch>`
