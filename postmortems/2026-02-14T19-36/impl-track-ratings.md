# Postmortem: impl-track-ratings

## Task

Implement the **Track ratings / favorites** feature -- a 1-5 star rating on tracks. Follow the 8-step PLAN.md to add a `rating` column to the database, update the Rust model, all SQL queries, add an IPC command, update TypeScript types, build a star widget in TrackRow.svelte, update Tauri mocks, and write tests.

## What Went Well

- The PLAN.md was well-structured with clear step-by-step instructions and code snippets. It was easy to follow sequentially.
- The plan correctly identified the `has_album_art` / `bitrate` migration pattern as a reference, making the migration straightforward.
- The `update_track_hash` function pattern for `set_track_rating` was a clean match.
- The test cases were well-specified and all 4 passed on first try.
- The existing codebase is well-organized -- consistent patterns made it easy to follow conventions.

## What Went Wrong

1. **replace_all on a substring caused a double-append bug**: I used `replace_all` to add `, rating` after `bitrate` in all SELECT column lists. This also matched the `bitrate` in the `upsert_track` INSERT column list, which resulted in `bitrate, rating, rating` (doubled). The VALUES still had `?19` for 19 params but the column list now had 20 columns, causing "19 values for 20 columns" errors in 25 tests. Fixed by manually correcting the doubled column.

2. **Plan missed playlist_repo.rs and scanner/metadata.rs**: The plan listed 6 SELECT statements that needed updating but only covered `library_repo.rs`. The `playlist_repo.rs` file has its own inline Track mapping (not using `track_from_row`) plus a test helper, and `scanner/metadata.rs` constructs Track structs directly. Both needed `rating` added. I found these by grepping for `has_album_art|bitrate` across the full `src-tauri/src/` directory.

3. **Nested button a11y warning**: The plan placed star `<button>` elements inside the `.track-node` `<button>`, which is invalid HTML. svelte-check flagged 3 new warnings (nested button, span with click handler lacking ARIA role). Fixed by moving the star rating span outside the `<button>` as a sibling in `.track-row`.

## PLAN.md Quality

**Good**: Clear, structured, with file paths and line numbers. Code snippets were mostly copy-paste ready. The risk section was helpful.

**Issues**:
- The plan says "8 SELECT statements" but only lists 6. The actual count of `track_from_row` usages is exactly 6 -- so the plan's claim of 8 is inaccurate but the listed 6 are correct. However, it completely missed `playlist_repo.rs` (1 SELECT + 1 test helper) and `scanner/metadata.rs` (1 Track construction), which are 3 additional locations needing `rating`.
- The plan's HTML structure for the star widget places `<button>` elements nested inside another `<button>`, which causes a11y warnings. The fix was simple (move stars outside) but the plan should have noted this constraint.
- The plan didn't account for the `upsert_track` column count needing to change from `?18` to `?19` in the VALUES clause -- it only mentioned adding to the column list and ON CONFLICT clause.

## Codebase Surprises

- `playlist_repo.rs` has its own inline Track row mapping instead of reusing `track_from_row` from `library_repo.rs`. This means every Track field addition requires updating both files.
- The existing a11y warnings in DuplicateReport.svelte and Settings.svelte are pre-existing and suppressed -- good to know they're known issues.

## Suggestions

1. **Grep-based validation in plans**: When a plan says "update all N locations", include a grep command to verify the count. For this feature, `grep -rn 'track_from_row\|has_album_art.*bitrate' src-tauri/src/` would have caught the missed files.
2. **Note HTML nesting constraints**: Plans that add interactive elements inside existing interactive elements should flag potential nesting issues.
3. **Consider refactoring playlist_repo to reuse track_from_row**: The duplicated Track mapping is a maintenance burden. Could be a separate cleanup task.
4. **Be cautious with replace_all on partial strings**: When using replace_all, verify the replacement doesn't match locations where the old string appears in a different context (like column lists vs. value lists).
