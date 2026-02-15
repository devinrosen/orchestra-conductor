# Plan: Rewrite `/implement-features` Skill

## Context

The current `/implement-features` skill spawns 2N+1 agents (planner + implementer per feature, plus lead) using a full agent team. Analysis in `docs/lessons/2026-02-15T07-16.md` identified this as expensive and unnecessarily complex. Planners don't need steering and implementers don't need to communicate — both are subagent use cases. The skill is also bloated at ~190 lines with a redundant Lessons Learned section.

This plan rewrites the skill to use **parallel planning subagents** and **sequential domain-aware implementation subagents** with no agent team, plus slims down postmortems and prunes the skill length.

## Changes

### 1. Replace agent team with subagents

**File:** `.claude/skills/implement-features/SKILL.md`

**Phase 2 (Planning)** — Replace teammate spawning with parallel `Task` subagents:
- Spawn one `general-purpose` subagent per feature using the `Task` tool, all in parallel
- Each subagent gets: worktree path, feature description, instruction to read CLAUDE.md, instruction to write PLAN.md
- Subagents run in background (`run_in_background: true`) so all plan in parallel
- Lead checks results, reads each PLAN.md from disk, presents to user for approval
- No team creation, no shutdown choreography, no messaging

**Phase 3 (Implementation)** — Replace teammate spawning with sequential domain-aware subagents:
- The planner's PLAN.md must label the feature as one of:
  - `backend-only` → spawn one Rust subagent
  - `frontend-only` → spawn one Svelte subagent
  - `cross-layer` → spawn Rust subagent first, then Svelte subagent (sequential)
  - `full-stack` → spawn one general subagent (when the split isn't clean)
- Each subagent uses `mode: "bypassPermissions"`
- Each subagent gets: worktree path, PLAN.md path, domain-specific instructions (which directories to focus on, which test command to run)
- Subagents for the SAME feature run sequentially (Rust before Svelte for cross-layer)
- Subagents for DIFFERENT features run sequentially (one feature at a time) — lead reviews between features
- Subagent pushes branch and implementer creates draft PR before finishing (move this responsibility from lead to agent)

**Remove entirely:**
- `TeamCreate` / `TeamDelete` calls
- Teammate shutdown logic
- Task list management
- All messaging instructions (send message to lead, etc.)

### 2. Domain-aware implementation subagent prompts

Add prompt templates for each domain:

**Rust subagent prompt includes:**
- Read CLAUDE.md and the **Backend** section of PLAN.md
- Work in `src-tauri/` directory
- Run `cargo test` before committing
- Stage specific files, never `git add -A`

**Svelte subagent prompt includes:**
- Read CLAUDE.md and the **Frontend** section of PLAN.md
- Work in `src/` directory
- Run `npm run check` before committing
- Stage specific files, never `git add -A`

**Full-stack subagent prompt** — combines both, runs both test commands.

### 3. Update planner prompt for domain labeling

Add to the planner subagent prompt:
- PLAN.md must include a `## Layer` field: `backend-only`, `frontend-only`, `cross-layer`, or `full-stack`
- For `cross-layer` plans, split into `## Backend` and `## Frontend` sections with a `## Shared Interface` section defining the Tauri command signatures

Keep all existing plan quality instructions (Scope indicator, Dead Code, Test Cases, Known Risks, pattern references, etc.) — these are already baked into the instructions and are valuable.

### 4. Slim postmortems to completion messages

**Remove from SKILL.md:**
- The entire "Postmortem Structure" section (~30 lines)
- Postmortem file-writing instructions from agent spawn prompts
- Lead postmortem writing from wrap-up

**Replace with:**
- Each subagent's prompt ends with: "In your final response, include a brief report: what worked, what was confusing or missing, and any codebase surprises."
- The lead writes ONE session postmortem (`postmortems/<timestamp>/session.md`) at wrap-up, synthesized from subagent completion messages
- Keeps the `/review-postmortems` pipeline working (it reads from `postmortems/`)

### 5. Prune Lessons Learned

**Remove the entire "Lessons Learned" section** (~25 lines, lines 168-191). Every item is either:
- Already baked into the instructions above it (e.g., "never use plan mode", "pre-check cleanup items")
- No longer relevant with the new subagent architecture (e.g., "shut down planners immediately")

Items that aren't yet in the instructions will be incorporated during the rewrite.

### 6. Specify Sonnet for subagents

All `Task` tool calls for planning and implementation subagents should include `model: "sonnet"`. The lead (which runs the skill) stays on whatever model the user chose — only the workers use Sonnet.

### 7. Update CLAUDE.md

**File:** `CLAUDE.md`

Update the "Agent Team Workflow" section to reflect the new subagent architecture:
- Remove references to teammates, team creation, shutdown
- Describe the subagent flow: parallel planning, sequential domain-aware implementation
- Keep worktree creation instructions (unchanged)

### 8. Update README.md

**File:** `README.md`

Update the workflow description in "1. Select and build" to reflect:
- Subagents instead of agent teams
- Domain-aware implementation
- No mention of "planner agents" and "implementer agents" as team members

## Files Modified

1. `.claude/skills/implement-features/SKILL.md` — major rewrite (target: ~120 lines, down from ~190)
2. `CLAUDE.md` — update Agent Team Workflow section
3. `README.md` — update workflow description

## Verification

After the rewrite:
1. Read the skill end-to-end and verify it's self-consistent (no references to teams, teammates, shutdown, messaging)
2. Verify CLAUDE.md and README.md match the new flow
3. Check that the skill is under 130 lines
4. Verify all plan quality instructions are preserved (Scope, Dead Code, Test Cases, Known Risks, pattern references, domain labeling, etc.)
5. Run a dry read of the skill imagining a 2-feature session (one cross-layer, one frontend-only) to verify the flow makes sense
