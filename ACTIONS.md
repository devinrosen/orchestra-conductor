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

- [x] **Pre-check ACTIONS.md cleanup items against codebase before spawning planners** — In the 2026-02-13T23-39 session, 4 of 7 cleanup items were already resolved, wasting planner research time. Before creating a cleanup worktree, run a quick automated grep pass against ACTIONS.md project items to mark stale ones as resolved. This could be a lead responsibility or a pre-flight step in the `/implement-features` skill.
  - Source: `postmortems/2026-02-13T23-39/planner-project-cleanup.md`
  - Source: `postmortems/2026-02-13T23-39/lead.md`
  - Category: `workflow`

- [x] **Allow combined plan+implement for small cleanup bundles** — For well-scoped mechanical tasks (dead code removal, import cleanup, documentation), the planning research is 90% of the implementation work. Consider a fast-track mode in `/implement-features` where a single agent plans and implements small cleanup bundles in one pass instead of requiring separate planner and implementer phases. Reinforced in 2026-02-14T00-17 session: all 3 agents independently noted the two-phase approach was overkill for 2 small fixes. Reinforced again in 2026-02-14T09-50 session: pure documentation tasks (3 CLAUDE.md convention bullets) completed in <5 min but still required 2 agents.
  - Source: `postmortems/2026-02-13T22-09/lead.md`
  - Source: `postmortems/2026-02-13T22-09/planner-project-cleanup.md`
  - Source: `postmortems/2026-02-14T00-17/planner-project-cleanup-2.md`
  - Source: `postmortems/2026-02-14T00-17/impl-project-cleanup-2.md`
  - Source: `postmortems/2026-02-14T00-17/lead.md`
  - Source: `postmortems/2026-02-14T09-50/lead.md`
  - Category: `workflow`

- [x] **Add "Known Risks / Blockers" section to plan template** — The playback visualization planner flagged CORS/Tauri asset protocol interaction as a real risk but had to embed it in prose. A dedicated plan section would make risks more visible to the lead and implementer during review.
  - Source: `postmortems/2026-02-14T06-51/planner-playback-visualization.md`
  - Source: `postmortems/2026-02-14T06-51/lead.md`
  - Category: `workflow`

- [x] **Require plans to include fallback strategies for uncertain fixes** — The project cleanup plan's `state_referenced_locally` fix didn't work (intermediate const approach). The implementer had to pivot to `// svelte-ignore`. Plans should use "try A; if that doesn't work, fallback to B" format for uncertain fixes instead of committing to a single approach.
  - Source: `postmortems/2026-02-14T06-51/impl-project-cleanup-3.md`
  - Source: `postmortems/2026-02-14T06-51/lead.md`
  - Category: `workflow`

- [x] **Plans should avoid extended deliberation sections** — The project cleanup plan had 110 lines of stream-of-consciousness exploration for `state_referenced_locally` fixes. Plans should be concise — a short "try A, fallback B" is more useful than exploring 6+ candidate approaches. Cap reasoning sections at ~20 lines.
  - Source: `postmortems/2026-02-14T06-51/impl-project-cleanup-3.md`
  - Source: `postmortems/2026-02-14T06-51/lead.md`
  - Category: `workflow`

- [x] **Add grep verification step to plans involving bulk replacements** — The UI skins plan had ~35 color replacements across 14 files. The implementer suggested adding a "verify" step: grep for remaining hardcoded colors after the replacement pass to catch any that were missed. Also useful for `color: white` → `var(--on-accent)` audits.
  - Source: `postmortems/2026-02-14T06-51/impl-ui-skins.md`
  - Source: `postmortems/2026-02-14T06-51/lead.md`
  - Category: `workflow`

- [x] **Consider adding a UI testing skill or agent** — Visual/interaction bugs (canvas overflow blocking player controls, button icon confusion) can only be caught through manual testing. Created `/ui-test` skill using Playwright against Vite dev server with Tauri IPC mocks (`page.addInitScript()`), screenshots all 6 pages with populated mock data, and uses Claude's vision to analyze for visual/layout bugs.
  - Source: `postmortems/2026-02-14T06-51/user-playback-visualization.md`
  - Source: `postmortems/2026-02-14-ui-test-playwright.md`
  - Category: `workflow`

