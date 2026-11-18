# ALCHUL — Batch 07 / Godot Visual Integration & Native Screenshot QA

**Date:** 2026-11-18  
**Status:** EXPERIMENTAL / NONCANONICAL / NOT PUBLISHED  
**Source branch:** `feature/m1-river-3d-study` — [draft pull request #1](https://github.com/SouthPaw302/Alchul/pull/1)

## 1. Actual milestone achieved

Batch 07 is the first batch with ten **actual Godot engine screenshots** produced by the pinned Godot 4.7.2 runtime on a Linux Xvfb virtual display using the Compatibility renderer. Previously shared 3D images were offscreen VTK/trimesh previews, not direct native Godot screenshots.

The native capture workflow `.github/workflows/alchul-m7-visual.yml` runs `godot/tests/render_m7.gd` in CI and preserves ten screenshot PNGs plus a JSON capture report. The final **pixel-regression-tested** workflow run is [44260475542](https://github.com/SouthPaw302/Alchul/actions/runs/44260475542) (pass). The ordinary native smoke also passed on [44260475543](https://github.com/SouthPaw302/Alchul/actions/runs/44260475543).

### Ten native Godot captures

- 960 × 540 RGBA screenshots at stable named camera viewpoints;
- Views include the M7 riverbank, M2 station, M3 nursery, M4 Harvest, M5 corridor, M6 material inspection, rootwood, water edge and panorama.
- Screenshots were checked for nontrivial image variation, correct dimensions, and visually inspected; they still look like **blockouts**, not polished art.
- A new pixel guard at (480,450) of camera 01 prevents regression to the previously invisible floodplain.
- **Visual bug discovered and fixed:** the terrain triangle winding in `world.gd` and M6's local terrain patch was reversed. Original native screenshots showed a floating settlement against a turquoise void. Reversing the winding visibly restored the base terrain. The native CI now checks this automatically.

[Drive: Ten final native screenshot PNGs, contact sheet, capture metrics and GitHub capture ZIP](https://drive.google.com/drive/folders/1TClWjLHjRdHOhNNoblxKPIUA_R4ejUO1)  
[Native capture contact sheet](https://drive.google.com/file/d/18TWHu0zhISilUBq8hOJCkKbkMJkd9FCg/view)  
[Native screenshot ZIP (v002)](https://drive.google.com/file/d/1JjGAwpmBBzK9P5jCipQEwuN--KSeasF9/view)

## 2. Real PBR inputs in the native Godot scene

`godot/scripts/materials_m7.gd` instantiates seven real `StandardMaterial3D` families: silt, limestone, rootwood, clay, moss, fern and water. It binds **albedo, normal and roughness textures** and applies the first four relevant families to the live M6 terrain, stone, fern and rootwood geometry.

**Crucial provenance distinction:** The tested GitHub branch did NOT contain the archived binary M6 GLB nor 28 full-resolution image maps. To remain completely self-contained for smoke and visual CI, the scene generated **21 deterministic 96×96 fallback maps** (7 families × 3 channels). The in-engine native report shows `original_asset_families: 0` and `generated_fallback_maps: 21`. It therefore validates the **Godot PBR binding/render path**, not a finished import of the 768px originals.

`godot/tools/stage_m6_assets.py` provides a no-network, checksum-verifying import command for the **original** M6 14MB GLB and all 28 PNG maps. Its source ZIP is from Batch 06 Google Drive. The full original material assets are separately staged into a ready-to-unzip Godot folder structure.

[Drive: Verified M7 Godot import-ready pack — original M6 GLB + 28 original PNG maps, 30 files total](https://drive.google.com/file/d/1rGUBgMnaCOrsAWvF8_9Yw_8XaWdJLLty/view)  
[Drive: import and source folder](https://drive.google.com/drive/folders/1z-YEd--XFZYn6DKkJJxE4nbjE54b8IO5)

**Do not mistake having a staged binary pack in Drive for having the binary checked into the GitHub branch, loaded in the live Godot game, or approved for release.** Once staged locally, texture imports can be detected by the M7 material pass. The optional GLB still requires explicit placement and geometry/collision validation before activation.

## 3. Ten *additional* offline geometry composition QA views

The sandbox placed the actual Batch 06 textured GLB alongside the Batch 05 connected-settlement GLB, with an explicit hypothetical M6 offset of (+20.0,+0.4,-3.0). It rendered ten distinct 1200 × 675 VTK camera views showing habitat/river transitions, vegetation, seams, root crossings and the overall envelope. This is **not** a direct Godot screenshot nor a precision-aligned, physically plausible scene registration.

[Drive: Ten VTK composite renders and contact sheet](https://drive.google.com/drive/folders/11_DFMeWIpFvYMlNJ2HenLz4f-N4BxP9o)  
[Drive: Source code, QA findings, SHA-256 manifest and reproducible visual review ZIP](https://drive.google.com/drive/folders/1PCA-bTyaDVK2VceXL7q2DQZa5OZGs_xD)  
[Offline QA ZIP](https://drive.google.com/file/d/1d-yVLemf3t_QV18Mup6CBPHbqSjeus64/view)

## 4. CI verification

- `godot/tests/smoke.gd` asserts M2–M7 candidate nodes, seven native material families, and bound albedo/normal/roughness maps on the M6 terrain.
- `godot/tests/render_m7.gd` creates an additional controlled camera, captures ten actual engine frames in a virtual OpenGL display, and checks that the floodplain appears rather than the sky-void failure.
- Native smoke passed: [44260475543](https://github.com/SouthPaw302/Alchul/actions/runs/44260475543).
- Native 10-shot visual capture passed: [44260475542](https://github.com/SouthPaw302/Alchul/actions/runs/44260475542).
- The ZIP extraction, PNG dimension checks, checksum integrity and asset pack CRC also passed locally.
- **Do not interpret the capture times in `capture_metrics.json` as FPS.** These are wall-clock time per screenshot including PNG write and software-render latency, not GPU-frame benchmarks.

## 5. Visual acceptance and known issues

| Priority | Item | Status |
|---|---|---|
| P0 | Floodplain invisible due to face winding | **Fixed and regression-tested** |
| P0 | Basic M2–M7 native scene startup | **Passed** |
| P0 | Ten verifiable native Godot screenshots | **Passed** |
| P1 | 28 original 768px maps verified/staged for Godot | **Archived; not yet used in tested branch** |
| P1 | Original 14MB GLB alignment to Godot terrain | **Not validated** |
| P1 | Seam-free terrain and water | **Not achieved** |
| P1 | Collision, species locomotor clearance, movement | **Not checked** |
| P1 | Web export / real browser FPS | **Not checked** |
| P2 | Cretaceous botanical and ecological fidelity | **Not reviewed** |
| P2 | Cinematic asset fidelity | **Not achieved** |

The real Godot screenshots show that the world finally has visible continuous ground, the five environment modules load, the PBR materials apply, and vegetation is dense. However, many surfaces remain schematic, there are visibly sparse areas, and there is no defensible claim of photorealism.

## 6. Promotion decision

Keep this work in the existing **draft PR #1**. Do not merge it into `main`, call the live URL updated, assert a finished 3D GLB integration, or change canon until Web/browser performance and collision/geometry acceptance have passed.

**Recommended Batch 08:** Import source PBR PNGs and a deliberately optimized M6 GLB into a dedicated native Godot scene; fix terrain seams and collision/locomotion, then measure actual web performance while preserving the canonical worldbook and live rollback path.

## 7. Final Drive production ledger and readback

- [Complete M7 production bundle: import-ready M6 assets, real native Godot screenshots, offline 3D QA images and manifests](https://drive.google.com/file/d/1nwgYkl-PcGQDNzMOIUsX6aoOLDYi6pz7/view).
- [Batch 07 production ledger](https://drive.google.com/file/d/1zRih6u8uOcUhD3VJ0nlgIYaxMXwL87wJ/view) and [final SHA-256 manifest](https://drive.google.com/file/d/1sp8GBHNWaLN6muFzjzQUNt--SN8NDtqk/view).
- Google Drive readback confirmed **13** native screenshot-folder files (10 PNG + contact sheet + metrics + ZIP), **11** offline QA image-folder files, **one** verified original import-ready ZIP, and **8** supporting QA/documentation files.
- The complete bundle contains three independently CRC-validated ZIP archives plus ledger, checksum manifest and contact sheets.
