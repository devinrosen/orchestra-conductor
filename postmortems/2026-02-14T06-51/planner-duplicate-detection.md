# Postmortem: Planner — Duplicate Detection

## Task

Research the codebase and write PLAN.md for the Duplicate Detection feature: scan the library for duplicate tracks by content hash or metadata similarity, and provide options to review and remove duplicates.

## What Went Well

- The codebase is very well-organized. The clear separation between models, db repos, commands, and frontend stores made it straightforward to trace the existing patterns.
- The existing `hash` column on the `tracks` table was a lucky find — no schema migration needed for content-hash detection. The BLAKE3 hasher in `scanner/hasher.rs` is already battle-tested in the sync diff flow.
- Pattern consistency is excellent: every feature follows the same model -> repo -> command -> types.ts -> commands.ts -> store -> component pipeline. Made planning predictable.
- The `MetadataReport` component is almost a perfect template for the DuplicateReport UI — same modal overlay, filter tabs, scrollable list pattern.
- Existing test patterns in `library_repo.rs` (the `stats_tests` module) provide a clear template for the new test module.

## What Went Wrong

- Nothing significant. The research phase was smooth because the codebase has strong conventions.
- Minor: had to read many files to fully understand the hashing flow (scanner/hasher.rs is used only during sync diff, not during scan — so tracks generally have NULL hashes). This informed the plan's "on-demand hashing" phase.

## Codebase Surprises

- **Hashes are not computed during library scan** — the `hash` field on Track is always `None` after scanning. Hashes are only computed lazily during the sync diff process (`sync/diff.rs:compute_hash_if_needed`). This means the duplicate detection command must first hash all unhashed tracks before grouping, which could be slow on large libraries and needs progress reporting.
- **No `trash` crate** — the plan calls for `std::fs::remove_file` for deletion. A "move to trash" option would be safer but would require a new dependency. The current plan uses permanent deletion for simplicity, matching what sync operations already do.
- The `track_from_row` helper in `library_repo.rs` is a private function, but it's reused by all query functions in that file. The new duplicate query functions will also use it — good that it exists.

## Suggestions

- The instruction to include a "Dead Code" section is helpful for implementers but often the answer is "none" for additive features. Consider making it optional or only required when modifications to existing code are planned.
- The plan format could benefit from a "Dependencies / New Crates" section — this feature doesn't need any, but others might.
- For features involving file deletion, it might be worth having a project-wide convention on whether to use permanent deletion or a trash mechanism. Could be an ACTIONS.md item.