- [x] **Note TypeScript strict typing for Web Audio API in plan instructions** — The playback visualization implementer hit a `Uint8Array<ArrayBufferLike>` vs `Uint8Array<ArrayBuffer>` typing issue with `getByteFrequencyData`/`getByteTimeDomainData`. Plans involving typed arrays or browser APIs should note explicit generic types needed for strict TypeScript.
  - Source: `postmortems/2026-02-14T06-51/impl-playback-visualization.md`
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

- [x] **Mark ACTIONS.md items done when completed as part of another task** — Actions A (COALESCE docs) and D (track_from_row) were completed in a prior session but never checked off in ACTIONS.md, causing the next planner to re-investigate them. Add a step in the `/implement-features` wrap-up phase or `/merge-feature` skill to check off any ACTIONS.md items that were resolved by the session's work.
  - Source: `postmortems/2026-02-13T23-13/lead.md`
  - Category: `workflow`

- [x] **Require plans to include fix actions for convention violations they discover** — When a planner documents a new convention and discovers existing code that violates it, the plan should include a separate action item to fix those violations, not just list them as context. In the 2026-02-14T09-50 session, the planner found DuplicateReport.svelte had ~10 hardcoded colors violating the CSS convention but listed them as context — the user had to manually request the fix. Update planner instructions in `/implement-features` to require a "Fix Existing Violations" section when documenting conventions.
  - Source: `postmortems/2026-02-14T09-50/impl-project-docs.md`
  - Source: `postmortems/2026-02-14T09-50/lead.md`
  - Category: `workflow`

- [x] **Add "Scope" indicator (S/M/L) to plan template** — For small features (single-file UI changes), the Dead Code and Known Risks sections feel redundant but are quick to fill. Adding a scope indicator (Small/Medium/Large) to PLAN.md would help the lead gauge complexity at a glance during plan review. Consider making Dead Code and Known Risks optional for S-scope plans.
  - Source: `postmortems/2026-02-14T13-19/planner-split-library.md`
  - Source: `postmortems/2026-02-14T13-19/lead.md`
  - Category: `workflow`

- [x] **Require plans to grep for all affected locations when adding model fields** — When a plan adds a field to a data model (e.g., `rating` to `Track`), it should grep for all files that construct or map that model, not just the primary repo file. The track ratings plan missed `playlist_repo.rs` (inline Track mapping) and `scanner/metadata.rs` (Track construction) because it only searched `library_repo.rs`. Include the grep command in the plan for implementer verification.
  - Source: `postmortems/2026-02-14T19-36/impl-track-ratings.md`
  - Source: `postmortems/2026-02-14T19-36/lead.md`
  - Category: `workflow`

- [x] **Require plans to flag HTML nesting constraints for interactive elements** — Plans that add interactive elements (buttons, links) inside existing interactive elements should explicitly flag potential nesting issues. The track ratings plan placed `<button>` stars inside a `.track-node` `<button>`, causing 3 a11y warnings. The implementer had to restructure the HTML.
  - Source: `postmortems/2026-02-14T19-36/impl-track-ratings.md`
  - Source: `postmortems/2026-02-14T19-36/lead.md`
  - Category: `workflow`

- [x] **Allow mixed fast-track and standard mode in the same session** — When a session has both S-scope cleanup items and larger features, the S-scope items could be fast-tracked (single agent) while the larger features use standard two-phase mode. Currently the skill evaluates ALL selected work together, so S-scope items bundled with larger features always get the slower two-phase treatment. Both a11y agents independently noted the overhead was unnecessary.
  - Source: `postmortems/2026-02-14T19-36/planner-a11y-warnings.md`
  - Source: `postmortems/2026-02-14T19-36/impl-a11y-warnings.md`
  - Source: `postmortems/2026-02-14T19-36/lead.md`
  - Category: `skill-update`

- [x] **Note in agent instructions that PLAN.md is gitignored** — PLAN.md is in `.gitignore`, so `git add PLAN.md` will fail silently or error. Agent spawn prompts or the `/implement-features` skill should mention that PLAN.md is for the agent's own reference only and won't be committed. This avoids a failed first commit attempt when agents try to include it.
  - Source: `postmortems/2026-02-14T21-16/fast-track-cleanup.md`
  - Source: `postmortems/2026-02-14T21-16/lead.md`
  - Category: `workflow`

## Project

_Changes to the app codebase in `main/`: code, docs, tests, features._

