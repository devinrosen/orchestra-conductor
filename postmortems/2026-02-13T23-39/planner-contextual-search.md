# Postmortem: Planner — Contextual Library Search

## Task

Research the codebase and write a PLAN.md for the "Contextual library search" feature: make the search bar filter contextually based on the active view mode (Artist, Album, Genre, Folder), filtering at the top-level grouping instead of individual tracks, and preserving the tree structure beneath matches.

## What Went Well

- The codebase is well-organized with clear separation: Rust backend (commands, db, models), TypeScript API layer (commands.ts, types.ts), Svelte stores, and view components. Easy to trace the full search flow from UI to SQL.
- The existing `library-grouping.ts` utility already exports pure functions (`groupByAlbum`, `groupByGenre`, `groupByFolder`) that provide an obvious pattern for adding filter functions.
- The `$derived` pattern in the library store makes it straightforward to add filtered variants without changing the view components.
- All four view components accept their data as props, so the filtering can happen entirely in the store/page layer without touching view components at all.

## What Went Wrong

- Nothing significant. The feature is well-scoped and the existing architecture supports it cleanly.
- Initially considered whether this needed new Rust commands, but quickly determined frontend-only filtering was the right approach since all data is already loaded.

## Codebase Surprises

- The current `search_tracks` SQL query matches against `title`, `artist`, `album`, and `album_artist` but does NOT match against `genre` or `relative_path` (folder). This means the current search couldn't even approximate contextual genre/folder search.
- The `albumEntries`, `genreNodes`, and `folderTree` derived properties are guarded by `this.viewMode === "..."` checks, meaning they only compute when the corresponding view is active. This is an optimization but means filtered derivatives need the same guard pattern.
- The search results section in Library.svelte uses an `{#if}...{:else if}` chain where search results take precedence over the tree view. This means the tree view is completely hidden during search, which is the exact behavior we want to replace.

## Suggestions

- The plan format requiring "Dead Code" section is useful for preventing orphan code, but for this feature the impact is minimal (just removing one state property and one function call). The section feels slightly forced for small changes.
- The instruction to "note which defined types are actually consumed by functions vs. defined speculatively" is hard to evaluate during planning since type usage is spread across the whole codebase. A better framing might be "list any new types you're introducing and which functions will consume them."
