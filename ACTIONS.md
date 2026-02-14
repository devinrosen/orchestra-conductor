# Actions

Actionable items extracted from session postmortems by the `review-postmortems` agent.

## Orchestration

_Changes to the orchestration workspace: workflows, skills, agents, team process._

- [x] **Spawn planners in `mode: "default"`, not `mode: "plan"`** — Plan mode prevents file writes, but planners need to write PLAN.md. Spawn planners in default mode and instruct them to only research and write PLAN.md (not implement). Update the `/implement-features` skill and `CLAUDE.md` workflow instructions accordingly.
  - Source: `postmortems/2026-02-13-feature-planning-team.md`
  - Source: `postmortems/2026-02-13-full-session.md`
  - Category: `workflow`

- [x] **Write PLAN.md from plan approval content as fallback** — When a planner submits via `ExitPlanMode` but cannot write PLAN.md to disk (e.g., stuck in plan mode), the lead should extract the plan content from the approval request and write PLAN.md immediately. Add this as an explicit fallback step in the `/implement-features` skill.
  - Source: `postmortems/2026-02-13-feature-planning-team.md`
  - Category: `skill-update`

- [x] **Shut down planners immediately after plan approval** — Don't wait for planners to realize they can't implement. Send the shutdown request in the same turn as the plan approval to avoid noise from approval loops. Document this in the `/implement-features` skill.
  - Source: `postmortems/2026-02-13-feature-planning-team.md`
  - Category: `skill-update`

- [x] **Require plans to flag dead code** — When a plan introduces a new function that replaces an existing one, the plan should explicitly note that the old function becomes dead code and should be removed during implementation. Update the PLAN.md template or planner instructions to include a "Dead Code" section.
  - Source: `postmortems/2026-02-13-sync-by-album/impl-sync-by-album.md`
  - Source: `postmortems/2026-02-13-sync-by-album/lead.md`
  - Source: `postmortems/2026-02-13-full-session.md`
  - Category: `workflow`

- [x] **Require plans to include test case stubs** — Plans should specify exact test scenarios (and optionally skeleton test code) for new query functions and commands, making implementation more turnkey and ensuring test coverage is not an afterthought.
  - Source: `postmortems/2026-02-13-sync-by-album/impl-sync-by-album.md`
  - Source: `postmortems/2026-02-13-sync-by-album/lead.md`
  - Source: `postmortems/2026-02-13-full-session.md`
  - Category: `workflow`

- [x] **Avoid `git add -A` in skills and agent instructions** — `git add -A` picked up untracked Vite cache files during cleanup. Update the `/implement-features` skill and any agent spawn prompts to prefer staging specific files by name instead.
  - Source: `postmortems/2026-02-13-full-session.md`
  - Category: `workflow`

- [x] **Add lead postmortem to the merge flow in `/implement-features` skill** — The lead postmortem is currently a separate manual step. Integrate it into the skill's Phase 4 (wrap-up) so it happens automatically as part of the merge flow.
  - Source: `postmortems/2026-02-13-full-session.md`
  - Category: `skill-update`

- [x] **Add `npm install` to worktree setup or implementer instructions** — Fresh worktrees don't have `node_modules`, and implementers consistently need it for `npm run check`. Add it as an explicit step in the `/implement-features` skill's worktree creation or implementer spawn prompt.
  - Source: `postmortems/2026-02-13T21-39/lead.md`
  - Source: `postmortems/2026-02-13T21-39/impl-library-stats.md`
  - Source: `postmortems/2026-02-13T21-39/impl-shared-track-row.md`
  - Category: `workflow`

- [x] **Clean up or ignore stale PLAN.md in worktrees** — New worktrees inherit PLAN.md from the base branch, causing confusion when planners overwrite a previous feature's plan. Either remove PLAN.md from main after merging, add it to `.gitignore`, or document this as expected behavior.
  - Source: `postmortems/2026-02-13T21-39/lead.md`
  - Source: `postmortems/2026-02-13T21-39/planner-library-stats.md`
  - Source: `postmortems/2026-02-13T21-39/planner-shared-track-row.md`
  - Source: `postmortems/2026-02-13T21-39/impl-library-stats.md`
  - Category: `workflow`

