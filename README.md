# Orchestra Conductor

Orchestration workspace for coordinating parallel agent development on [Orchestra](https://github.com/devinrosen/orchestra), a desktop music library manager and device sync tool built with Tauri v2 (Rust + Svelte 5).

## Structure

```
main/                  # Primary repository (Tauri v2 app)
feat-<slug>/           # Git worktrees for feature branches
fix-<slug>/            # Git worktrees for fix branches
postmortems/           # Session postmortems
ACTIONS.md             # Backlog of extracted actions from postmortems
```

## Getting Started

The `main/` directory (the Orchestra app repo) is not included in this repository. After cloning, set it up:

```bash
git clone git@github.com:devinrosen/orchestra.git main
npm install --prefix main
```

Or if using Claude Code, run `/init`.

## About Orchestra

Orchestra is a desktop app for managing music libraries and syncing them to external devices. Key capabilities:

- **Library management** — Scan, browse (by artist/album/genre/folder), search, and view statistics across a local music collection
- **Metadata editing** — View and edit track/album metadata with write-back to audio files
- **Device sync** — Two-way sync with diff preview, conflict resolution, and cancellation support
- **Playback** — Play tracks and albums with queue management, equalizer, and real-time visualizations
- **Duplicate detection** — Find and remove duplicate tracks by content hash

Built with Rust (SQLite, BLAKE3 hashing, atomic file operations) on the backend and Svelte 5 on the frontend.

## Agent Workflow

This workspace is designed for agent teams using [Claude Code](https://claude.ai/code). The team lead runs from this directory and coordinates teammates working in isolated git worktrees.

1. **Plan** — Read `main/docs/FEATURES.md`, create worktrees, spawn planners to write `PLAN.md` per feature
2. **Implement** — Spawn implementers that follow approved plans, run tests, and commit
3. **Merge** — Merge completed features, clean up worktrees, update feature tracking

See `CLAUDE.md` for the full workflow reference.

## Development

```bash
# Run the app (from main/)
npm run tauri dev

# Frontend only
npm run dev

# Rust tests (from main/src-tauri/)
cargo test

# Type checking
npm run check
```
