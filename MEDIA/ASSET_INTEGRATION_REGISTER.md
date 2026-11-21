# ALCHUL — Batch 09 preliminary asset integration audit

**Date:** 2026-11-18  
**Starting commit on main:** `da769be3b1cf09241535a018bdd546f7b6bf9023`  
**Status:** preliminary metadata inventory; **Gate 0 is NOT passed**.  
**Scope:** original media, Godot runtime stand-ins, QA baseline, and import priorities. No canon modification.

## 1. Verified inventory

The connected [Alchul Drive project](https://drive.google.com/drive/folders/1EwcWrWDHsSr5KniPfhmhN2zLRmGMXANW) contains **242 catalogued direct-child records from 23 scoped folders**. This is a Drive metadata listing, not full recursive ZIP inspection or a checksum audit.

- **6 original GLB files** in M1–M6 source folders. A real model exists for the M2 river station.
- **28 M6 768-pixel material maps**, seven families × four maps (albedo, normal, roughness, height); plus **12 earlier A01 PBR candidates**. These are separate asset versions, not interchangeable evidence of import.
- **60 M1–M6 standalone 3D render PNGs** in their six ten-shot batches; **20 M7/M8 Godot-native screenshot PNGs** (separate QA evidence); **10 M7 offline composite PNGs**, NOT native engine screenshots; **16 concept PNGs**, including M2 studies.
- **14 items** held in the explicitly rejected M8 optimization folder, quarantined from approved imports.
- Machine-readable file IDs, byte lengths, source URL, batch, stage, file role and current gate status are in [ASSET_INTEGRATION_REGISTER.json](ASSET_INTEGRATION_REGISTER.json). SHA-256 intentionally remains null pending independent reads of original bytes.

### Original geometry candidates

| Batch | Master GLB on Drive | Size (bytes) | Godot import |
|---|---|---:|---|
| M1 | [ALC_SURFACE_RIVER_M1_v001.glb](https://drive.google.com/file/d/1nztTyxTbsWGNP_eD_JG1XVHoEcY0uhdq/view?usp=drivesdk) | 5,569,072 | Not in tracked `godot/assets` |
| M2 | [ALC_M2_RIVER_STATION_v001.glb](https://drive.google.com/file/d/1f-iQjSM6P7m4StfFaECLh0Kb6Q_NacPN/view?usp=drivesdk) | 2,364,296 | Not in tracked `godot/assets` |
| M3 | [ALC_M3_NURSERY_CIRCULATION_v001.glb](https://drive.google.com/file/d/13yVVCVbWmbZNsyGf4gxlWnUsra2Drddc/view?usp=drivesdk) | 1,680,296 | Not in tracked `godot/assets` |
| M4 | [ALC_M4_HARVEST_PRECINCT_v001.glb](https://drive.google.com/file/d/1Djt7wnaAcSnp_Ml5nRCqXQ6KT8nrjCJP/view?usp=drivesdk) | 2,147,656 | Not in tracked `godot/assets` |
| M5 | [ALC_M5_CONNECTIVE_SETTLEMENT_v001.glb](https://drive.google.com/file/d/1EmnbnYpksorU6Ez_uUhmldiVjx_G4zZM/view?usp=drivesdk) | 1,973,640 | Not in tracked `godot/assets` |
| M6 | [ALC_M6_RIVERBANK_DETAIL_TEXTURED_v001.glb](https://drive.google.com/file/d/1Dq8tWIWa4QPDculuxXrRGhsa5T-ogGh3/view?usp=drivesdk) | 13,728,468 | Not in tracked `godot/assets` |

## 2. Current engine reality

The current `main` tree includes first-party procedural scene components in `godot/scripts/`, but **does not contain `godot/assets/`**. The engine's `materials_m7.gd` seeks `res://assets/m6/textures/` originals, then generates 96×96 fallback PBR maps when missing. The archived native M8 `capture_metrics.json` reports `original_asset_families: 0` and `generated_fallback_maps: 21`. Thus archived M6 textures and GLBs must not be described as live assets.

M8 archival evidence: ten screenshots captured by native Godot under Xvfb/OpenGL Compatibility at **960×540**, and the pre-optimization Chromium SwiftShader/WebGL2 sample had **733.3 ms median / 883.3 ms p95** requestAnimationFrame scheduling. **These are historical samples, not fresh M9 timing, real desktop GPU FPS, or a visual acceptance gate.**

The M8 beam-batching attempt made roof arches appear as spikes and was rejected. Its v002 renders and code must not be restored without geometry/normal fixes and real engine image comparison.

## 3. Source folder counts (direct children)

| Folder | Evidence class | Count |
|---|---|---:|
| A01_PBR_CANDIDATES | pbr_candidate | 12 |
| A01_RIVERBANK_STUDIES | concept | 4 |
| M1_3D_RENDERS | offline_render | 11 |
| M1_RIVER_SOURCE | source_3d | 8 |
| M2_3D_RENDERS | offline_render | 11 |
| M2_CONCEPTS | concept | 18 |
| M2_STATION_SOURCE | source_3d | 8 |
| M3_3D_RENDERS | offline_render | 11 |
| M3_NURSERY_SOURCE | source_3d | 9 |
| M4_3D_RENDERS | offline_render | 11 |
| M4_HARVEST_SOURCE | source_3d | 8 |
| M5_3D_RENDERS | offline_render | 11 |
| M5_CONNECTED_SOURCE | source_3d | 8 |
| M6_3D_RENDERS | offline_render | 11 |
| M6_PBR_TEXTURES_28 | pbr_original | 28 |
| M6_RIVERBANK_SOURCE | source_3d | 9 |
| M7_COMPOSITE_REVIEW | offline_composite | 11 |
| M7_GODOT_IMPORT_READY | import_ready_archive | 1 |
| M7_NATIVE_GODOT | native_capture | 13 |
| M8_NATIVE_GODOT | native_capture | 16 |
| M8_QA_ARCHIVE | qa_archive | 4 |
| M8_REJECTED_BEAM_MULTIMESH | rejected_optimization | 14 |
| M8_WEB_PREVIEW | web_archive | 5 |

## 4. First integration choice

1. **M2 River-reading station**: start from [ALC_M2_RIVER_STATION_v001.glb](https://drive.google.com/file/d/1f-iQjSM6P7m4StfFaECLh0Kb6Q_NacPN/view) and its source generator/manifest. Compare to [ten M2 3D renders](https://drive.google.com/drive/folders/1c5CoobpsQlAdAutR72GCOO4hVXekB8KS) and distinguish these from concept studies. Measure mesh/tri counts, coordinates, tangents, UVs, collision geometry and roof seams.
2. **M6 original textures**: use the [28-file original PNG folder](https://drive.google.com/drive/folders/1BfJvpQr4Ml2Lhp56spU6BEUhYA-Gp7xw). Independently hash received bytes and compare to the archived `BATCH06_PACKAGE_MANIFEST.json`. Validate normal-map channel convention and actual in-Godot resource import.
3. **Replay M8 baseline** with pinned SHA and captures; archive exact device/browser versions and human-readable regression comparisons before changing scene assets.

## 5. Unfinished Gate 0 work

- Expand production ZIP members, reconcile duplicate generations/variants and deep archives; this listing is not yet exhaustive.
- Compute SHA-256 on every candidate **downloaded original file**; metadata size is insufficient for integrity.
- Derive mesh stats from actual GLBs and test source-to-render correspondence.
- Pin current native and browser tests, frame timing, load/WASM/PCK sizes, draw calls and memory, with repeatable scripts and exact SHA.
- Check accepted vs candidate vs rejected review decisions; no candidate is automatically canon.
- Record scientific source categories for historical/biological claims in corresponding research records rather than promoting visual assets to evidence.
- Keep the deployed site untouched until the M10 source-import, native image, science and browser gates have passed.

**M9 is not a new artwork batch.** The next deliverable is a verified original station + texture import, not another depiction of the station.

Related: [M9–M12 roadmap](ROADMAP_M9_M12_ASSETS_AND_INHABITANTS.md) · [Godot source](../godot/) · [Drive archive](https://drive.google.com/drive/folders/1EwcWrWDHsSr5KniPfhmhN2zLRmGMXANW).

## Follow-up verification: pilot asset bytes and UVs (2026-11-18)

[Complete source-integrity report](M9_SOURCE_INTEGRITY_CHECK.md) now records direct downloaded-byte verification for the M2 GLB and independently checked M6 archive members. This replaces the initial purely metadata-based status **for those specific sources only**.

- **M2 GLB direct SHA-256 matched its archived manifest:** `4e1a48850ea6d3e2b50e2a923ac07d11f637b9629090e7bcda5f3299ab5822c3`; 19 meshes, 93,114 triangles and **zero meshes with UV coordinates**.
- **M6 source ZIP passed CRC, SHA-256 and size checks on all 46 manifest-listed members**, including 28 original 768×768 PNG textures and the M6 GLB. The packaged M6 GLB has 7 meshes, 141,176 triangles and UV coordinates on all 7 meshes.
- **Critical M10 design correction:** import M2 source geometry separately; test genuine M6 textures first on the M6 UV-ready mesh. Add UV mapping or a documented triplanar solution for selected M2 structural surfaces instead of assuming it already has UVs.
- This does **not** establish the checksums of separately stored M6 Drive PNGs, or substitute for a native Godot visual validation. Gate 0 remains open and the live site is unchanged.
