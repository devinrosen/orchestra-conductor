---
name: implement-features
description: Plan and implement features using an agent team with isolated git worktrees. Use when starting a new development session to build features from FEATURES.md.
disable-model-invocation: true
argument-hint: [feature-names]
---

# /implement-features

Plan and implement features using an agent team with isolated git worktrees.

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
4. **Pre-check cleanup items** — If the user chose to bundle cleanup actions, verify each one is still relevant before creating a worktree. For each unchecked project action, run a quick grep in `main/` to check if the target symbol/file still exists (e.g., `grep -r "get_tracks_by_artists" main/src-tauri/`). Mark any already-resolved items as `[x]` in `ACTIONS.md` with a note, and drop them from the cleanup bundle. Report what was dropped to the user.
5. Generate a session timestamp: `YYYY-MM-DDTHH-MM` (e.g., `2026-02-13T15-04`)
6. Create a team using the timestamp (e.g., `feature-impl-2026-02-13T15-04`)
7. For each feature, create a git worktree and install dependencies:
   ```bash
   cd main && git branch feat/<slug> main && git worktree add ../feat-<slug> feat/<slug>
   npm install --prefix ../feat-<slug>
   ```
8. Create a session postmortem directory: `postmortems/<timestamp>/` (e.g., `postmortems/2026-02-13T15-04/`)

### Phase 1.5: Fast-Track Check

After setup, evaluate **each worktree independently** for fast-track eligibility. A session can mix fast-track and standard-mode worktrees.

**Fast-track criteria** (ALL must be true for a given worktree):
- Work is purely mechanical: documentation changes, dead code removal, import cleanup, convention updates, small bug fixes with obvious solutions
- No architectural decisions or design choices required
- Scope is small enough for one agent to hold in context (roughly ≤3 files changed)

**Per-worktree evaluation:**
1. Classify each worktree as **fast-track eligible** or **standard**
2. If ANY worktrees are fast-track eligible, ask the user: "These items look like small cleanup work — use fast-track mode for them? [list items]. The remaining items will use standard two-phase mode."
3. If ALL worktrees are fast-track eligible, ask: "This looks like small cleanup work. Use fast-track mode (single agent plans + implements in one pass) or standard two-phase mode?"

**Fast-track flow** (for eligible worktrees only):
1. Spawn one agent per fast-track worktree with `mode: "bypassPermissions"`
2. Agent prompt includes all standard planner instructions PLUS implementation instructions
3. Agent writes a brief PLAN.md (for the record), implements it immediately, runs tests, and commits
4. Agent writes a postmortem and sends completion message
5. Lead reviews the commit diff (not a separate plan review step)

**Standard worktrees** proceed through Phase 2 (Planning) and Phase 3 (Implementation) as normal. Fast-track agents run in parallel with standard planners.

All worktrees converge at Phase 4 (Wrap-Up).

### Phase 2: Planning

Spawn one **planner** per feature in parallel. Critical rules:

