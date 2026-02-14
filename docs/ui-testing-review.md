# UI Testing Skill Review

## Background

ACTIONS.md item: "Consider adding a UI testing skill or agent" — Visual/interaction bugs (canvas overflow blocking player controls, button icon confusion) can only be caught through manual testing.

An initial `/ui-test` skill was created at `.claude/skills/ui-test/SKILL.md` using macOS `screencapture` + CGEvent coordinate-based clicking to navigate the Tauri app's sidebar and screenshot each page.

## What Went Wrong (2026-02-14 session)

### CGEvent clicks don't reach WKWebView
Tauri on macOS uses WKWebView (Apple's WebKit). Low-level `CGEvent` mouse posts go through the HID layer but WKWebView doesn't process them like native Cocoa controls. Clicks technically "land" (screenshots changed when clicking the artist list) but sidebar navigation buttons in the WebView ignored them.

### AppleScript UI scripting needs Accessibility permissions
`osascript` via System Events requires assistive access, which isn't granted to the terminal process. This blocked the AppleScript-based fallback approach.

### Coordinate-based clicking is fundamentally fragile
Even if it worked, it would break whenever the window moves, resizes, or the sidebar layout changes. The window moved from 1200x800 at (156,71) to 756x949 at (756,33) during the session, invalidating all pre-calculated coordinates.

### Playwright available but browsers not installed
`npx playwright` existed but the Chromium binary was missing. Installing browsers is a one-time step but adds friction.

## Key Insight

The skill was designed around "simulate mouse clicks on a native window" — one of the hardest things to do reliably on macOS without accessibility permissions. That was a bad foundation for an automated tool.

## Options Considered

### Option 1: Playwright against Vite dev server (localhost:1420)
- **How**: Install Playwright browsers once, navigate the Vite dev server as a regular web page
- **Pros**: Playwright clicks DOM elements by selector (not coordinates), very reliable, headless
- **Cons**: `invoke()` calls to Tauri backend fail outside the Tauri runtime — pages show error/empty states instead of real data. Good for layout/styling testing, bad for data-dependent views.

### Option 2: Tauri WebDriver via tauri-driver (RECOMMENDED)
- **How**: Use `tauri-driver` which implements the WebDriver protocol for Tauri apps. Connect via Playwright or WebDriverIO to the *actual running Tauri app* including the Rust backend.
- **Pros**: Full E2E testing with real data. Officially supported by Tauri. Click by CSS selector, not coordinates. Can test real user flows (scan library, navigate, play tracks).
- **Cons**: Requires `tauri-driver` binary (installable via cargo). Slightly more setup than pure Playwright.
- **Tauri docs**: https://v2.tauri.app/develop/tests/webdriver/

### Option 3: Screenshot-only (no automated navigation)
- **How**: Just `screencapture -l<windowID>` whatever page the user has open. User navigates manually, skill analyzes what it sees.
- **Pros**: Zero setup, works today. Still catches visual bugs via Claude's vision.
- **Cons**: No automated navigation. Limited to whatever page is currently showing.

### Option 4: Hybrid (Playwright + manual screencapture)
- **How**: Playwright for structural/styling checks (no Tauri runtime needed), `screencapture` for analyzing the real app when user has it open.
- **Pros**: Best of both worlds.
- **Cons**: Two modes to maintain, more complexity.

## Decision (updated 2026-02-14)

**Original decision**: Option 2 (tauri-driver).

**Problem**: `tauri-driver` does not support macOS. It relies on platform-specific WebDriver backends — Microsoft Edge WebDriver on Windows and `WebKitGTFDriver` (for WebKitGTK) on Linux. macOS uses WKWebView, which has no WebDriver implementation. The Tauri docs only document Windows and Linux setup. Attempting to use tauri-driver on macOS fails with no available browser backend.

**Revised decision**: **Playwright against Vite dev server + Tauri IPC mocking** (enhanced Option 1).

The key insight is that Option 1's main weakness (empty/error states from failed `invoke()` calls) can be eliminated by mocking `window.__TAURI_INTERNALS__` via `page.addInitScript()`. This injects a mock IPC handler that returns realistic data for all commands, making pages render with full content.

This provides:
- Reliable DOM-based navigation (CSS selectors via Playwright)
- Populated pages with realistic mock data (not empty/error states)
- Headless operation, no macOS accessibility permissions needed
- No dependency on tauri-driver or platform-specific WebDriver backends
- Mock layer is entirely external to the app (no build pipeline changes)

## Implementation

- Playwright config: `main/playwright.config.ts`
- Tauri IPC mocks: `main/e2e/tauri-mocks.ts`
- Screenshot test: `main/e2e/ui-screenshots.spec.ts`
- Skill: `.claude/skills/ui-test/SKILL.md`
- Run: `cd main && npx playwright test e2e/ui-screenshots.spec.ts`
