---
name: ui-test
description: Run Playwright against the Vite dev server with Tauri IPC mocks, screenshot each page, and analyze for visual/layout bugs using Claude's vision.
disable-model-invocation: true
argument-hint: [page-names or "all"]
---

# /ui-test

Visual QA skill that uses Playwright to navigate the app (via Vite dev server + Tauri IPC mocks), take screenshots of each page, and analyze them with Claude's vision for layout and visual issues.

## Usage

```
/ui-test              # Test all pages
/ui-test library      # Test specific page(s)
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

### Step 2: Ensure Vite dev server is running

Check if port 1420 is serving:

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:1420
```

If it returns 000 or an error, start the dev server:

```bash
cd main && npm run dev &
```

Wait for it to be ready (poll every 2 seconds, up to 30 seconds):

```bash
for i in $(seq 1 15); do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:1420 | grep -q "200"; then
    echo "Dev server ready"
    break
  fi
  sleep 2
done
```

### Step 3: Run Playwright tests

Run the screenshot test. This uses Tauri IPC mocks (injected via `page.addInitScript()`) so all pages render with realistic data.

To test all pages:

```bash
cd main && npx playwright test e2e/ui-screenshots.spec.ts
```

Screenshots are saved to `test-results/screenshots/`:
- `library.png`
- `statistics.png`
- `playlists.png`
- `profiles.png`
- `devices.png`
- `settings.png`

If only specific pages were requested, note which screenshots to analyze.

### Step 4: Analyze Screenshots

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

### Step 5: Report

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

## How the mocks work

The test injects `main/e2e/tauri-mocks.ts` via `page.addInitScript()` before navigating to the app. This sets up `window.__TAURI_INTERNALS__` with a mock `invoke()` handler that returns realistic data for all Tauri commands called during page load (library tree, playlists, settings, devices, etc.).

This is entirely external to the app — no build pipeline changes, no risk of leaking into production. Pages render with populated data instead of error/empty states.

## Limitations

- Cannot test dynamic interactions (drag-and-drop, complex form flows) — only static page state
- Cannot test audio playback visualization (requires audio playing)
- Mock data is static — does not reflect the user's actual library
- Cannot test real Tauri-specific features (file dialogs, system tray, etc.)
