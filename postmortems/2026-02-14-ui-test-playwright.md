# Session Postmortem: Playwright UI Testing Skill

**Date:** 2026-02-14
**Goal:** Replace unreliable macOS screencapture/CGEvent `/ui-test` skill with Playwright + Tauri IPC mocking

## Timeline

1. **Planning** (pre-session) — Plan already written and approved.
2. **Implementation** (~10 min) — Read reference files (types, stores, App.svelte, commands, page components) to understand all IPC calls during page load. Created all 6 files: docs update, package.json edits, playwright config, tauri mocks, test spec, SKILL.md rewrite.
3. **Fix** (~1 min) — ESM `__dirname` error in test spec. Fixed with `fileURLToPath(import.meta.url)`.
4. **Verification** — Playwright test passed (1 test, 6 screenshots, 4.3s). Visual inspection confirmed all pages render with populated mock data.
5. **Skill execution** — Ran `/ui-test` end-to-end. All 6 pages passed with no visual/layout issues.
6. **Cleanup** — Added `test-results/` to both `.gitignore` files. Committed to both repos.

## What Went Well

- **Thorough reference reading** — Reading all stores, page components, and commands.ts before writing mocks meant the mock data covered every IPC call. No missing commands at runtime.
- **Mock architecture** — `page.addInitScript()` with a self-contained JS string worked perfectly. Zero changes to the app's build pipeline. The `window.__TAURI_INTERNALS__` mock matched Tauri's internal API exactly.
- **Realistic mock data** — 21 tracks across 3 artists/5 albums with mixed formats (FLAC/MP3) made every page render with meaningful content: library tree, statistics charts, playlist list, device cards, profile cards, settings dropdowns.
- **Single test cycle** — After the one `__dirname` fix, everything passed on the first run. No iteration needed on mock data or selectors.
- **End-to-end skill validation** — Running `/ui-test` immediately after implementation proved the full workflow works.

## What Went Wrong

- **ESM `__dirname`** — Used `__dirname` in the test spec despite `package.json` having `"type": "module"`. Common ESM gotcha that should have been caught during writing.
- **Minor: ACTIONS.md description** — The ACTIONS.md checkbox update still mentions "AppleScript coordinate clicking" which describes the old approach, not the new Playwright approach.

## What Can Be Improved

- **ESM awareness** — When a project uses `"type": "module"`, always use `import.meta.url` patterns instead of `__dirname`/`__filename`.
- **Mock maintenance** — If new IPC commands are added to the app, `main/e2e/tauri-mocks.ts` needs updating. The mock already logs `console.warn("[tauri-mock] unhandled command:", cmd)` for unhandled calls.
- **Selective page testing** — The skill says `/ui-test library` should test specific pages, but the Playwright test always screenshots all 6. A future enhancement could accept a page filter via environment variable.

## Files Changed

**main/ repo:**
- `package.json` — Added `@playwright/test` devDep + `test:ui` script
- `playwright.config.ts` — Created (Chromium, headless, 1280x800, localhost:1420)
- `e2e/tauri-mocks.ts` — Created (Tauri IPC mock with realistic data for all commands)
- `e2e/ui-screenshots.spec.ts` — Created (navigates all 6 pages, screenshots each)
- `.gitignore` — Added `test-results/`

**orchestration repo:**
- `.claude/skills/ui-test/SKILL.md` — Rewritten for Playwright workflow
- `docs/ui-testing-review.md` — Updated with tauri-driver macOS finding + decision pivot
- `.gitignore` — Added `test-results/`
- `ACTIONS.md` — Checked off UI testing action item