- [x] **Document `COALESCE(album_artist, artist, 'Unknown Artist')` as canonical artist grouping in `main/CLAUDE.md`** — This SQL expression is the canonical way artists are grouped throughout the codebase (device sync, library queries, UI). It appears in multiple places and any feature touching artist/album grouping needs to use it consistently. Add it to the conventions section of `main/CLAUDE.md`.
  - Source: `postmortems/2026-02-13-sync-by-album/planner-sync-by-album.md`
  - Source: `postmortems/2026-02-13-sync-by-album/lead.md`
  - Source: `postmortems/2026-02-13-full-session.md`
  - Category: `documentation`

- [x] **Remove dead code: `get_tracks_by_artists` function** — The `get_tracks_by_artists` function in the device repo was replaced by `get_tracks_for_device` (which handles both artist and album selections). The old function is now unused and triggers a compiler warning. Remove it. _(Verified already removed from codebase — 2026-02-13T23-39 session)_
  - Source: `postmortems/2026-02-13-sync-by-album/impl-sync-by-album.md`
  - Source: `postmortems/2026-02-13-sync-by-album/lead.md`
  - Category: `dead-code`

- [x] **Remove dead code: `get_tracks_by_albums` function** — The `get_tracks_by_albums` function in `library_repo.rs` is unused and triggers a compiler warning. Remove it. _(Verified already removed from codebase — 2026-02-13T23-39 session)_
  - Source: `postmortems/2026-02-13T21-39/lead.md`
  - Category: `dead-code`

- [x] **Extract `track_from_row()` helper in `library_repo.rs`** — The Track row mapping (`row.get(0)?, row.get(1)?, ...`) is duplicated 6-7 times across query functions. A `track_from_row(row: &Row) -> Result<Track>` helper would centralize this and make adding columns (like `bitrate`) much easier. High priority — flagged by 4 of 5 postmortems.
  - Source: `postmortems/2026-02-13T21-39/lead.md`
  - Source: `postmortems/2026-02-13T21-39/planner-library-stats.md`
  - Source: `postmortems/2026-02-13T21-39/impl-library-stats.md`
  - Source: `postmortems/2026-02-13T21-39/impl-shared-track-row.md`
  - Category: `refactor`

- [x] **Use shared `formatDuration` in AlbumEditor.svelte** — `AlbumEditor.svelte` has its own copy of `formatDuration` that could now import from `src/lib/utils/format.ts` (created during the shared track row feature). _(Verified already resolved — AlbumEditor imports from shared format.ts. Statistics.svelte copy is intentionally different — 2026-02-13T23-39 session)_
  - Source: `postmortems/2026-02-13T21-39/lead.md`
  - Source: `postmortems/2026-02-13T21-39/impl-shared-track-row.md`
  - Category: `dead-code`

- [x] **Remove unused `AlbumNode` import in TreeView.svelte** — `AlbumNode` is imported but unused in TreeView.svelte. Pre-existing issue, not introduced by the refactor. _(Verified already resolved — TreeView imports only ArtistNode and Track — 2026-02-13T23-39 session)_
  - Source: `postmortems/2026-02-13T21-39/impl-shared-track-row.md`
  - Category: `dead-code`

- [x] **Extract shared album header component** — The album header pattern (expand/collapse toggle + play album button + edit album button) is duplicated across TreeView, AlbumListView, and GenreTreeView with minor variations. Consider extracting into a shared component in a future feature.
  - Source: `postmortems/2026-02-13T21-39/planner-shared-track-row.md`
  - Category: `feature`

- [x] **Remove dead code: `ScanCancelled` and `DiskFull` error variants and `is_cancelled` method** — These unused error variants in `AppError` and the `is_cancelled` method trigger compiler warnings. Pre-existing dead code unrelated to recent features. _(Implemented in feat/project-cleanup branch — 2026-02-13T23-39 session)_
  - Source: `postmortems/2026-02-13T22-09/lead.md`
  - Source: `postmortems/2026-02-13T22-09/impl-project-cleanup.md`
  - Category: `dead-code`

- [x] **Update test count in `main/CLAUDE.md` to 28** — Resolved by removing the hard-coded test count and specific file names from `main/CLAUDE.md`, since counts drift with every feature.
  - Source: `postmortems/2026-02-13T22-09/lead.md`
  - Source: `postmortems/2026-02-13T22-09/impl-project-cleanup.md`
  - Category: `documentation`

