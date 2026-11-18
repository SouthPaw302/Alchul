# ALCHUL — Batch 10 Original Source Asset Pilot

**Date:** 2026-11-18  
**Branch:** `batch10-original-gltf-pbr-pilot-20261118` (stacked on M9 branch)  
**Status:** Source import and automated test **implemented**, engine CI and screenshot acceptance **pending**. No live site, canonical history, or default Godot main scene changed.

## 1. Actual source files now in the Godot repository branch

| Artifact | Source | Exact-byte verification | Godot use |
|---|---|---|---|
| M2 River-Reading Station GLB | [Drive original](https://drive.google.com/file/d/1f-iQjSM6P7m4StfFaECLh0Kb6Q_NacPN/view) | SHA-256 `4e1a48850ea6d3e2b50e2a923ac07d11f637b9629090e7bcda5f3299ab5822c3` | `godot/assets/m2/` isolated diagnostic scene `m10_import_pilot.tscn` |
| M6 all 28 original PNG maps | [Drive texture masters](https://drive.google.com/drive/folders/1BfJvpQr4Ml2Lhp56spU6BEUhYA-Gp7xw) | Per-file SHA-256, byte counts and byte-for-byte ZIP member equality **independently verified** | `godot/assets/m6/textures/`, 7 families x albedo, normal, roughness, height |
| M6 original archive manifest | [Drive manifest](https://drive.google.com/file/d/1RJw_UrIKTQwdPdEjNqlBHFTNY7Cs7Q_f/view) | Copied unchanged from archive | `godot/data/m10_m6_archive_manifest.json` used in native import smoke |

The M6 complete production archive separately passed CRC and hash checks. Its original UV-ready GLB (13,728,468 bytes) was also directly downloaded and found identical to its archive member and source hash. **It was not added to the GitHub branch:** the 18MB encoded blob upload failed. No claim is made that the source M6 GLB runs natively in this pilot.

## 2. What is implemented

- Real M2 imported as `PackedScene` in `scenes/m10_import_pilot.tscn`; vertex color attribute `COLOR_0` is preserved explicitly with `vertex_color_use_as_albedo`.
- The genuine M6 maps are consumed by the existing `materials_m7.gd` in the original world and in an isolated 7-material diagnostic. The loader is now allowed to run without applying to existing world nodes, avoiding unwanted modifications to M1–M8 study geometry in the pilot.
- Seven native, UV-ready material sample meshes show authentic M6 material data; the original M2 model has **no** UVs and is **not falsely described as PBR-mapped**. Height PNGs preserved for eventual normal/parallax study, not currently used in the PBR loader.
- `tests/m10_import_smoke.gd` requires M2 original hash, **all 28 original 768px texture hashes and dimensions**, imported original M2 mesh nodes, 7 original native PBR families, zero fallback maps.
- `tests/render_m10.gd` defines ten actual native engine camera angles and stores 960x540 screenshots and capture-latency metrics. The new `.github/workflows/alchul-m10-visual.yml` packages visual evidence.
- The existing foundation native validation workflow has been extended to run M10 source tests. The existing Web candidate preview workflow remains unchanged and will test PR web export.
- Source provenance appended to `godot/PROVENANCE.md`, isolated usage documented in `godot/README.md`.

## 3. Scientific and engine limits

- M2 original = 19 source meshes, 93,114 triangles; world footprint roughly 84m across; **0 UV-bearing meshes**.
- M6 source original = 7 meshes, 141,176 triangles and UVs on all seven, **not runtime imported**.
- This is a **candidate**, not a newly established ancient city layout. No historical absolute date is established and no morphology or Alchul nature is represented.
- Native source code and tests are committed to the candidate branch, but source creation does **not** establish actual screenshot quality, import success on all CI setups, browser framerate, game collision or accessibility.
- The initial station source is not swapped into the published Godot main scene, preventing accidental overlap with the procedural station and site markers.
- Prior M8 spike-inducing beam batching remains rejected. No GLB or texture optimization has yet been approved.

## 4. Acceptance gates

1. **Native import:** CI `alchul-native-validation` returns green, including M10 exact SHA checks and existing main world smoke.
2. **Real camera review:** CI `alchul-m10-visual` produces all ten actual native screenshots. Inspect material visibility, model position, roof continuity, winding/normals, vertex colors and swatches; archive approved evidence separately from rejected views.
3. **Web preview:** existing M8 preview workflow runs on the M10 PR. Record WASM/PCK growth, load success, canvas screenshot and actual measured software-GL frame latency before approving.
4. **Optimization:** choose station UV or triplanar authored mapping; do not mutate source original. Consider M6 original geometry import as explicitly derived optimized GLB, with exact provenance and geometry/texture correspondence tests.
5. **Production:** only after reviews, merge M9 then M10 in order and deliberately publish. No approval/release is implied by creating this PR.

**Reference:** [M9 verification](M9_SOURCE_INTEGRITY_CHECK.md), [M9 registry](ASSET_INTEGRATION_REGISTER.json), [M9–M12 roadmap](ROADMAP_M9_M12_ASSETS_AND_INHABITANTS.md).
