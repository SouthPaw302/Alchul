# Alchul — Batch 04: Harvest processing precinct

**Recorded:** 2026-11-17  
**Status:** EXPLORATORY / NOT CANON / NOT RELEASED  
**Repo branch:** `feature/m1-river-3d-study`, draft [PR #1](https://github.com/SouthPaw302/Alchul/pull/1)  
**Careful usage:** This is a hypothetical biochemical processing precinct. It does not redefine any separately established canonical event called "The Harvest."

## 1 — Concepts

- 5 original full-resolution study masters (4 panoramas and 1 ten-panel storyboard source).
- 10 editorial crops of **one** storyboard, not ten independent image generations.
- Concept imagery evokes clay, living wood, roots, canals, settling chambers, drying galleries and wetland ecology. Visual plausibility is **not** archaeological evidence.
- [Drive: Batch 04 concepts, source storyboard, ten crops, concept ZIP](https://drive.google.com/drive/folders/1EyZHqp2rasRseymxp4IOkanopusmJdoa) — verified 16 entries.

## 2 — Reproducible actual 3D

- Standalone `ALC_M4_HARVEST_PRECINCT_v001.glb` (2,147,656 bytes).
- Trimesh parse: **21 geometry groups, 63,500 vertices, 92,990 triangles**.
- SHA-256: `cf34d146fe77bc283035b0fc7e4d97d0bb853d358f73168fe82d4c3bff7a898b`.
- Source: `build_harvest.py`; renders by `render_harvest.py`; reproducible pack by `package_batch.py`.
- The GLB has static symbolic fluid surfaces; no simulated hydrology or validated chemical processes.
- [Drive: original 3D, scripts, README, manifests, 3D ZIP](https://drive.google.com/drive/folders/1ZIeWO8kDYAIfp07QO-5nTy_Du6YXsDJn) — verified 8 entries.
- [Complete 3D package](https://drive.google.com/file/d/10ac8uCBTUmFj5fn_ZtJbNQhBDgp4JcfF/view).

## 3 — Render pass

- 10 separate offscreen VTK camera views of real mesh geometry, plus one contact sheet.
- Unlike the concept sheets, these **are** renders of the reproducible GLB, but are not cinematic finished assets.
- [Drive: ten 3D renders + contact sheet](https://drive.google.com/drive/folders/1Av9zLW3GkkCqkbD7nOz_Q9Qnb5o1AdWe) — verified 11 entries.

## 4 — Native Godot candidate

- New `godot/scripts/harvest_m4.gd` defines an autonomous no-network schematic Harvest scene with stone containment collars, wet terraces, permeable curing racks, vented clay forms, seep channels, wetlands, and plant growth.
- `godot/scripts/environment_m1.gd` now calls `_build_m4_harvest()`, which creates `M4HarvestPrecinct_Candidate`, instead of rendering the old placeholder Harvest geometry.
- The independent M4 Godot procedural model is **not a GLB import** and must not be described as the same mesh as the sandbox GLB.
- `godot/tests/smoke.gd` requires the M4 node in addition to M2 and M3, without weakening existing camera, worldbook or interpretation tests.
- Existing `godot/data/worldbook.json`, original four interpretive markers, user controls and live GitHub Pages deployment are unchanged.
- **Passed** [M4 native validation run #44029161811](https://github.com/SouthPaw302/Alchul/actions/runs/44029161811): both `offline-contract` and `godot-native-smoke` succeeded against commit `841675e9`. This validates script compilation, scene startup, M2/M3/M4 presence, observer and lens contracts; it does **not** validate graphical quality, navigation, frame rate, or browser deployment.

## 5 — Integrity checks

1. `ALC_M4_3D_PACK_v001.zip`: 17 members, CRC integrity passes.
2. `ALC_M4_CONCEPTS_10_v001.zip`: 15 members, CRC integrity passes.
3. Local GLB reloaded as a valid trimesh scene; SHA-256 and triangle counts verified.
4. Drive readback checked all three target folders: 16 / 8 / 11 entries.
5. Native Godot CI is a **technical smoke test**, not an audiovisual approval, performance benchmark, collision/navigation test or browser deployment.

## 6 — Gates before merging

1. **Anatomy:** adjust access for an actual nonhuman theropod-derived inhabitant, with turn radius and tail clearance.
2. **Ecology:** review Cretaceous plants and material provenance.
3. **Environment:** constrain channel slopes, drainage, sediment and return flows; test storm loads.
4. **Chemistry:** retain functional abstraction until proposed biology/chemistry undergoes independent scientific review; no specific actionable fermentations asserted.
5. **Visuals:** replace primitives with high-quality surface meshes/PBR, consistent scale, light, believable erosion and vegetation.
6. **Engine:** optimize draw calls, collision meshes and browser frame rate, test player movement and camera from inside the M4 precinct.
7. **Approval:** do not merge the draft PR or alter canon/live Pages until reviewed.

## 7 — Next production scope

Batch 05 candidate: connective wetland, vegetation and ecological transitions among the river-reading station (M2), protected nursery (M3), and Harvest precinct (M4). Prioritize scale, ecological credibility and seamless player navigation over another isolated showcase.