- [x] **Remove unused tree CSS from `AlbumListView.svelte`** — After the AlbumHeader extraction, `.tree-toggle`, `.chevron`, `.chevron.expanded`, `.count` CSS rules are unused in AlbumListView (it has no non-album toggles), producing 5 Svelte unused-selector warnings. Remove them. _(Implemented in feat/project-cleanup branch — 2026-02-13T23-39 session)_
  - Source: `postmortems/2026-02-13T23-13/impl-project-cleanup.md`
  - Source: `postmortems/2026-02-13T23-13/lead.md`
  - Category: `dead-code`

- [x] **Extract shared tree CSS into a shared stylesheet or component** — The tree CSS (`.tree-toggle`, `.tree-toggle:hover`, `.chevron`, `.chevron.expanded`, `.count`, `.children`) is duplicated across TreeView, GenreTreeView, and FolderTreeView (3 components). Consider extracting into a global stylesheet or a base tree CSS file. _(Implemented in feat/project-cleanup-3 branch — 2026-02-14T06-51 session. Moved 6 selectors to global app.css, removed from 5 component files.)_
  - Source: `postmortems/2026-02-13T23-13/planner-project-cleanup.md`
  - Source: `postmortems/2026-02-13T23-13/impl-project-cleanup.md`
  - Source: `postmortems/2026-02-13T23-39/planner-project-cleanup.md`
  - Category: `refactor`

- [x] **Remove unused `PlaylistTrack` struct in `models/playlist.rs`** — The `PlaylistTrack` struct (line 12) is never constructed anywhere in the codebase. It produces a `dead_code` compiler warning. The playlist repo works with `track_id`s directly via the `playlist_tracks` join table. Remove the struct.
  - Source: `postmortems/2026-02-13T23-39/impl-project-cleanup.md`
  - Source: `postmortems/2026-02-13T23-39/lead.md`
  - Category: `dead-code`

- [x] **Address pre-existing svelte-check warnings (25 warnings across 9 files)** — `npm run check` produces 25 warnings: mostly `state_referenced_locally` in MetadataEditor.svelte (8), AlbumEditor.svelte (5), ArtistPicker.svelte (2), plus `a11y_interactive_supports_focus` in DeviceSync, MetadataEditor, AlbumEditor, MetadataReport, and `a11y_label_has_associated_control` in SyncProfiles, Settings. _(Implemented in feat/project-cleanup-3 branch — 2026-02-14T06-51 session. All 25 warnings resolved: 0 errors, 0 warnings.)_
  - Source: `postmortems/2026-02-14T00-17/impl-project-cleanup-2.md`
  - Category: `code-quality`

- [x] **Fix Playlists.svelte `playTrack` queue slicing bug** — When playing a track from the Playlists page, `playTrack` calls `playerStore.playPlaylist(tracks.slice(index))` which sets the queue to only tracks from the clicked track onward, discarding earlier tracks. It should call `playerStore.playTrack(track, tracks)` or equivalent to set the full playlist as the queue with `queueIndex` pointing to the clicked track. Now visible to users via the play queue viewer panel.
  - Source: `postmortems/2026-02-13T23-39/planner-play-queue-viewer.md`
  - Source: `postmortems/2026-02-13T23-39/lead.md`
  - Category: `bug`

- [x] **Document `// svelte-ignore state_referenced_locally` as standard pattern** — The correct Svelte 5 approach for "copy prop to local editable state" is to use `// svelte-ignore state_referenced_locally` in `<script>` blocks. The intermediate-const approach doesn't work. Document this in `main/CLAUDE.md` or `.claude/memory/MEMORY.md` as a project convention.
  - Source: `postmortems/2026-02-14T06-51/planner-project-cleanup-3.md`
  - Source: `postmortems/2026-02-14T06-51/impl-project-cleanup-3.md`
  - Source: `postmortems/2026-02-14T06-51/lead.md`
  - Category: `documentation`

- [x] **Add CSS lint convention to prevent hardcoded colors** — After the UI skins implementation, all colors should go through CSS custom properties. Consider adding a comment convention or lint rule to flag new hardcoded `rgba()` / hex values in `.svelte` style blocks, preventing the same ~35-replacement cleanup from being needed again.
  - Source: `postmortems/2026-02-14T06-51/planner-ui-skins.md`
  - Category: `code-quality`

