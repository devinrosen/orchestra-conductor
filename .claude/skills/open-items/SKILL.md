---
name: open-items
description: List open features from FEATURES.md and unchecked actions from ACTIONS.md. Use to quickly see available work.
disable-model-invocation: true
---

# /open-items

Scan `main/docs/FEATURES.md` and `ACTIONS.md` for open items and present a concise summary.

## Instructions

1. Read `main/docs/FEATURES.md`
2. Read `ACTIONS.md`
3. Extract:
   - **Features**: all entries with status `[ ]` (not started), grouped by section
   - **Actions (Orchestration)**: unchecked items (`- [ ]`) under `## Orchestration`
   - **Actions (Project)**: unchecked items (`- [ ]`) under `## Project`
4. Present a concise table per group:

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
```

5. At the end, show totals: `N features open, M orchestration actions, P project actions`

Keep it brief — one-line summaries only, no full descriptions.
