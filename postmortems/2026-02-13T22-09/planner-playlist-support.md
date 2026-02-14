# Postmortem: Planner - Playlist Support

## Task

Research the codebase and write a comprehensive PLAN.md for the "Playlist Support" feature: create, manage, and reorder playlists within the app, with export to M3U/PLS formats.

## What Went Well

- The codebase is very consistently structured. The patterns for adding a new feature are clear: model -> schema -> repo -> commands -> registration -> frontend types -> command wrappers -> store -> page -> router. Each layer has existing examples to follow.
- The existing `profilesStore` and `profile.rs` command file are excellent templates for the playlist CRUD pattern.
- The `TrackRow` component already accepts flexible props (`onPlay`, `onEdit`), making it straightforward to extend with an `onAddToPlaylist` action.
- The player store already has `playAlbum()` which sets a queue and plays — the playlist play feature is a natural extension.
- The Tauri dialog plugin is already a dependency, so export save dialogs are available out of the box.

## What Went Wrong

- The glob tool did not find files when using a relative path pattern with an explicit `path` parameter pointing to the worktree. Had to fall back to `ls` via Bash to discover file listings, then read files individually. Minor friction but added a round trip.

## Codebase Surprises

- Schema migrations are done inline in `execute_batch` with `CREATE TABLE IF NOT EXISTS` rather than using a migration framework. This is simple and works well since all DDL is idempotent, but it means new tables must be added inside the same batch block to maintain the pattern.
- The `AppError` enum serializes to a plain string for the frontend via a custom `Serialize` impl. This means error variants just need a descriptive `#[error("...")]` message and they'll automatically surface in the frontend.
- The `Track` struct has 18 fields, and every query that returns tracks must map all 18 columns positionally (no derive-based mapping like sqlx). This is repetitive but consistent across the codebase.
- All IDs for top-level entities (profiles, devices) are UUIDv4 strings, not autoincrement integers. Playlists should follow this convention.

## Suggestions

- The repetitive 18-column Track mapping could benefit from a helper function like `fn track_from_row(row: &Row) -> rusqlite::Result<Track>` to reduce duplication. This is a codebase improvement, not required for this feature.
- The planner instructions were clear and comprehensive. No changes needed.
