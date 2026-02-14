# Postmortem: Planning Library Statistics Feature

## Task

Research the codebase and write PLAN.md for the "Library Statistics" feature -- a dashboard showing format breakdown, genre distribution, total library size, number of artists/albums/tracks, and average bitrate.

## What Went Well

- The codebase is well-organized and consistent. The patterns for adding a new Tauri command are clear: model struct, repo function, command function, register in handler, TypeScript type, command wrapper, page component, router entry.
- The existing `list_artists` and `list_albums` functions in `library_repo.rs` provided good examples of aggregate SQL queries that informed the stats query design.
- The database schema has all the columns needed for most statistics (format, genre, file_size, duration_secs). Only bitrate was missing.
- The `lofty` library (0.22) provides `overall_bitrate()` on `FileProperties`, making the bitrate extraction straightforward.
- The migration pattern for adding columns (seen with `has_album_art`) is clean and easy to follow.

## What Went Wrong

- Nothing significant. The planning phase was straightforward.

## Codebase Surprises

- Bitrate is not stored in the database despite being easily available from lofty. This means the plan needs to include a schema migration and scanner update, not just a query.
- The `Track` struct row mapping is duplicated 7 times in `library_repo.rs` (one per query function). Adding a column means updating all 7 places. This is a maintenance burden but not something to fix in this feature.
- The PLAN.md in the worktree was left over from a previous feature (eject device), not a clean file. This is expected for worktrees reused across features.
- There's no existing test infrastructure in `library_repo.rs` -- the existing tests are only in `sync/diff.rs` and `sync/two_way.rs`. The stats tests will be the first tests for the library repo module.

## Suggestions

- Consider extracting the row-to-Track mapping into a helper function to reduce duplication across the 7+ query functions in `library_repo.rs`. This would make adding columns much easier in the future. (Out of scope for this feature but worth noting.)
- The `total_albums` count query uses `COUNT(DISTINCT COALESCE(album, 'Unknown Album'))` which groups all tracks without an album tag into one "Unknown Album" bucket. This is acceptable for statistics but worth documenting.
- Future enhancement: the statistics page could show a bitrate distribution histogram (e.g., how many tracks at 128/256/320/lossless) rather than just an average. The avg_bitrate field enables this later.