- [ ] **Allow combined plan+implement for small cleanup bundles** — For well-scoped mechanical tasks (dead code removal, import cleanup), the planning research is 90% of the implementation work. Consider a fast-track mode in `/implement-features` where a single agent plans and implements small cleanup bundles in one pass instead of requiring separate planner and implementer phases.
  - Source: `postmortems/2026-02-13T22-09/lead.md`
  - Source: `postmortems/2026-02-13T22-09/planner-project-cleanup.md`
  - Category: `workflow`

- [x] **Require plans to note which defined types are actually consumed** — The playlist plan included a `PlaylistTrack` struct that went unused by the implementation (repo works with `track_id`s directly). Plans should explicitly note which defined types are consumed by repo/command functions vs. defined speculatively.
  - Source: `postmortems/2026-02-13T22-09/lead.md`
  - Category: `workflow`

- [x] **Include "Dead Code Summary" table in cleanup plan template** — The cleanup planner's dead code summary table format was praised as effective for quick reference. Add this as a recommended pattern in planner instructions for cleanup tasks.
  - Source: `postmortems/2026-02-13T22-09/impl-project-cleanup.md`
  - Category: `workflow`

- [x] **Use precise duplication counts in action descriptions** — The action for `track_from_row` said "6-7 times" which led to uncertainty requiring manual verification (actual count was 6, with 2 in dead functions). Action descriptions should include exact counts and specific function names.
  - Source: `postmortems/2026-02-13T22-09/planner-project-cleanup.md`
  - Category: `workflow`

- [x] **Instruct planners to reference existing patterns by name** — The playlist implementer found "follow the profilesStore pattern" highly effective as a convention guide. Planner instructions should require naming the specific existing file/module to follow for each new component (e.g., "model: follow `profile.rs`, store: follow `profilesStore`").
  - Source: `postmortems/2026-02-13T22-09/impl-playlist-support.md`
  - Category: `workflow`

- [x] **Update test count in CLAUDE.md during merge flow** — Resolved by removing the hard-coded test count from `main/CLAUDE.md` entirely, eliminating the maintenance burden. No merge-flow step needed.
  - Source: `postmortems/2026-02-13T22-09/lead.md`
  - Source: `postmortems/2026-02-13T22-09/impl-project-cleanup.md`
  - Category: `skill-update`

## Project

_Changes to the app codebase in `main/`: code, docs, tests, features._

- [x] **Document `COALESCE(album_artist, artist, 'Unknown Artist')` as canonical artist grouping in `main/CLAUDE.md`** — This SQL expression is the canonical way artists are grouped throughout the codebase (device sync, library queries, UI). It appears in multiple places and any feature touching artist/album grouping needs to use it consistently. Add it to the conventions section of `main/CLAUDE.md`.
  - Source: `postmortems/2026-02-13-sync-by-album/planner-sync-by-album.md`
  - Source: `postmortems/2026-02-13-sync-by-album/lead.md`
  - Source: `postmortems/2026-02-13-full-session.md`
  - Category: `documentation`

- [ ] **Remove dead code: `get_tracks_by_artists` function** — The `get_tracks_by_artists` function in the device repo was replaced by `get_tracks_for_device` (which handles both artist and album selections). The old function is now unused and triggers a compiler warning. Remove it.
  - Source: `postmortems/2026-02-13-sync-by-album/impl-sync-by-album.md`
  - Source: `postmortems/2026-02-13-sync-by-album/lead.md`
  - Category: `dead-code`

