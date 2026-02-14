# Postmortem: Planner — Project Docs Conventions

## Task

Research three documentation/convention actions and write PLAN.md for the `feat-project-docs` worktree:
1. Document `// svelte-ignore state_referenced_locally` as standard Svelte 5 pattern
2. Add CSS lint convention to prevent hardcoded colors
3. Establish convention on file deletion (permanent vs trash)

## What Went Well

- All three research areas had clear, consistent findings. The codebase is well-organized and patterns were easy to trace.
- The CSS custom property system in `app.css` is comprehensive — dark and light themes are fully defined with semantic variable names. The convention practically writes itself.
- File deletion was straightforward to audit: 4 call sites, all using `std::fs::remove_file`, no trash crate dependency. The distinction between sync deletions (non-destructive, copy exists elsewhere) and user-initiated deletions (destructive) was clear.

## What Went Wrong

- Nothing significant. The task was well-scoped and the instructions were clear.

## Codebase Surprises

- `DuplicateReport.svelte` has many hardcoded colors despite the rest of the codebase using CSS custom properties consistently. This is a good example of why the convention is needed.
- The `ArtistPicker.svelte` usage of `state_referenced_locally` is slightly different from the editors — it adds `$effect()` blocks to resync when props change, making it a "copy with resync" pattern rather than pure one-time copy.

## Suggestions

- The instructions were well-structured. No changes needed for this type of planning task.
- For the implementer: the changes are simple CLAUDE.md bullet additions, so the implementation should be very fast.