- **Do NOT use `mode: "plan"`.** Plan mode prevents file writes, but planners need to write PLAN.md. Use `mode: "default"` instead.
- Each planner's prompt must include:
  - Their worktree path
  - The feature description from FEATURES.md
  - Instruction to read `CLAUDE.md` in their worktree
  - Instruction to **only research and write PLAN.md** — no implementation
  - Instruction that PLAN.md must start with a **Scope** indicator: `S` (small: single-file, no architectural decisions), `M` (medium: 2-5 files, some design choices), or `L` (large: 6+ files, architectural decisions, new subsystems). This helps the lead gauge complexity at a glance during plan review.
  - Instruction that PLAN.md must include a **Dead Code** section listing any existing functions that become unused as a result of the plan's changes (so they can be removed during implementation). For cleanup tasks, use a **Dead Code Summary** table with columns: function name, file, reason for removal.
  - Instruction that PLAN.md must include a **Test Cases** section specifying exact test scenarios (and optionally skeleton test code) for new functions and commands
  - Instruction that when defining new types/structs, the plan must note which ones are actually consumed by repo functions and commands vs. defined speculatively. Do not include unused types in the plan.
  - Instruction that when noting code duplication or refactoring targets, the plan must include exact counts and list the specific functions involved (e.g., "4 instances in `get_all_tracks`, `get_tracks_for_device`, `search_tracks`, `get_tracks_for_playlist`") — never approximate with "6-7 times"
  - Instruction to reference existing patterns by name for each new component (e.g., "model: follow `profile.rs`, store: follow `profilesStore`, commands: follow `profile` commands"). This is the most effective guidance for implementers.
  - Instruction that PLAN.md must include a **Known Risks / Blockers** section listing technical uncertainties, external dependencies, or potential issues (e.g., "CORS/Tauri asset protocol interaction untested", "requires new crate dependency"). Keep it short — if there are no risks, write "None identified." For S-scope plans, Dead Code and Known Risks can each be a single line ("None." / "None identified.").
  - Instruction that for uncertain fixes (where the first approach might not work), the plan must use a **"try A; if that doesn't work, fallback to B"** format instead of committing to a single approach. Example: "Try extracting to intermediate const; if that still triggers the warning, fallback to `// svelte-ignore`."
  - Instruction that plans should be **concise** — avoid extended deliberation or stream-of-consciousness exploration of multiple candidate approaches. Cap reasoning/exploration sections at ~20 lines. A short "try A, fallback B" is more useful than exploring 6+ candidates in prose.
  - Instruction that for plans involving **bulk replacements** (e.g., renaming a function across files, replacing hardcoded colors), the plan must include a **Verification** step: grep for remaining instances after the replacement pass to catch any that were missed.
  - Instruction that when documenting a new convention, if the planner discovers **existing code that violates it**, the plan must include a **Fix Existing Violations** section listing the specific files and values to fix — not just mention them as context.
  - Instruction that plans involving **TypeScript typed arrays or browser APIs** (Web Audio, Canvas, etc.) should note explicit generic types needed for strict TypeScript (e.g., `Uint8Array<ArrayBuffer>` not `Uint8Array<ArrayBufferLike>` for `getByteFrequencyData`).
  - Instruction that when a plan **adds a field to a data model** (e.g., a new column on `Track`), the plan must grep for ALL files that construct or map that model — not just the primary repo file. Include the grep command in the plan so the implementer can verify completeness (e.g., `grep -rn 'Track {' src-tauri/src/` or `grep -rn 'has_album_art.*bitrate' src-tauri/src/`).
  - Instruction that when a plan **adds interactive elements** (buttons, links, clickable spans) inside or adjacent to existing interactive elements, the plan must note potential **HTML nesting constraint** issues (e.g., `<button>` inside `<button>` is invalid HTML and triggers a11y warnings). Suggest the correct structure (e.g., sibling elements instead of nesting).
  - Instruction to write a postmortem before finishing (see Postmortem section below)
  - Instruction to send a message to the lead when PLAN.md is complete

**On receiving a planner's completion message:**
1. Read the PLAN.md from their worktree
2. If PLAN.md is missing, write it from the message content as a fallback
3. Review the plan against the codebase (spot-check key files mentioned)
4. Present the plan to the user for approval
5. **Shut down the planner immediately** — do not wait for them to idle

### Phase 3: Implementation

For each approved plan, spawn one **implementer**:

- Use `mode: "bypassPermissions"` so they can edit files and run commands freely
- Each implementer's prompt must include:
  - Their worktree path
  - Instruction to read `CLAUDE.md` and `PLAN.md` in their worktree
  - Instruction to follow the plan strictly
  - Instruction to run `cargo test` (from src-tauri/) and `npm run check` before committing
  - Instruction to mark the feature as `[implemented]` in `docs/FEATURES.md` (change `- [ ]` to `- [implemented]`) if it matches an entry. Do NOT mark as `[done]` — that happens after the user tests and merges.
  - Instruction to stage specific files by name when committing — **never use `git add -A` or `git add .`** as it can pick up cache/build artifacts
  - Instruction to commit with a clear message on the current branch
  - Instruction to write a postmortem before finishing (see Postmortem section below)
  - Instruction to send a message to the lead with a summary when done

**On receiving an implementer's completion message:**
1. Mark the task as completed
2. Shut down the implementer immediately

### Phase 4: Wrap-Up

