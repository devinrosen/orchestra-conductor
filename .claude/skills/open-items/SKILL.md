---
name: open-items
description: List open features, unchecked actions, and GitHub issues. Use to quickly see available work.
disable-model-invocation: true
---

# /open-items

Scan `main/docs/FEATURES.md`, `ACTIONS.md`, and `issues/` for open items and present a concise summary.

## Instructions

1. Read `main/docs/FEATURES.md`
2. Read `ACTIONS.md`
3. Run `./scripts/sync-issues.sh` to refresh `issues/`, then read all `.md` files in `issues/`
4. Extract:
   - **Features**: all entries with status `[ ]` (not started), grouped by section
   - **Actions (Orchestration)**: unchecked items (`- [ ]`) under `## Orchestration`
   - **Actions (Project)**: unchecked items (`- [ ]`) under `## Project`
   - **Issues**: title, number, and labels from each issue file
5. Present a concise table per group:

```
## Open Features

### Library
| Feature | Summary |
|---------|---------|
| Auto-fetch album art | Download art from MusicBrainz for tracks missing art |
| ... | ... |

### Playback
| Feature | Summary |
| ... | ... |

## Open Actions

### Orchestration
| Action | Category |
|--------|----------|
| ... | ... |

### Project
| Action | Category |
|--------|----------|
| ... | ... |

## GitHub Issues

| # | Title | Labels |
|---|-------|--------|
| 1 | Fix crash on startup | bug |
| ... | ... | ... |
```

6. At the end, show totals: `N features open, M orchestration actions, P project actions, Q issues`

Keep it brief — one-line summaries only, no full descriptions.
