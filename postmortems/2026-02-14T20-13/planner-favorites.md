# Postmortem: Planner — Favorites Feature

## Task

Research the codebase and write a PLAN.md for the Favorites feature: heart-toggle to favorite artists, albums, and tracks with a dedicated Favorites page and library filter toggle.

## What Went Well

- The codebase is very well-organized with clear, repeatable patterns. The playlist feature (model, repo, commands, store, page) provided an almost 1:1 template for favorites.
- Glob pattern searches for files were straightforward. The project structure is consistent.
- The CLAUDE.md provided excellent context about conventions (COALESCE pattern, CSS variables, Svelte 5 runes, etc.) that directly informed the plan.

## What Went Wrong

- Initial glob searches for `src-tauri/src/commands/*.rs` returned empty because the glob tool does not support the same recursive behavior as `find`. Had to fall back to `ls` via Bash to discover the directory listing, then read individual files. Minor friction.
- No issues with research otherwise — the codebase is small enough to read relevant files directly.

## Codebase Surprises

- Artists and albums have no ID columns — they are purely name-derived aggregates from the `tracks` table. This is a deliberate design choice that simplifies the schema but makes favoriting artists/albums slightly awkward (must use name strings as identifiers).
- The `track_from_row` helper is duplicated between `library_repo.rs` (private fn) and `playlist_repo.rs` (inline in `get_playlist_tracks`). Making it `pub(crate)` in `library_repo.rs` and reusing it in both `playlist_repo.rs` and the new `favorite_repo.rs` would reduce duplication, but the plan only changes it to `pub(crate)` for the new repo — updating `playlist_repo.rs` would be scope creep.
- The `AlbumListView.svelte` uses `"\0"` (null byte) as a separator in album keys (line 44). The plan adopts this same convention for album favorite entity IDs.

## Suggestions

- The instructions were clear and the plan format requirements were well-specified.
- The explicit callout about artist/album identification being name-based was very helpful and saved research time.
- Consider adding a "Patterns to Follow" section to CLAUDE.md that explicitly lists the model->repo->command->store->page pipeline, since this is the main extension pattern for new features.