- [ ] **Remove dead code: `get_tracks_by_albums` function** — The `get_tracks_by_albums` function in `library_repo.rs` is unused and triggers a compiler warning. Remove it.
  - Source: `postmortems/2026-02-13T21-39/lead.md`
  - Category: `dead-code`

- [x] **Extract `track_from_row()` helper in `library_repo.rs`** — The Track row mapping (`row.get(0)?, row.get(1)?, ...`) is duplicated 6-7 times across query functions. A `track_from_row(row: &Row) -> Result<Track>` helper would centralize this and make adding columns (like `bitrate`) much easier. High priority — flagged by 4 of 5 postmortems.
  - Source: `postmortems/2026-02-13T21-39/lead.md`
  - Source: `postmortems/2026-02-13T21-39/planner-library-stats.md`
  - Source: `postmortems/2026-02-13T21-39/impl-library-stats.md`
  - Source: `postmortems/2026-02-13T21-39/impl-shared-track-row.md`
  - Category: `refactor`

- [ ] **Use shared `formatDuration` in AlbumEditor.svelte** — `AlbumEditor.svelte` has its own copy of `formatDuration` that could now import from `src/lib/utils/format.ts` (created during the shared track row feature).
  - Source: `postmortems/2026-02-13T21-39/lead.md`
  - Source: `postmortems/2026-02-13T21-39/impl-shared-track-row.md`
  - Category: `dead-code`

- [ ] **Remove unused `AlbumNode` import in TreeView.svelte** — `AlbumNode` is imported but unused in TreeView.svelte. Pre-existing issue, not introduced by the refactor.
  - Source: `postmortems/2026-02-13T21-39/impl-shared-track-row.md`
  - Category: `dead-code`

- [x] **Extract shared album header component** — The album header pattern (expand/collapse toggle + play album button + edit album button) is duplicated across TreeView, AlbumListView, and GenreTreeView with minor variations. Consider extracting into a shared component in a future feature.
  - Source: `postmortems/2026-02-13T21-39/planner-shared-track-row.md`
  - Category: `feature`

- [ ] **Remove dead code: `ScanCancelled` and `DiskFull` error variants and `is_cancelled` method** — These unused error variants in `AppError` and the `is_cancelled` method trigger compiler warnings. Pre-existing dead code unrelated to recent features.
  - Source: `postmortems/2026-02-13T22-09/lead.md`
  - Source: `postmortems/2026-02-13T22-09/impl-project-cleanup.md`
  - Category: `dead-code`

- [x] **Update test count in `main/CLAUDE.md` to 28** — Resolved by removing the hard-coded test count and specific file names from `main/CLAUDE.md`, since counts drift with every feature.
  - Source: `postmortems/2026-02-13T22-09/lead.md`
  - Source: `postmortems/2026-02-13T22-09/impl-project-cleanup.md`
  - Category: `documentation`

## Processed Postmortems

_Postmortem files that have already been reviewed. Do not reprocess these._

- `postmortems/2026-02-13-feature-planning-team.md`
- `postmortems/2026-02-13-sync-by-album/planner-sync-by-album.md`
- `postmortems/2026-02-13-sync-by-album/impl-sync-by-album.md`
- `postmortems/2026-02-13-sync-by-album/lead.md`
- `postmortems/2026-02-13-full-session.md`
- `postmortems/2026-02-13T21-39/lead.md`
- `postmortems/2026-02-13T21-39/planner-library-stats.md`
- `postmortems/2026-02-13T21-39/planner-shared-track-row.md`
- `postmortems/2026-02-13T21-39/impl-library-stats.md`
- `postmortems/2026-02-13T21-39/impl-shared-track-row.md`
- `postmortems/2026-02-13T22-09/lead.md`
- `postmortems/2026-02-13T22-09/planner-project-cleanup.md`
- `postmortems/2026-02-13T22-09/planner-playlist-support.md`
- `postmortems/2026-02-13T22-09/impl-project-cleanup.md`
- `postmortems/2026-02-13T22-09/impl-playlist-support.md`
