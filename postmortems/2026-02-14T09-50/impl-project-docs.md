# Postmortem: impl-project-docs

## Task

Implement two changes in the `feat-project-docs` worktree:
1. Add 3 new convention bullets to the `## Conventions` section in `CLAUDE.md` (as specified in PLAN.md)
2. Replace all hardcoded color values in `DuplicateReport.svelte` with CSS custom property references from `app.css`

## What Went Well

- PLAN.md provided exact text for the three convention bullets, making the CLAUDE.md edit trivial and unambiguous.
- The CSS custom properties in `app.css` were well-organized and easy to map to the hardcoded values in DuplicateReport.svelte.
- Both `npm run check` and `cargo test` passed on first attempt with no issues.
- The color replacements were straightforward -- each hardcoded value had a clear semantic equivalent in the theme system.

## What Went Wrong

- Nothing significant went wrong. The task was well-scoped and clearly specified.

## PLAN.md Quality

- Excellent for the CLAUDE.md changes: exact text provided, clear section placement.
- The plan correctly identified the hardcoded colors in DuplicateReport.svelte but this was listed as context for the convention bullet rather than as an action item. The team lead's additional task instructions filled this gap.
- The plan could have included the additional hardcoded values I found: `rgba(255, 255, 255, 0.05)` fallback on `.track-row:hover` and `#e94560` fallbacks on `.danger-btn`. These were unnecessary fallbacks for always-defined variables.

## Codebase Surprises

- The success/info/orange colors in DuplicateReport.svelte used different raw values than the theme defines (e.g., `#4caf50` Material green vs `#4ecca3` theme success teal). Switching to `var(--success)` changes the actual rendered color, but this is correct -- the component should use the theme's palette, not its own.
- The `.select-best-btn` had a `var(--bg-tertiary, var(--bg-primary))` pattern which is fine since both are CSS variables, but the `.danger-btn` had `var(--danger, #e94560)` with a hardcoded hex fallback that was unnecessary.

## Suggestions

- When a plan identifies code that violates a convention being documented, the plan should include a separate action to fix that code, rather than relying on supplementary instructions from the team lead.
- The plan's "Context" sections were very helpful for understanding *why* each convention exists. This pattern should be continued in future plans.