- [x] **Establish project convention on file deletion (permanent vs trash)** — The duplicate detection feature uses `std::fs::remove_file` for permanent deletion. A "move to trash" option would be safer but requires a new dependency (`trash` crate). Decide on a project-wide convention for features involving file removal.
  - Source: `postmortems/2026-02-14T06-51/planner-duplicate-detection.md`
  - Category: `convention`

- [x] **Add selective page filtering to `/ui-test` Playwright test** — The skill advertises `/ui-test library` for testing specific pages, but the Playwright test (`main/e2e/ui-screenshots.spec.ts`) always screenshots all 6 pages. Add support for a `PAGES` environment variable or test parameter so the skill can run `PAGES=library,settings npx playwright test` to test only requested pages.
  - Source: `postmortems/2026-02-14-ui-test-playwright.md`
  - Category: `skill-update`

- [x] **Document: update `main/e2e/tauri-mocks.ts` when adding new IPC commands** — The Tauri IPC mock must be updated whenever a new `invoke()` command is added to the app, otherwise the corresponding page will show error/empty state during UI tests. The mock already logs `console.warn("[tauri-mock] unhandled command:")` for unhandled calls. Add a reminder to `main/CLAUDE.md` conventions or the IPC pattern section.
  - Source: `postmortems/2026-02-14-ui-test-playwright.md`
  - Category: `documentation`

- [x] **Fix 2 pre-existing `npm run check` a11y warnings** — `Settings.svelte:44` has `a11y_label_has_associated_control` (form label not associated with a control) and `DuplicateReport.svelte:135` has `a11y_interactive_supports_focus` (dialog role element missing tabindex). Both are pre-existing and unrelated to recent features. Fix them to get `npm run check` to 0 warnings.
  - Source: `postmortems/2026-02-14T13-19/lead.md`
  - Source: `postmortems/2026-02-14T13-19/impl-split-library.md`
  - Source: `postmortems/2026-02-14T13-19/impl-equalizer.md`
  - Category: `code-quality`

- [x] **Refactor `playlist_repo.rs` to reuse `track_from_row` from `library_repo.rs`** — `playlist_repo.rs` has its own inline Track row mapping instead of reusing the `pub(crate) track_from_row` function from `library_repo.rs`. Every Track field addition now requires updating both files independently. The `favorite_repo.rs` already uses the shared version. Updating `playlist_repo.rs` would complete the consolidation.
  - Source: `postmortems/2026-02-14T19-36/impl-track-ratings.md`
  - Source: `postmortems/2026-02-14T19-36/lead.md`
  - Source: `postmortems/2026-02-14T20-13/planner-favorites.md`
  - Source: `postmortems/2026-02-14T20-13/lead.md`
  - Category: `refactor`

- [x] **Document `track_from_row` positional column convention in `main/CLAUDE.md`** — `track_from_row` uses positional indices (0-18) for column mapping. Adding a column requires updating the index in the function AND ensuring all SELECT statements list columns in exactly the same order. This is a common source of bugs when extending the Track model. Document this pattern in the conventions section.
  - Source: `postmortems/2026-02-14T19-36/planner-track-ratings.md`
  - Category: `documentation`

- [x] **Add "Patterns to Follow" section to `main/CLAUDE.md`** — Document the `model → repo → command → store → page` pipeline as the standard extension pattern for new features. The planner noted this is the main pattern agents follow, and having it explicitly documented would save research time for future planners.
  - Source: `postmortems/2026-02-14T20-13/planner-favorites.md`
  - Source: `postmortems/2026-02-14T20-13/lead.md`
  - Category: `documentation`

- [ ] **Instruct implementation agents to commit incrementally after each logical unit** — The multi-library backend agent wrote all code but hit a rate limit before running `cargo test` or `git commit`, requiring manual lead intervention for those steps. Agent spawn prompts should instruct agents to run tests and commit after each logical unit of work (e.g., after backend code, after frontend code) rather than batching all commits at the end. This prevents loss of work when rate limits or context exhaustion occur mid-session.
  - Source: `postmortems/2026-02-15T08-02/session.md`
  - Source: `postmortems/2026-02-16T08-13/session.md`
  - Category: `workflow`

