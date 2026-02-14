# Postmortem: Planner — Play Queue Viewer

## Task

Research the codebase and write a PLAN.md for the "Play queue viewer" feature: a panel accessible from the player bar showing the current play queue with track highlighting, skip-to-track, reorder, and remove capabilities.

## What Went Well

- The codebase is well-organized. The player store, NowPlayingBar, and related components were easy to locate and understand.
- Existing patterns (Playlists page for drag-and-drop reorder, PlaylistPicker for overlay/backdrop, TrackRow for now-playing highlighting) provide clear templates for the new component.
- The player store already has a clean queue/queueIndex model that only needs 3 new methods (jumpTo, removeFromQueue, moveInQueue) — no architectural changes needed.
- The feature is entirely frontend — no Rust backend changes required, which simplifies the plan significantly.

## What Went Wrong

- Nothing significant. This was a well-scoped frontend feature with clear existing patterns to follow.

## Codebase Surprises

- The `Playlists.svelte` page's `playTrack` function has a subtle issue: it sets `playerStore.queue` directly then calls `playPlaylist(tracks.slice(...))`, which overwrites the queue again. This means the queue after playing a track from a playlist only contains tracks from the clicked track onward, not the full playlist. The play queue viewer will faithfully show whatever is in `playerStore.queue`, so this existing behavior will be visible to users. This is a pre-existing issue, not something the plan needs to fix.
- The NowPlayingBar has a fixed 72px height, which is useful for positioning the queue panel above it.
- Z-index values are spread across components: PlaylistPicker uses 100, MetadataEditor uses 200. The plan uses 150 for the queue panel to slot between them.

## Suggestions

- The plan format with "pattern reference" callouts (e.g., "follow Playlists.svelte for drag-and-drop") worked well for this feature since so many patterns already exist. This should be standard for plans where the codebase already has similar components.
- Consider fixing the Playlists.svelte `playTrack` behavior in a separate cleanup pass — it should set the queue to the full playlist and queueIndex to the clicked track's position, rather than slicing.
