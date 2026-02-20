# Specification Workflow

When the specification is excellent, the implementation is excellent. When feature implementation failed, it was because of poor specification.

## The Problem

The current pipeline is:

```
GitHub issue (1-2 sentences) → Planner (researches + designs) → Implementer (builds)
```

The planner is doing two jobs simultaneously: **figuring out what to build** (specification) and **figuring out how to build it** (technical plan). When the "what" is vague, the "how" suffers. Concrete examples from past sessions:

- **Track ratings**: The issue said "1-5 star rating." Planner missed 3 locations needing the `rating` field (playlist_repo.rs, scanner/metadata.rs) because the spec never said "adding a field to Track touches every file that constructs a Track." Planner also put `<button>` stars inside an existing `<button>` row — the spec never described where ratings appear relative to existing UI.
- **Multi-library**: Planner missed `Favorites.svelte` as a location that reads `libraryRoot`. The spec never enumerated which pages/stores depend on the single-root assumption.
- **PlaylistTrack struct**: Plan defined a type that was never consumed. The spec never clarified whether playlists work with full Track objects or just IDs.
- **state_referenced_locally cleanup**: Planner spent 110 lines deliberating and landed on a broken approach. The spec didn't clarify the correct Svelte 5 pattern upfront.

Meanwhile, the sessions that went best had strong implicit specs:
- **Duplicate detection**: Plan had exact code snippets + 14 test specifications → first-try implementation.
- **UI skins**: Comprehensive replacement table → clean implementation.
- **Import music**: Existing infrastructure was sufficient, scope was obvious → no surprises.

## The Spec Document (SPEC.md)

Written per feature, stored in the worktree. Has these sections:

### 1. Behavior

What the user sees and does, written as concrete scenarios:

```
- User clicks the star icon on a track row → rating cycles 0→1→2→3→4→5→0
- Stars are displayed in the track row, between duration and format columns
- Rating persists across app restarts (stored in DB)
- Rating of 0 means "unrated" (no stars shown)
```

### 2. Data Model Changes

Exact fields added/removed, with an impact grep:

```
Add `rating INTEGER NOT NULL DEFAULT 0` to tracks table.

Impact (files that construct/query Track):
- library_repo.rs: track_from_row (positional index update), 6 SELECT statements
- playlist_repo.rs: inline Track mapping (also uses positional indices)
- favorite_repo.rs: uses track_from_row (inherits fix)
- scanner/metadata.rs: Track construction in extract_metadata
- models/track.rs: struct definition
- api/types.ts: TypeScript Track type
```

### 3. UI Description

Where new elements appear relative to existing ones:

```
TrackRow.svelte: Add a star rating widget AFTER the duration column.
The widget is a <span> (NOT a <button>) since TrackRow is already inside
a clickable row. Click is handled via onclick on the span, not a nested button.
```

### 4. Scope Boundaries

What this feature explicitly does NOT do:

```
- Does NOT add rating to album or artist level (track-only)
- Does NOT add a "sort by rating" option (future feature)
- Does NOT sync ratings to devices
```

### 5. Acceptance Criteria

Checkable statements the implementer must satisfy:

```
- [ ] `cargo test` passes with ≥2 new tests for rating CRUD
- [ ] `npm run check` passes with 0 warnings
- [ ] Rating persists after app restart (DB round-trip)
- [ ] Unrated tracks show no stars (not zero stars)
```

## How It Fits in the Workflow

```
/implement-features
  Phase 1: Setup (feature selection, worktree creation)
  Phase 1.5: Fast-track check

  Phase 2: Specification (collaborative, lead + user)
    For each non-fast-track feature:
    1. Lead reads the codebase to build an impact analysis:
       - Which files/modules are affected?
       - What data model changes are needed?
       - What existing patterns apply?
    2. Lead drafts SPEC.md and presents it to the user
    3. User refines: corrects behavior, adjusts scope, adds edge cases
    4. Lead updates SPEC.md, confirms with user
    5. SPEC.md is written to the worktree

  Phase 3: Planning (subagents receive SPEC.md)
    - Planner prompt includes: "Read SPEC.md for the feature specification.
      Your job is to produce a TECHNICAL PLAN — the spec already defines
      what to build. Focus on how: file changes, code structure, test stubs."
    - Planner no longer decides what the feature does — that's settled.

  Phase 4: Implementation
  Phase 5: Wrap-up
```

## Design Decisions

**Why the lead writes the spec, not a subagent**: The spec requires back-and-forth with the user. Subagents can't have a conversation — they run and return. The lead can use `AskUserQuestion` to clarify ambiguities interactively.

**Why the lead does the impact analysis, not the planner**: The lead can grep the codebase and present findings to the user before a subagent is ever spawned. This catches the "missed playlist_repo.rs" class of bugs at the cheapest possible moment.

**Why scope boundaries matter**: Half the postmortem actions trace back to planners over-specifying (PlaylistTrack struct) or under-specifying (missing files). Explicit "does NOT" lines prevent both.

**Fast-track items skip this phase**: Small cleanup work doesn't need a spec. The fast-track criteria stay the same.

## Cost

This adds one interactive round-trip per feature before planning starts. For a session with 2 features, that's maybe 5-10 minutes of conversation. Given that bad specs caused multi-hour debugging cycles (state_referenced_locally deliberation, track ratings restructuring, multi-library missed locations), the ROI is clear.
