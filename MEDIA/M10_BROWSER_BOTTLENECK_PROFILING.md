# ALCHUL — M10 Browser Rendering Bottleneck Investigation

**Date:** 2026-11-18  
**Branch:** `batch10-original-gltf-pbr-pilot-20261118` (draft PR #3).  
**Status:** Diagnostic tests committed; **do not promote this branch or modify the published main site based on isolated RAF samples.**

## Current engineering evidence

1. The original M2 station GLB and 28 original M6 maps passed native import/hash gates. The unapproved GLB and UV material test remain a separate Godot scene, not literal archaeological reconstruction.
2. The authored procedural runtime reduced 3,556 eligible opaque static nodes to 102 groups with full transform/triangle conservation. Ten actual native visual A/B views passed the previous image-diff threshold, and mean native RenderingServer draw calls fell from about 8,454 to about 580 per reviewed view.
3. The independent *Web* candidate passes Chromium page/canvas/WebGL2 loading, but p95 `requestAnimationFrame` scheduling in GitHub's SwiftShader was still measured up to **1,749.9 ms** against a **250 ms** software-renderer budget. Native draw-call reductions did **not** establish that the web budget was achieved. These samples are neither desktop GPU FPS nor mobile-device evidence.

## Three competing performance hypotheses

| Hypothesis | Test change | Expected discriminating signal | Caveats |
| --- | --- | --- | --- |
| H1: Shadow cost is dominant in SwiftShader | `?alchul_perf=no_shadows` | Meaningfully lower p95 RAF than `reference` | Shadow fidelity changes; only a diagnostic |
| H2: M6 per-pixel 3D noise shader is dominant | `?alchul_perf=simple_m6` | Meaningfully lower p95 RAF at otherwise identical geometry | Flat colors are not release-ready |
| H3: M8 animated river shader is dominant | `?alchul_perf=static_water` | Meaningfully lower p95 RAF at otherwise identical geometry | Removes water variation and is not release-ready |
| Combined graphics cost | `?alchul_perf=all_light` | Large improvement implies several interacting costs | Does not identify the unique cause without isolated runs |
| Control | `?alchul_perf=reference` | Full visuals retained, same scene/build/browser settings | Software timing varies across runs and hosts |

**Mechanism:** Godot browser-only code reads a whitelisted `alchul_perf` URL parameter through JavaScriptBridge and reports the exact applied mode as `window.alchulM10ActiveProfile`. No data leaves the browser and no runtime source assets are fetched from remote hosts. Without a recognized parameter, full visuals remain the default. On native Godot runs, `reference` is always used.

**Reproduction:** [GitHub profiling CI](https://github.com/SouthPaw302/Alchul/actions/workflows/alchul-m10-web-profiles.yml) compiles one Godot Web export and tests five modes with exactly the same Chromium viewport and SwiftShader arguments, saving `M8_BROWSER_METRICS.json` and a true browser screenshot for each. `godot/tests/summarize_m10_web_profiles.py` validates that the requested modes were actually applied, then reports the median/p95 RAF deltas and sample sizes. Normal M8 functional/Web preview tests and native engine captures still run independently.

**Next evidence gate:** Examine per-mode metrics for a high-signal bottleneck. If several modes are close or timing noisy, instrument warmup/CPU and repeat controlled samples; do not lower the project performance threshold or claim production success. Convert an identified hotspot into a full-quality optimized shader or adjusted lighting technique, rerun ten true Godot views and Web browser measurements, and keep PR #3 draft until explicit approval.

**Scientific context:** No approved changes to inhabitants, history or the nature of Alchul are proposed. The current architecture remains an explicitly provisional pre–Long Descent mature surface environment.
