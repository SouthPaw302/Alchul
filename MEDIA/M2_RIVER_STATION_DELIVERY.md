# Alchul production | Batch 02 — River-reading Station

**Date:** 2026-11-17  
**Classification:** experimental, noncanonical, visual candidate  
**Source of truth:** Alchul Godot branch `feature/m1-river-3d-study`; `main` remains the currently published runtime.

## 1. Source concept images

Ten labeled editorial study crops from original generated 2×5 storyboard sheets. **Crops are not ten independently generated full-resolution concepts.** Six full-resolution uncropped storyboard variants are retained as source, along with a SHA-256 manifest and ZIP.

[Batch 02 concept archive (Drive)](https://drive.google.com/drive/folders/1GZAArdMIeeqK2O519roTbL0IcIZnG0XF)

Subjects: aerial overview; water intake; root/wood undercroft; sediment wedges; dry-season terraces; storm-water operation; sheltered interior; overhead system; root-stone load transfer; dawn view.

## 2. Actual 3D source

[Batch 02 standalone model and original Python source (Drive)](https://drive.google.com/drive/folders/1Ot6lzbnoBCNAOVHORT5XAqWCBvWbzUm5)  
[Complete reproducible 3D pack ZIP (Drive)](https://drive.google.com/file/d/10KEnjEoRbPYqHeMd-lLh7vWHDA74RuRD/view)

The **2.36 MB GLB** was modeled procedurally in the sandbox and validated with `trimesh`; approximately **78,493 vertices**, **93,114 triangles**, **19 grouped geometries**. Source `build_station.py`, `render_station.py`, and manifest are preserved. These numbers are for the *standalone GLB*, not for the separate Godot-native study.

The archive ZIP has 18 entries and passed Python's ZIP CRC test. It includes ten 3D render PNGs and one contact sheet.

## 3. Actual 3D camera renders

[Ten true 3D camera renders and a contact sheet (Drive)](https://drive.google.com/drive/folders/1c5CoobpsQlAdAutR72GCOO4hVXekB8KS)

The ten renders are direct views of the GLB. Unlike concept paintings, they expose the mesh's real shape and geometry gaps. Use them for critique, not as photorealistic marketing images.

## 4. Native Godot integration

The branch has:
- `godot/scripts/station_m2.gd`, a modular station assembled from stone-lipped flow lanes, timber ribs, buttresses, movable calibration shims, sensor stands and vegetation.
- `godot/scripts/environment_m1.gd`, now instantiates the Batch 02 station instead of the former simpler river platform.
- Unmodified `worldbook.json`, interpretive lenses and observer controls.

The in-engine model is currently **independent** of the sandbox GLB rather than an import of exactly the same mesh. Treat the pair as two alternative technical hypotheses.

[Draft pull request #1](https://github.com/SouthPaw302/Alchul/pull/1)  
[Most recent native-validation workflow (success)](https://github.com/SouthPaw302/Alchul/actions/runs/44026588916)

**Passed:** worldbook contract and native Godot engine smoke checks.  
**Not yet passed:** screenshot review, browser performance/fps testing, 3D mesh integration acceptance, species-safe site circulation, artistic approval.

## 5. Quality and canon gates

- The illustrated source reference often resembles human landscape architecture. This resemblance should be removed or justified before any canon promotion.
- Do not assert an excavated site, a precise date, species-specific dimensions, or the true appearance of Alchul.
- No iron-age technologies; the design should reveal engineering through flow, stress, chemistry, and ecological systems.
- The material colors and rough geometry remain **blockout-level**, not the intended cinematic visual result.
- Retain the old GitHub Pages release while this remains a draft PR.
- Future media batches must be archived to Drive immediately after generation with source, derived renders, provenance, version, manifest and explicit CANDIDATE status.

## 6. Verification log

- Drive archive readback (2026-11-17): concepts 18 files; GLB/source 8 files after final ZIP upload; 3D renders 11 files.
- Original GLB mesh and ZIP validated locally.
- Current native Godot study passed CI under PR #1.
- No claim of approval or release to the live URL.
