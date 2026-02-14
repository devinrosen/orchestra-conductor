# Postmortem: impl-ui-skins

## Task

Implement the UI Skins (Light/Dark Mode) feature following the plan in PLAN.md. This involved:
- Defining light and dark CSS variable palettes in app.css
- Creating a ThemeStore (Svelte 5 runes) for OS theme detection and persistence
- Integrating the store in App.svelte with a reactive $effect
- Adding an Appearance section to the Settings page
- Replacing ~35 hardcoded rgba/hex color values across 14 component files with CSS custom properties
- Replacing `color: white` on accent-background buttons with `var(--on-accent)`

## What Went Well

- **Plan quality was excellent.** The PLAN.md was highly detailed with exact file paths, line numbers, CSS snippets, and a comprehensive replacement table. This made implementation straightforward with minimal guesswork.
- **No ambiguity in the replacement table.** Every hardcoded color had a clear mapping to a CSS variable, making the bulk replacement step mechanical and fast.
- **Zero errors introduced.** `cargo test` passed all 28 tests and `npm run check` reported 0 errors. All warnings were pre-existing.
- **Pattern consistency.** The ThemeStore followed the exact same pattern as existing stores (class with $state/$derived runes, singleton export, async init), making it feel native to the codebase.
- **No Rust changes needed.** Reusing the existing get_setting/set_setting commands meant zero backend work.

## What Went Wrong

- Nothing significant went wrong. The implementation was clean and followed the plan exactly.

## PLAN.md Quality

The plan was very high quality:
- **Strengths:** Exact CSS variable names and values for both themes, precise file:line references for every replacement, clear store implementation with full code snippet, step-by-step ordering that made sense.
- **Minor gap:** The plan mentioned "~35 replacements" but the actual count in the table was slightly higher when counting sub-items in some rows (e.g., MetadataReport badges had 4 sub-replacements in one row). Not a real problem, just a minor discrepancy in the count.
- **Step 6 (color: white on buttons)** was useful but could have been more explicit about which files beyond the NowPlayingBar. I found additional `color: white` instances in app.css (button.primary), ConflictCard, and PlaylistPicker that also benefited from the replacement.

## Codebase Surprises

- The Settings page labels already had pre-existing a11y warnings (`a11y_label_has_associated_control`) for the existing settings. Adding the Theme setting followed the same pattern and inherited the same warning style. This is a known pre-existing issue, not something introduced by this feature.
- The `button.primary` global style in app.css also used `color: white` which the plan didn't explicitly mention but was a natural candidate for `var(--on-accent)`.

## Suggestions

- **Plan format is great as-is.** The table format for color replacements was particularly effective for bulk changes.
- **Could add a "verify" step** to the plan suggesting a grep for remaining hardcoded colors after the replacement pass, to catch any that were missed.
- **The `color: white` audit in Step 6** could be expanded to a full grep-based list rather than a mention of "several places."