- [x] **Make commit/push a lead responsibility instead of relying on agents** — In the 2026-02-16T08-13 session, 2 of 3 implementation agents couldn't run `git commit` or `push-branch.sh` due to sandbox permissions, requiring manual lead intervention. Rather than trying to fix agent sandbox permissions, update the `/implement-features` skill to make commit and push explicit lead steps after each agent completes implementation. Remove commit/push instructions from agent spawn prompts.
  - Source: `postmortems/2026-02-16T08-13/session.md`
  - Category: `workflow`

- [x] **Document `libraryStore.libraryRoot` nullability in `main/CLAUDE.md`** — `libraryStore.libraryRoot` can be `null`/`undefined` even when `libraryStore.tree` is populated. The import music frontend agent had to add a conditional guard for this. Document in `main/CLAUDE.md` conventions to prevent future agents from assuming `libraryRoot` is always set when the library is loaded.
  - Source: `postmortems/2026-02-15T21-57/session.md`
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
- `postmortems/2026-02-13T23-13/lead.md`
- `postmortems/2026-02-13T23-13/planner-project-cleanup.md`
- `postmortems/2026-02-13T23-13/impl-project-cleanup.md`
- `postmortems/2026-02-13T23-39/planner-contextual-search.md`
- `postmortems/2026-02-13T23-39/planner-play-queue-viewer.md`
- `postmortems/2026-02-13T23-39/planner-project-cleanup.md`
- `postmortems/2026-02-13T23-39/impl-contextual-search.md`
- `postmortems/2026-02-13T23-39/impl-play-queue-viewer.md`
- `postmortems/2026-02-13T23-39/impl-project-cleanup.md`
- `postmortems/2026-02-13T23-39/lead.md`
- `postmortems/2026-02-14T00-17/planner-project-cleanup-2.md`
- `postmortems/2026-02-14T00-17/impl-project-cleanup-2.md`
- `postmortems/2026-02-14T00-17/lead.md`
- `postmortems/2026-02-14T06-51/planner-duplicate-detection.md`
- `postmortems/2026-02-14T06-51/planner-ui-skins.md`
- `postmortems/2026-02-14T06-51/planner-playback-visualization.md`
- `postmortems/2026-02-14T06-51/planner-project-cleanup-3.md`
- `postmortems/2026-02-14T06-51/impl-duplicate-detection.md`
- `postmortems/2026-02-14T06-51/impl-ui-skins.md`
- `postmortems/2026-02-14T06-51/impl-playback-visualization.md`
- `postmortems/2026-02-14T06-51/impl-project-cleanup-3.md`
- `postmortems/2026-02-14T06-51/lead.md`
- `postmortems/2026-02-14T06-51/user-playback-visualization.md`
- `postmortems/2026-02-14T09-50/planner-project-docs.md`
- `postmortems/2026-02-14T09-50/impl-project-docs.md`
- `postmortems/2026-02-14T09-50/lead.md`
- `postmortems/2026-02-14-ui-test-playwright.md`
- `postmortems/2026-02-14T13-19/planner-split-library.md`
- `postmortems/2026-02-14T13-19/planner-equalizer.md`
- `postmortems/2026-02-14T13-19/impl-split-library.md`
- `postmortems/2026-02-14T13-19/impl-equalizer.md`
- `postmortems/2026-02-14T13-19/lead.md`
- `postmortems/2026-02-14T19-36/planner-a11y-warnings.md`
- `postmortems/2026-02-14T19-36/planner-track-ratings.md`
- `postmortems/2026-02-14T19-36/impl-a11y-warnings.md`
- `postmortems/2026-02-14T19-36/impl-track-ratings.md`
- `postmortems/2026-02-14T19-36/lead.md`
- `postmortems/2026-02-14T20-13/planner-favorites.md`
- `postmortems/2026-02-14T20-13/impl-favorites.md`
- `postmortems/2026-02-14T20-13/lead.md`
- `postmortems/2026-02-14T20-13/user-favorites.md`
- `postmortems/2026-02-14T21-16/fast-track-cleanup.md`
- `postmortems/2026-02-14T21-16/lead.md`
- `postmortems/2026-02-15T08-02/session.md`
- `postmortems/2026-02-15T21-57/session.md`
- `postmortems/2026-02-16T07-45/session.md`
- `postmortems/2026-02-16T08-13/session.md`
