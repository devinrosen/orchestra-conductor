# Postmortem: Planner — Track Ratings

## Task

Research the Orchestra app codebase and write a PLAN.md for the "Track ratings / favorites" feature. The feature adds a 1-5 star rating to tracks, displayed in TrackRow and persisted to the database.

## What Went Well

- The codebase is very well-organized with clear patterns. The migration pattern (`has_column` check + `ALTER TABLE ADD COLUMN`) in `schema.rs` makes adding new columns straightforward.
- The `track_from_row` helper centralizes column mapping, so there's exactly one place to update the row-to-struct mapping. All SELECT queries that return full tracks use this function.
- The `TrackRow.svelte` shared component means the rating widget only needs to be added once and automatically appears in all 4 browse views (Artist, Album, Genre, Folder).
- The existing hover-to-show pattern (play button, add-to-playlist button) provides a clear UX precedent for the star rating visibility behavior.

## What Went Wrong

- Nothing significant. The feature is well-scoped and the codebase patterns are consistent.

## Codebase Surprises

- The `track_from_row` function uses positional column indices (0-18) rather than column names. This is fragile — adding a column requires updating the index in the function AND ensuring all SELECT statements list columns in exactly the same order. It works because the project is disciplined about it, but it's a maintenance risk.
- The `upsert_track` function has grown to 18 columns with positional parameters (?1 through ?18). Adding `rating` makes it ?19. This is approaching the point where a builder pattern or named parameters would improve readability.
- The feature description mentions "heart toggle or 1-5 star rating" — I chose 1-5 star rating because it subsumes favorites (a favorite is just a 5-star or any rated track), and the column works naturally as a smart playlist criterion with comparison operators.

## Suggestions

- The plan format worked well for this medium-sized feature. No changes needed.
- Consider documenting the `track_from_row` column index convention more explicitly in CLAUDE.md, since it's a common source of bugs when adding fields to the Track model.
