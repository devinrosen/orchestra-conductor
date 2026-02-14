---
name: ui-test
description: Run Playwright against the Vite dev server with Tauri IPC mocks, screenshot each page, and analyze for visual/layout bugs using Claude's vision.
disable-model-invocation: true
argument-hint: [page-names or "all"] [--label <name>]
---

# /ui-test

Visual QA skill that uses Playwright to navigate the app (via Vite dev server + Tauri IPC mocks), take screenshots of each page, and analyze them with Claude's vision for layout and visual issues.

## Usage

```
/ui-test                        # Test all pages (cleans previous screenshots)
/ui-test library                # Test specific page(s)
/ui-test library --label v2     # Iterative: saves as library-v2.png (no cleanup)
/ui-test all --label after-fix  # All pages, labeled (no cleanup)
```

## Prerequisites

- Node.js and npm
- Playwright + Chromium browser installed

## Pages

The app has these navigable pages (sidebar nav buttons):

| Page ID      | Nav Label     |
|-------------|---------------|
| library     | Library       |
| statistics  | Statistics    |
| playlists   | Playlists     |
| profiles    | Sync Profiles |
| devices     | Devices       |
| settings    | Settings      |

## Workflow

### Step 1: Ensure Playwright is installed

Check if Chromium is available. If not, install it:

```bash
cd main && npx playwright install chromium 2>/dev/null || npx playwright install chromium
```

### Step 2: Run Playwright tests

The `playwright.config.ts` has `webServer` configured to auto-start the Vite dev server on port 1420 (and reuse it if already running). No manual server management is needed.

**Standard run** (cleans previous screenshots, takes fresh ones):

```bash
cd main && npx playwright test e2e/ui-screenshots.spec.ts
```

**Specific pages:**

```bash
cd main && PAGES=library,settings npx playwright test e2e/ui-screenshots.spec.ts
```

**Iterative/labeled run** (preserves existing screenshots, appends label):

```bash
cd main && LABEL=after-fix npx playwright test e2e/ui-screenshots.spec.ts
```

This produces `library-after-fix.png`, `statistics-after-fix.png`, etc. alongside any existing screenshots — useful for before/after comparisons.

### Screenshot naming and cleanup

- **Without `LABEL`**: Previous screenshots are deleted before the run. Clean slate every time.
- **With `LABEL`**: Previous screenshots are preserved. New ones are saved as `{page}-{label}.png`.
- **Auto-increment**: If a file already exists (e.g., running the same label twice), names increment automatically: `library-after-fix.png` → `library-after-fix-2.png` → `library-after-fix-3.png`.

Screenshots are saved to `test-results/screenshots/` (gitignored).

### Step 3: Analyze Screenshots

Read each screenshot using the `Read` tool (Claude's vision). For each screenshot, evaluate:

**Layout issues:**
- Elements overflowing their containers
- Content cut off or hidden behind other elements
- Incorrect z-ordering (overlapping panels)
- Misaligned elements or inconsistent spacing
- Sidebar/content area sizing issues

**Visual issues:**
- Missing or broken icons
- Incorrect colors or color contrast problems
- Text readability issues (too small, wrong color, truncated)
- Empty states that should have content or placeholder text
- Broken or missing images

**Component issues:**
- Buttons that look unclickable or have wrong styling
- Input fields that aren't properly styled
- Scroll areas that don't indicate scrollability
- Interactive elements that overlap or are blocked by other elements

**Theme consistency:**
- Colors matching the current theme (dark theme by default in mocks)
- Consistent use of CSS custom properties (no hardcoded colors standing out)
- Dark/light theme rendering correctly

### Step 4: Report

Present a summary table:

```
| Page          | Status | Issues Found |
|---------------|--------|-------------|
| Library       | pass   | —           |
| Statistics    | warn   | 2 issues    |
| ...           |        |             |
```

For each issue found, include:
- **Page**: Which page
- **Severity**: `error` (blocks usage), `warning` (visual defect), `info` (minor polish)
- **Description**: What's wrong
- **Location**: Where in the screenshot (e.g., "bottom-right, player controls area")
- **Suggestion**: How to fix it

When running with `--label`, also compare labeled screenshots against the base versions (if they exist) and note any regressions or improvements.

## How the mocks work

The test injects `main/e2e/tauri-mocks.ts` via `page.addInitScript()` before navigating to the app. This sets up `window.__TAURI_INTERNALS__` with a mock `invoke()` handler that returns realistic data for all Tauri commands called during page load (library tree, playlists, settings, devices, etc.).

This is entirely external to the app — no build pipeline changes, no risk of leaking into production. Pages render with populated data instead of error/empty states.

## Limitations

- Cannot test dynamic interactions (drag-and-drop, complex form flows) — only static page state
- Cannot test audio playback visualization (requires audio playing)
- Mock data is static — does not reflect the user's actual library
- Cannot test real Tauri-specific features (file dialogs, system tray, etc.)
