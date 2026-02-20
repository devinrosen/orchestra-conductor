---
name: open-items
description: List unchecked actions and GitHub issues. Use to quickly see available work.
disable-model-invocation: true
---

# /open-items

Scan `ACTIONS.md` and `issues/` for open items and present a concise summary.

## Instructions

1. Read `ACTIONS.md`
2. Run `./scripts/sync-issues.sh` to refresh `issues/`, then read all `.md` files in `issues/`
3. Extract:
   - **Actions (Orchestration)**: unchecked items (`- [ ]`) under `## Orchestration`
   - **Actions (Project)**: unchecked items (`- [ ]`) under `## Project`
   - **Issues**: title, number, and labels from each issue file
4. Present a concise table per group:

```
## GitHub Issues

| # | Title | Labels |
|---|-------|--------|
| 1 | Fix crash on startup | bug |
| ... | ... | ... |

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

5. At the end, show totals: `M orchestration actions, P project actions, Q issues`

Keep it brief — one-line summaries only, no full descriptions.
