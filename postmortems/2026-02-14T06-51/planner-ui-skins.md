# Postmortem: Planner — UI Skins (Light/Dark Mode)

## Task

Research the codebase and write PLAN.md for the UI skins (light/dark mode) feature. The feature should support light and dark color themes with a toggle in Settings, respect OS-level appearance by default, use CSS custom properties, and persist the user's choice.

## What Went Well

- The codebase already uses CSS custom properties exclusively in `:root` for all major colors. This made the theming approach straightforward — define an alternate set of variables under `[data-theme="light"]`.
- The existing `settings` table and `get_setting`/`set_setting` commands eliminate the need for any Rust-side changes. The feature is purely frontend.
- The store pattern (Svelte 5 rune-based class singletons) is well-established and consistent across `libraryStore`, `profilesStore`, `playerStore`, etc. Easy to follow for the new `themeStore`.
- The `libraryStore` already demonstrates persisting a UI preference (view mode) via `setSetting`, which is exactly the pattern for theme persistence.

## What Went Wrong

- Nothing major. The planning was straightforward because the codebase has a clean, consistent architecture.
- There are approximately 35 hardcoded `rgba()` and hex color values scattered across 14 files that need to be extracted to CSS variables. This is the bulk of the work and is tedious but not complex. Cataloging each one took careful grepping.

## Codebase Surprises

- The app has zero hardcoded hex colors in `<style>` blocks inside `.svelte` files for the main theme colors (bg, text, border) — everything uses `var(--...)`. But it does have many hardcoded `rgba()` values for semi-transparent tints, overlays, and shadows. These are consistently the accent/success/warning colors at low opacity, used for hover states, tag backgrounds, and modal overlays.
- `button.secondary:hover` in `app.css` has a hardcoded `#1a4a80` rather than using a variable — the only place in the global stylesheet with a hardcoded color outside `:root`.
- The `color: white` used for text on accent-colored buttons is implicit rather than defined as a variable. Adding `--on-accent` makes this themeable.

## Suggestions

- The plan format instructions asked for "exact counts and specific functions" for code duplication, which was useful for the hardcoded-color audit but felt somewhat forced since this feature doesn't involve refactoring duplicated logic.
- The instruction to note "which types are consumed by repo functions vs. defined speculatively" didn't really apply here since no new Rust types are needed. Could be helpful to note that this check can be skipped when the feature is frontend-only.
- Consider adding a pre-existing CSS variable audit to the codebase (e.g., a lint rule flagging hardcoded colors in `.svelte` style blocks) to prevent this kind of scattered hardcoding from accumulating in the future.
