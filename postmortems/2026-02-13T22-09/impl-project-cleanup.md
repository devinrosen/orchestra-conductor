# Postmortem: Project Cleanup (Actions A-F)

## Task

Implement 6 cleanup actions from the ACTIONS.md backlog:
- A: Document COALESCE artist-grouping SQL convention in CLAUDE.md
- B: Remove dead `get_tracks_by_artists` function
- C: Remove dead `get_tracks_by_albums` function
- D: Extract `track_from_row()` helper to eliminate duplicated Track row-mapping
- E: Replace local `formatDuration` in AlbumEditor.svelte with shared import
- F: Remove unused `AlbumNode` import in TreeView.svelte

## What Went Well

- The plan was extremely well-structured with clear, ordered implementation steps. Each action had exact file paths, line numbers, and before/after code examples.
- All 20 tests passed on first try after changes -- no regressions.
- `npm run check` returned 0 errors (25 pre-existing warnings unchanged).
- Net result: -193 lines (32 insertions, 225 deletions) across 4 files.
- The plan correctly noted that `AlbumSelection` import should remain after removing B and C -- this kind of explicit call-out prevents accidental over-deletion.

## What Went Wrong

- Nothing significant went wrong. This was a clean, mechanical cleanup with no surprises.

## PLAN.md Quality

Excellent. The plan was:
- **Clear**: Each action had its own section with exact file paths, line numbers, and code snippets.
- **Complete**: The implementation steps were ordered correctly (remove dead code first, then extract helper, then frontend, then docs).
- **Careful**: Important caveats were explicitly called out (e.g., keep `AlbumSelection` import, don't replace `Statistics.svelte`'s different `formatDuration`).
- **Testable**: The test plan section was thorough and accurate -- all 20 tests passed as predicted.

No ambiguities or missing information.

## Codebase Surprises

- The test count was 20, not 13 as mentioned in CLAUDE.md (`cargo test` comment says "13 tests"). The additional 7 are the `stats_tests` in `library_repo.rs`. Minor documentation drift.
- There are 2 pre-existing dead code warnings (`ScanCancelled`, `DiskFull` error variants and `is_cancelled` method) that are unrelated to this cleanup.

## Suggestions

- The plan format with a "Dead Code Summary" table was very helpful for quick reference. Recommend keeping this pattern for future cleanup plans.
- Consider adding the pre-existing compiler warnings to ACTIONS.md as future cleanup items.
- The CLAUDE.md test count should be updated to reflect the actual 20 tests.
