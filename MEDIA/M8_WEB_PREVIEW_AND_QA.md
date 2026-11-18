# ALCHUL — Batch 08: Browser-Ready Riverbank Candidate

**Production date:** November 18, 2026  
**Status:** DEVELOPMENT CANDIDATE — not yet published  
**Repository:** SouthPaw302/Alchul  
**Public baseline:** https://southpaw302.github.io/Alchul/  
**Development:** https://github.com/SouthPaw302/Alchul/pull/1

## 1. Target and release policy

**The GitHub Pages URL is the target delivery platform, not an external prototype.** Current public `main` is intentionally unchanged while the M8 candidate is compiled and checked in a real browser. GitHub Pages `.github/workflows/alchul-pages.yml` already publishes fresh Web builds from `main` when changes to `godot/**` are merged. It must not be described as having M8 until the deployment run for the release commit has passed.

## 2. Scene development

- `godot/scripts/environment_m8.gd` adds a water material with time-dependent surface variation, terrain-following vegetated river-edge strips and 220 instanced wetland plants.
- It reuses `WorkingFloodplain` to build a matching static concave terrain collider, creating first-class physics picking for the otherwise height-following spectator.
- The named node is `M1RiverEnvironment_Candidate/M8RiverbankWebCandidate`, added without changing the worldbook, markers, interpretive lenses or old assets.
- **Not a claim of finished navigation:** the visitor remains a terrain-height observer and there are no collider meshes for every bridge and canopy; proper inhabitant anatomy clearance and collision must be engineered later.
- **Not a physical hydrology simulation:** the river is shader-animated appearance, not dynamic fluid dynamics.

## 3. Native regression gate

The existing `godot/tests/smoke.gd` now checks M2–M8, plus M8 asset presence, water shader, riverbank, and real terrain raycast using Godot's PhysicsDirectSpaceState3D. A good run must preserve the existing controls, worldbook and three interpretation lenses.

## 4. Ten native Godot views

The native capture workflow `alchul-m7-visual.yml` includes Batch 08 changes. Screenshots are produced by Godot itself under Xvfb/OpenGL using ten stable cameras, not by AI image generation or a detached 3D renderer.

The images are **technical-review evidence** and not cinematic art. Compare the first frame to Batch 07 and check that the terrain remains visible, the water geometry is not hidden, and the bank strips do not occlude settlement markers.

## 5. Real Web export and browser test

`.github/workflows/alchul-m8-web-preview.yml` compiles a fresh **single-threaded Godot 4.7.2 Web** build on the PR branch via `godot/tools/build_web.sh`. It checks HTML, JS, PCK and WASM, launches a local HTTP server, then uses Playwright Chromium configured with software WebGL2 to visit and screenshot the game. A 120-frame requestAnimationFrame timing sample records approximate browser scheduling latency (median/p95) and captures JS errors.

**RAFrame timings are not true gameplay FPS;** this is a limited CI software-GL smoke test. Even if it passes, mobile device, native GPU, collision/navigation and aesthetic review remain open.

Artifacts: `alchul-m8-godot-web-preview`, `alchul-m8-chromium-browser-review`. This test deliberately does NOT deploy to GitHub Pages; the known working main URL stays preserved until candidate acceptance.

## 6. Drive and reproducibility

- Ten Godot-native screenshots, a labeled contact sheet, JSON metrics and screenshot artifact ZIP will be archived as Batch 08 evidence.
- Full browser export artifact and rendered browser screenshot are stored separately.
- Checksum manifests and the exact GitHub commit/run IDs are included so the tested build is identifiable.
- Keep M6/M7 original texture GLB pack archived on Drive; do not claim the original 768px sources are in the tested branch. M8 continues to use the M7 96px procedurally generated PBR fallback while the archived originals await a verified binary import and full browser budget.
- Asset packs are still provisional; no image depicting Alchul's true nature or canonical civilization is asserted.

## 7. Release gate

Accept only when:
1. Native engine import/smoke succeeds on the exact candidate revision.
2. Ten real Godot scene captures succeed and are inspected.
3. Web compilation and browser smoke succeed.
4. Bundle size, screen output, at least one actual navigation check, and major rendering regressions have been reviewed.
5. The change is deliberately promoted from PR to main and the GitHub Pages deployment result is confirmed.

Until then, link users to the **existing** GitHub Pages game as the baseline, and the M8 GitHub Actions artifact as the candidate, *not* to a non-existent preview URL.
