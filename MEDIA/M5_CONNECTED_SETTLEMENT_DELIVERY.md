# Alchul | Batch 05 — Connected River Settlement

**Date:** 2026-11-17  
**Classification:** EXPERIMENTAL / NONCANONICAL / NOT PUBLISHED  
**Development branch:** `feature/m1-river-3d-study`, draft [PR #1](https://github.com/SouthPaw302/Alchul/pull/1)

## 1. Objective

Join the Batch 02 river-reading station near (8,-3), Batch 03 protected nursery near (-16,13), and Batch 04 Harvest precinct near (-8,-2) in a single interpretable riverplain. The route geometry seeks to express a nonhuman ecology-led civilization through living-root bracing, braided wetland paths, two causeways, silt margins, water and forest buffers. Do not assume the depicted routes already fit any actual theropod-derived resident.

## 2. Original mesh and ten genuine 3D renders

- True standalone procedural mesh: `ALC_M5_CONNECTIVE_SETTLEMENT_v001.glb` (**1,973,640 bytes**), built with Python + trimesh.
- **66,118 vertices, 77,540 triangles, 17 material/geometry groups.**
- Heightfield approximately matches `godot/scripts/world.gd` terrain equation.
- Ten unique **VTK offscreen camera renders of the actual exported GLB** (1280×720 PNG), plus one labeled contact sheet.
- The three key sites in this **standalone model** are symbolic markers, **not imported Batch 02–04 meshes**. The native Godot M5 layer is independently generated geometry; do not call it a GLB import.
- `ASSET_MANIFEST.json` records material groups, mesh counts, geometry SHA-256; `PACKAGE_MANIFEST.json` records source and render checksums.
- Local validation: trimesh GLB reload, 10 PNG dimensions, checked 18-entry ZIP CRC.

## 3. Drive archive (upload + readback required)

- [Original GLB, generator, render script, packaging source, README, manifests and full 3D ZIP](https://drive.google.com/drive/folders/1oz5SUQr3Su2-2_6L2i9UCW5D10rCjnVy)
- [Ten actual rendered 3D camera views and full contact sheet](https://drive.google.com/drive/folders/1YRTEhjvdR-AphQK4-xObnicoBHB1Aujs)
- [Complete versioned 3D package](https://drive.google.com/file/d/1-sYjc-5nDWzjaglNMXWqTYDvzY9IcPLG/view)
- [Standalone GLB](https://drive.google.com/file/d/1EmnbnYpksorU6Ez_uUhmldiVjx_G4zZM/view)

**This batch emphasizes ten genuine geometry renders rather than another generated concept-art storyboard.** No new independent painting batch is being misrepresented as finished geometry.

## 4. Godot branch integration

- New `godot/scripts/connective_m5.gd`, a noncanonical, no-network, additive candidate.
- Terrain-following triangle strips model routes near established interpretive markers and a pair of raised causeways; stem vegetation uses MultiMesh to moderate draw calls.
- `godot/scripts/environment_m1.gd` creates `M5SettlementConnectors_Candidate` alongside the M2 station, M3 nursery, M4 Harvest candidate and prior baseline.
- `godot/tests/smoke.gd` now asserts M2, M3, M4 **and M5** nodes exist. Other camera, local worldbook and lens tests remain intact.
- [CI run #44029645552](https://github.com/SouthPaw302/Alchul/actions/runs/44029645552) **passed both `offline-contract` and `godot-native-smoke`** for the M5 code revision (commit `3b002809`).
- No change to main, no publish and no canon change.

## 5. Acceptance gates before production promotion

1. **Spatial verification:** align procedural transforms with all three native site centerlines, evaluate intersections and floating structures via actual Godot screenshots.
2. **Species accessibility:** quantify body width, turning envelope, tail swing, limb load and bridge clearance based on future anatomical model. No human-path design assumptions.
3. **Geology and hydraulics:** calibrate flood levels, sediment deposition, channel gradients and rock weathering. The present water is static geometry, not physically simulated water.
4. **Ecology:** verify plausible Late Cretaceous flora and no anachronistic details.
5. **Visual fidelity:** add detailed 3D meshes, PBR texture maps, volumetric atmosphere, undergrowth and site-specific differences before calling it cinematic.
6. **Performance:** measure Godot draw calls, frame time, collision, WebGL 2 export and mobile GPU load with M2/M3/M4/M5 enabled together. MultiMesh use is a mitigation, not an FPS guarantee.
7. **Regression:** maintain existing observer, controls, interpretation views and worldbook; keep a rollback path.
8. **Release:** draft PR until a visually inspected browser build and explicit acceptance.

## 6. Next milestone

Batch 06: **Materials, vegetation and physically convincing terrain transitions**, replacing simplistic geometry and color-only shaders where feasible, starting with one consistent riverbank detail zone in the playable Godot scene rather than ten more disconnected showcases.
