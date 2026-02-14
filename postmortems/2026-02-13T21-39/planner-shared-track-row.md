# Postmortem: Planner - Shared Track Row Component

**Date:** 2026-02-13
**Role:** Planner
**Feature:** Shared Track Row Component

## Task

Research the codebase to understand the duplicated track row markup across TreeView, AlbumListView, GenreTreeView, and FolderTreeView, then write a PLAN.md describing how to extract a reusable TrackRow.svelte component.

## What Went Well

- The duplication was extremely consistent across all four views. The track row markup, CSS, and utility functions (`formatDuration`, `formatSize`) were nearly character-for-character identical, making the extraction straightforward to plan.
- The only meaningful difference between views was in FolderTreeView's title fallback (`relative_path.split("/").pop()` vs `relative_path`), which maps cleanly to a single optional `titleFallback` prop.
- The existing codebase follows clear Svelte 5 conventions (runes, `$props()`, `$state`, `$derived`) which made the component design predictable.
- The player store's interface (`playerStore.currentTrack?.file_path`) is simple and can be encapsulated entirely within the new component.

## What Went Wrong

- The PLAN.md file in the worktree already contained a plan for a completely different feature (Eject/Unmount Device Button). This was leftover content from the branch being created from main. It needed to be overwritten rather than created fresh, requiring an extra read step.

## Codebase Surprises

- All four views independently define identical `formatDuration` and `formatSize` functions. These utility functions have no view-specific logic and could have been shared long ago. The new `src/lib/utils/format.ts` module addresses this.
- FolderTreeView uses a Svelte 5 `{#snippet}` for recursive rendering (`folderContent`), which is a newer pattern. The TrackRow component fits cleanly inside the snippet since it's a leaf-level component.
- FolderTreeView does not have `onEditAlbum` in its props (folders don't map to albums), which is an expected difference that does not affect the track row extraction.

## Suggestions

- Consider also extracting the album header pattern (expand/collapse toggle + play album button + edit album button) into a shared component in a future feature. It's duplicated across TreeView, AlbumListView, and GenreTreeView with minor variations.
- The `src/lib/utils/` directory does not currently exist. Creating it with `format.ts` establishes a pattern for future shared utilities.