1. Shut down all remaining teammates
2. Delete the team
3. Read all agent postmortems from the session directory
4. Write the **lead postmortem** (see below) — this is part of the wrap-up flow, not a separate manual step
5. Check `ACTIONS.md` for any items that were resolved by this session's work (including items the planners discovered were already done). Mark them `[x]`.
6. Present a final summary table to the user with branches, commits, and test results
6. Remind the user they can merge with `/merge-feature <branch>` which handles the merge, worktree cleanup, directory cleanup, and FEATURES.md update automatically

## Postmortem Structure

### Agent Postmortems (planners and implementers)

Each agent writes their postmortem to `postmortems/<timestamp>/<agent-name>.md` as their **last action before signaling completion**. Include this in every agent's spawn prompt:

```
Before you send your completion message, write a postmortem file to:
postmortems/<timestamp>/<your-name>.md

Include these sections:
- **Task**: What were you asked to do?
- **What Went Well**: What was smooth or effective?
- **What Went Wrong**: What was confusing, missing, or caused friction?
- **PLAN.md Quality** (implementers only): Was the plan clear and complete? What was missing or ambiguous?
- **Codebase Surprises**: Anything unexpected you discovered about the code?
- **Suggestions**: What would you change about the workflow, instructions, or plan format?
```

### Lead Postmortem

The team lead writes `postmortems/<timestamp>/lead.md` after all agents are shut down. Include:

- **Goal**: What was the session trying to accomplish?
- **Timeline**: Chronological summary of key events
- **Results**: Table of features, branches, commits, test results
- **What Went Well**: Effective coordination, fast phases, clean implementations
- **What Went Wrong**: Coordination issues, stuck agents, rework, timing problems
- **What Can Be Improved**: Actionable changes to this skill or the workflow
- **Agent Feedback Summary**: Key themes from agent postmortems (read them first)

## Lessons Learned (update this section over time)

- Never use `mode: "plan"` for planners — it prevents writing PLAN.md and causes approval loops
- Shut down planners immediately after their PLAN.md is confirmed on disk — don't let them idle
- Always verify PLAN.md exists on disk after a planner reports completion
- Implementers with `bypassPermissions` mode work smoothly and avoid permission prompt interruptions
- Git worktree isolation prevents all cross-agent conflicts
- Parallel planning is highly effective — plans complete nearly simultaneously
- High-quality plans lead to first-try implementations with passing tests
- Implementers should mark their feature as `[implemented]` in `docs/FEATURES.md` as part of their commit — `[done]` is set by the lead after user tests and merges
- `FEATURES.md` statuses: `[ ]` not started, `[designed]` plan exists, `[implemented]` code done awaiting test/merge, `[done]` tested and merged
- When selecting features to work on, skip anything that is not `[ ]` (not started)
- Pre-check cleanup ACTIONS.md items with grep before creating worktrees — in one session, 4 of 7 items were already resolved, wasting planner time
- Always use `AskUserQuestion` with multi-select for feature and action selection — never just list them in text. Interactive menus are faster and clearer for the user
- Feature selection must be organized by FEATURES.md section (one question per section) — the tool limits each question to 4 options, so cramming all features into one question silently drops features. Use one `AskUserQuestion` call with up to 4 section-questions, then a separate call for ACTIONS.md items
- Fast-track mode (single agent plan+implement) is effective for small cleanup/documentation tasks — saves time and avoids the overhead of separate planner and implementer agents for trivial work
- Plans involving uncertain fixes should always include fallback strategies — committing to a single approach wastes implementer time when it doesn't work
- Plans should be concise — extended deliberation sections (100+ lines exploring candidates) are less useful than a short "try A, fallback B" format
- When documenting a convention, the plan should also fix existing violations — planners who discover violations should include them as action items, not just context
- Plans should include a Scope indicator (S/M/L) so the lead can gauge complexity at a glance — S-scope plans can abbreviate Dead Code and Known Risks to a single line
- When adding model fields, plans must grep for ALL files that construct/map the model — the track ratings plan missed playlist_repo.rs and scanner/metadata.rs by only searching library_repo.rs
- Plans adding interactive elements near existing ones must flag HTML nesting constraints — nested buttons cause a11y warnings
- Fast-track evaluation should be per-worktree, not all-or-nothing — S-scope cleanup items bundled with larger features were unnecessarily slow in two-phase mode
