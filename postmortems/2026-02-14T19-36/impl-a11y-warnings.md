# Postmortem: impl-a11y-warnings

## Task

Fix 2 pre-existing `npm run check` a11y warnings to reach 0 errors and 0 warnings. The two warnings were:
1. `a11y_label_has_associated_control` in Settings.svelte (Theme label missing `for`/`id` association)
2. `a11y_interactive_supports_focus` in DuplicateReport.svelte (dialog div missing `tabindex`)

## What Went Well

- The plan was precise and surgical -- each fix was exactly 1-2 lines per file.
- Both fixes applied cleanly with no surprises.
- `npm run check` immediately showed 0 errors and 0 warnings after the edits.
- `cargo test` passed all 42 tests on first run.
- Total implementation time was very fast due to plan clarity.

## What Went Wrong

Nothing went wrong. This was a clean, straightforward fix.

## PLAN.md Quality

Excellent. The plan was clear, complete, and accurate:
- Exact file paths and line numbers were correct.
- The specific attributes to add/modify were spelled out.
- The rationale for each fix was included (e.g., why `tabindex="-1"` vs `tabindex="0"`).
- The existing pattern in Settings.svelte (`for="setting-sync-mode"`) was referenced, making the fix consistent.
- Dead code section and risks section were appropriately marked as "None".

## Codebase Surprises

- The DuplicateReport.svelte already had a `svelte-ignore` comment attempting to suppress the `a11y_interactive_supports_focus` warning, but the warning still fired. The proper fix was adding the `tabindex` attribute rather than relying on suppression.

## Suggestions

- For small fixes like this, the planning + implementation two-phase approach adds overhead. A single implementer could handle both research and fix in one pass. Consider a "fast-track" mode for S-sized tasks.
- The plan format worked well for this size. No changes needed to the format itself.
