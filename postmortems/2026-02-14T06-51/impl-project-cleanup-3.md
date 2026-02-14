# Postmortem: impl-project-cleanup-3

## Task

Implement Project Cleanup Bundle 3:
1. Extract shared tree CSS (`.tree-toggle`, `.chevron`, `.count`, `.children`) from 5 component files into global `app.css`
2. Fix all 25 svelte-check warnings across 8 files (state_referenced_locally, a11y_interactive_supports_focus, a11y_label_has_associated_control, attribute_quoted)

## What Went Well

- Part 1 (CSS extraction) was straightforward. The plan accurately identified all duplicated selectors and which files to modify.
- The a11y fixes (tabindex, for/id pairs, attribute_quoted) were simple and worked on the first try.
- Cargo tests (28/28) passed without issues since only frontend files were modified.
- Final result: 0 errors, 0 warnings from `npm run check`.

## What Went Wrong

- The plan's approach for `state_referenced_locally` warnings did not work. The plan suggested using intermediate const variables to break the reactive chain (e.g., `const initTitle = track.title; let title = $state(initTitle)`). Svelte's compiler still detected the reactive prop reference through the intermediate const, leaving 8 warnings after the first attempt.
- Had to pivot to using `// svelte-ignore state_referenced_locally` comments inside `<script>` blocks, which is the correct Svelte 5 approach. The plan explored this option but incorrectly concluded that svelte-ignore comments don't work in script blocks. They do work in Svelte 5.50.3.

## PLAN.md Quality

- **Part 1 (CSS)**: Excellent. Accurate selector inventory, clear file list, correct identification of component-specific overrides to keep.
- **Part 2 (svelte-check)**: Mixed. The a11y and attribute_quoted fixes were clear and correct. The `state_referenced_locally` section was overly long (110 lines of deliberation) and ultimately recommended an approach that doesn't work. The plan went through 6+ candidate approaches before settling on intermediate consts, but never tested whether `// svelte-ignore` works in `<script>` blocks (it does).
- **Suggestion**: For warnings where multiple fix strategies exist, the plan should include a fallback strategy. "Try X first; if it doesn't suppress the warning, use `// svelte-ignore` as fallback."

## Codebase Surprises

- None significant. The codebase was well-organized and matched the plan's descriptions.
- The ArtistPicker already had `$effect` blocks that resync state when props change, so the state_referenced_locally warning was truly a false positive there.

## Suggestions

- Plans should avoid extended deliberation sections. The state_referenced_locally analysis could have been 20 lines instead of 110. A concise "try A, fallback to B" is more useful than a stream-of-consciousness exploration.
- For Svelte-specific warnings, the planner should verify the Svelte version in use and check whether `svelte-ignore` works in script blocks before ruling it out.
- The plan's implementation order was good and efficient.
