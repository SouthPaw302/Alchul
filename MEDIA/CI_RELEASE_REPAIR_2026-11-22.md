# ALCHUL — Release CI repair: Web HTML validation and M11 native capture consolidation

**Date:** 2026-11-22  
**Scope:** GitHub Actions workflow orchestration and documentation only; no change to Chapter I, original source geometry, results, `CANON.md`, or biological approval.

## Observed failure evidence

- Standalone Web export completed the official Godot build and emitted `index.html`, `index.js`, `index.wasm`, and `index.pck` (approximately 66 MB aggregate). The November 21 run failed at `Validate generated website`: the script searched for exact-case `Alchul`. The application HTML uses the project title's `ALCHUL` capitalization. The independently successful GitHub Pages workflow already used case-insensitive `grep -qi alchul`.
- T07, T08–T09, and T10 screenshot workflows recorded immediate failed Actions runs with **zero created jobs**, and therefore did not provide any Godot screenshots or job logs. The exact GitHub-side validation rejection is not exposed by those runs; do not pretend to know a renderer error. These were not evidence that a GDScript capture actually failed.

## Implemented repairs

1. The standalone Web workflow now verifies the app title with `grep -qi 'alchul'`, matching the proven Pages workflow. HTML, JS, WASM, package presence and binary size checks remain.
2. The three zero-job capture workflow definitions are retired. The previously passing `.github/workflows/alchul-native-validation.yml` now has an independent `m11-native-captures` job, reusing the pinned Godot 4.7.2 SHA, installing an Xvfb software renderer, importing the native project, and invoking the actual T07, T08–T09 and T10 Godot capture scripts.
3. This job explicitly verifies seven nonempty PNG screenshots and three machine-readable source/scene manifests. Captures are archived in the `alchul-m11-t07-t10-native-engine-evidence` Actions artifact for 90 days, not as scientific or canon proof.
4. The T07, T08–T09 and T10 report pointers have been updated to the consolidated workflow.

## Acceptance checks

- Pull request must have a successful native `offline-contract` job, existing `godot-native-smoke` job and new `m11-native-captures` job.
- Verify the `m11-native-captures` artifact contains exactly 7 nonempty study PNGs and three manifests; opening and visually reviewing them is a separate release gate.
- The standalone Web export workflow only triggers on `main` (or manual dispatch). After merge, verify it reaches `ALCHUL BROWSER EXPORT TECHNICAL PASS` and publishes the build artifact.
- GitHub Pages deployment and live browser experience are separate checks; even passing CI does not certify a smooth browser game session or acceptable native GPU performance.
- The M11 H-A/H-B body plans, dimensions, gait, grasp and reproductive biology are provisional throughout.
