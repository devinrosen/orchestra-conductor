# Postmortem: planner-sync-by-album

## Task

Plan the "Sync by album" feature: allow users to select individual albums (not just whole artists) to sync to a device. Research the entire codebase to understand the existing device sync flow, then produce a detailed PLAN.md covering backend (DB, queries, commands) and frontend (types, store, UI) changes.

## What Went Well

- The codebase is well-organized with clear separation of concerns. The naming is consistent (device_repo for DB, device_cmd for commands, device.svelte.ts for the store), making it easy to trace the full data flow from UI to database.
- The existing artist selection pattern (DB table, repo functions, command, store method, UI component) provided a direct template for the album selection feature. The plan could be written as "do the same thing but for albums" in most layers.
- The sync pipeline is cleanly separated: track fetching is independent from diff computation and sync execution. This means the feature only needs to change the track-fetching step; the diff and sync layers are untouched.
- Reading the ArtistPicker component made it clear exactly how the UI interaction works, which made designing the album expansion straightforward.

## What Went Wrong

- Nothing significant went wrong. The task was well-scoped and the codebase was clean enough to navigate efficiently.
- Minor: had to read several files to understand that `COALESCE(album_artist, artist, 'Unknown Artist')` is the canonical artist grouping key used everywhere. This could have been documented in CLAUDE.md or a conventions doc.

## Codebase Surprises

- The device sync flow uses its own separate diff/sync engine (`device/sync.rs`) rather than the profile-based sync engine (`sync/diff.rs`, `sync/one_way.rs`). They share `copy_file_safe` and `remove_empty_parents` from `one_way.rs`, but the diff logic is fully separate. This means changes to device sync don't risk breaking profile sync.
- The `DeviceWithStatus` struct bundles `selected_artists` alongside the device data, meaning the frontend always has selection data available without a separate fetch. The album selections need to follow this same pattern.
- The `device_file_cache` table with hash caching is a nice optimization -- the diff engine reuses cached hashes when file size+mtime haven't changed, avoiding expensive re-hashing of device files.
- Unicode normalization (`NFC + lowercase`) is used throughout device sync to handle FAT32/exFAT filesystem case-insensitivity. This is well-encapsulated in `normalize_path`.

## Suggestions

- The CLAUDE.md could mention the canonical artist grouping expression (`COALESCE(album_artist, artist, 'Unknown Artist')`) since it's used in multiple places and is crucial for any feature touching artist/album grouping.
- The feature description in FEATURES.md is concise, which is good, but could benefit from noting any explicit design constraints (e.g., "album selection should be additive to artist selection" vs "album selection should replace artist selection").
- The planning workflow was efficient. No changes suggested to the plan format or workflow.
