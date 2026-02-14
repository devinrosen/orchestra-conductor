# Postmortem: Planner — Equalizer

## Task

Research the codebase and write PLAN.md for the Equalizer feature: a 10-band graphic EQ using Web Audio API BiquadFilterNode nodes, with presets and manual per-band adjustment, sharing panel space with the visualizer.

## What Went Well

- The codebase is well-structured and predictable. The player store, visualizer panel, and audio graph were exactly where expected.
- The existing audio graph in `initAudioContext()` is simple and clean — inserting filter nodes between source and analyser is straightforward.
- The settings persistence system (key-value `setSetting`/`getSetting`) is already in place and can be reused for EQ state without any Rust changes.
- The visualizer panel and queue panel provide clear UI patterns to follow for the EQ panel component.

## What Went Wrong

- Nothing significant. The feature description accurately described the existing AnalyserNode pipeline.

## Codebase Surprises

- The `AudioContext` is lazily initialized only when the visualizer is first toggled, not when playback starts. This means the EQ will also need to trigger context initialization if the user opens EQ before the visualizer.
- The `Uint8Array` in `VisualizerPanel.svelte` uses an explicit `as Uint8Array<ArrayBuffer>` cast (line 100), confirming strict TypeScript generic requirements for typed arrays.
- No existing audio settings on the Settings page — the settings page only has theme, sync mode, and hash mode. The EQ doesn't need a settings page entry since it has its own panel.

## Suggestions

- The plan format requirements are comprehensive and clear. No changes needed.
- The feature description was accurate about the AnalyserNode pipeline being "already wired up" — this made research faster.
