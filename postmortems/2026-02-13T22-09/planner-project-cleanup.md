# Postmortem: Planner -- Project Cleanup (Actions A-F)

**Date**: 2026-02-13
**Role**: Planner
**Worktree**: `fix-project-cleanup/`

## Task

Plan 6 project cleanup actions: document COALESCE convention, remove 2 dead functions (`get_tracks_by_artists`, `get_tracks_by_albums`), extract `track_from_row()` helper, replace local `formatDuration` with shared import, and remove unused `AlbumNode` import.

## What Went Well

- The actions were clearly scoped and well-described in the task assignment. Each one mapped cleanly to specific file locations.
- The codebase is well-organized -- `library_repo.rs` for all Track queries, `format.ts` for shared formatters, types mirrored between Rust and TypeScript.
- Confirming dead code was straightforward: grep for function names across the entire `src-tauri/src` directory showed zero callers outside the definition site.
- The `track_from_row` refactor is safe because `query_map` expects exactly `FnMut(&Row) -> rusqlite::Result<T>`, which matches the proposed helper signature.

## What Went Wrong

- Nothing significant. The task was well-suited for a planning pass.

## Codebase Surprises

- `Statistics.svelte` has its own `formatDuration` that differs from the shared utility (hours+minutes format vs mm:ss). The action description didn't mention this, but it's important context to avoid accidentally replacing the wrong one.
- The Track row-mapping duplication was exactly 6 instances (not "6-7" as stated in the task), and 2 of them are in the dead functions being removed, leaving 4 to refactor.
- The `AlbumNode` type IS used structurally in TreeView (via `ArtistNode.albums`) but the explicit import is indeed unused -- TypeScript structural typing means no explicit import is needed.

## Suggestions

- When describing refactoring tasks, include the exact count of duplications and which functions contain them. "6-7 times" led to uncertainty that required manual verification.
- The planning phase for a well-scoped cleanup like this could be combined with implementation -- the research needed to plan is 90% of the work, and the changes themselves are mechanical.
