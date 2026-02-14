# Postmortem: Planner — Project Cleanup Bundle 3

## Task

Research the codebase and write PLAN.md for a project cleanup bundle with two items: (1) extract shared tree CSS into a shared stylesheet, and (2) resolve all 25 pre-existing svelte-check warnings.

## What Went Well

- The codebase is well-organized: all tree components are in `src/lib/components/` and follow very consistent patterns, making the CSS duplication easy to catalog exhaustively.
- Running `npm run check` gave precise, actionable output — every warning included the file, line number, and Svelte diagnostic URL, making it easy to plan exact fixes.
- The existing `app.css` global stylesheet already exists and is imported in `App.svelte`, providing a natural home for shared tree CSS without needing a new import mechanism.
- The warning categories are well-defined and each has a clear mechanical fix pattern.

## What Went Wrong

- The `state_referenced_locally` warning required significant research to determine the correct Svelte 5 fix. The Svelte docs are somewhat vague on how to intentionally copy a prop to local state without triggering this warning. I initially considered several approaches (untrack, removing $state, svelte-ignore in script) before settling on the "intermediate const destructure" pattern.
- The instruction mentioned "DeviceSync, MetadataEditor, AlbumEditor, MetadataReport" for `a11y_interactive_supports_focus` but DeviceSync is in `src/pages/` not `src/lib/components/`. A small path discrepancy that required a file search to resolve.
- ArtistPicker's `.chevron` styles differ slightly from the shared tree `.chevron` (it uses `display: inline-block`). This cross-component variation required careful analysis to ensure the global rule wouldn't break ArtistPicker.

## Codebase Surprises

- ArtistPicker.svelte also has `.chevron` and `.chevron.expanded` selectors (making it a 5th file with chevron duplication), even though it wasn't listed in the original task description as a tree CSS duplicate.
- The editors (MetadataEditor, AlbumEditor) already have `svelte-ignore` comments that include `a11y_interactive_supports_focus`, but the warning still fires. This is because `svelte-ignore` comments on the same line as the element suppress the warning in the template, but the svelte-check CLI still reports it. The proper fix (adding `tabindex="-1"`) will resolve it at the source level rather than suppressing.
- SyncPreview.svelte has an `attribute_quoted` warning (line 88) that wasn't mentioned in the original task description but showed up in `npm run check` output. Added to the plan.

## Suggestions

- For future cleanup bundles, running `npm run check` first and including the exact output in the task description would save research time and ensure completeness.
- The "intermediate const destructure" pattern for `state_referenced_locally` is non-obvious. If it works, it should be documented in CLAUDE.md or MEMORY.md as the standard pattern for "copy prop to local editable state" in this codebase.
- Consider whether `svelte-ignore` comments that are now redundant (because the underlying issue is properly fixed) should be cleaned up as part of this bundle. The plan includes removing `a11y_interactive_supports_focus` from those comments.
