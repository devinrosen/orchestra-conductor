# Postmortem: Planner -- Project Cleanup Bundle A/D/G

## Task

Plan cleanup actions A (document COALESCE convention), D (extract track_from_row helper), and G (extract shared AlbumHeader component). Research the codebase, verify duplication, and write PLAN.md.

## What Went Well

- Actions A and D were already completed in prior work. The planner correctly identified this and marked them as SKIP rather than producing unnecessary plans.
- The album header duplication analysis was precise: 3 components, exact line ranges, specific CSS rules, and clear enumeration of differences (artist name visibility, font-weight variation).
- The AlbumHeader component design uses simple scalar props rather than requiring a specific album type, making it work with both `AlbumNode` (no artist field) and `AlbumEntry` (has artist field).
- Following the TrackRow.svelte pattern for component design kept the plan consistent with existing codebase conventions.

## What Went Wrong

- Nothing significant. The plan was straightforward once the codebase was read.

## Codebase Surprises

- Actions A and D were already done. The COALESCE convention was documented in CLAUDE.md line 71, and `track_from_row` was already extracted at library_repo.rs:9-31. The actions backlog may not be getting updated when work is completed.
- The `AlbumNode` type (used in TreeView) lacks an `artist` field -- the artist context comes from the parent `ArtistNode`. This means the shared component cannot accept a single album object; it needs individual props.
- AlbumListView uses `font-weight: 600` for album names while TreeView and GenreTreeView use `500`. This is likely an intentional visual distinction (albums are the top-level grouping in AlbumListView, so they're bolder) but it's a subtle inconsistency to preserve.
- The tree CSS (`.tree-toggle`, `.chevron`, etc.) is duplicated across all 4 tree views (including FolderTreeView), not just the 3 with album headers. A future cleanup could extract shared tree styles, but that's a bigger scope change.

## Suggestions

- Mark actions A and D as completed in ACTIONS.md to prevent future planners from re-investigating them.
- Consider a future action to extract shared tree CSS (`.tree-toggle`, `.chevron`, `.count`, `.children`) into a global stylesheet or shared CSS file, since it's duplicated across 4 components.
