# ALCHUL — Batch 06: Materials and Living Riverbank

**Date:** 2026-11-18  
**Status:** experimental visual candidate, NOT approved canon and NOT published  
**Working tree:** `feature/m1-river-3d-study`, draft [PR #1](https://github.com/SouthPaw302/Alchul/pull/1)

## Numbered production record

1. **Objective.** Improve the riverplain's material language: weathered limestone, damp silt, clay, fibrous rootwood, moss, fern-like foliage and braided water. The emphasis shifts from disconnected structural blockouts to fine geological and vegetational detail.
2. **Actual textured geometry.** The standalone model `ALC_M6_RIVERBANK_DETAIL_TEXTURED_v001.glb` contains **139,280 vertices and 141,176 triangles**, organized into **seven texture-material groups**. It was generated procedurally in the sandbox with original reproducible Python sources. It is a new *localized detail study*, not the fully assembled M2–M5 settlement.
3. **Original material pack.** Seven 768×768 texture families × four PNG map types = **28 PNG files**, including albedo, normal, roughness and height maps. The GLB also embeds glTF PBR material textures. Its UVs are experimental world-aligned projections; inspect steep surfaces for artifacts.
4. **Ten true 3D render images.** Ten unique camera views were produced from the **exported GLB using VTK**, plus a combined contact sheet. These are genuine mesh previews, not AI-generated concept illustrations. The VTK renderer uses the generated albedo textures and approximate specular lighting; it is not a full glTF PBR path-tracer. **Do not call these photorealistic or cinematic final shots.**
5. **Native Godot detail.** `godot/scripts/materials_m6.gd` uses a shader-based world-space noise palette plus localized riverbank terrain, rock and fern MultiMeshes and root-bracing. The `environment_m1.gd` module adds `M6RiverbankMaterials_Candidate` separately from M2, M3, M4 and M5. This is an **independent Godot approximation**, *not* an import of the standalone GLB or 28 archived PNG maps.
6. **Native acceptance checks.** `godot/tests/smoke.gd` asserts all M2–M6 candidate nodes. [Godot workflow run #44258712432](https://github.com/SouthPaw302/Alchul/actions/runs/44258712432) passed `offline-contract` and `godot-native-smoke` on commit `1144424a`. This validates technical startup/node invariants, *not* aesthetic quality, browser frame time or physical navigation.
7. **Asset integrity.** GLB was reloaded with trimesh; each generated texture was saved as PNG; Python's ZIP CRC verification passed for the full 47-file production archive. Source, images, texture families, model, metadata and reproducibility instructions are bundled.
8. **Drive archive and readback.** [Textures — 28 PNGs](https://drive.google.com/drive/folders/1BfJvpQr4Ml2Lhp56spU6BEUhYA-Gp7xw), [3D model + source + versioned ZIP — 9 files](https://drive.google.com/drive/folders/128PBqGQGvD71SRRifjilkfNNXd34nOQb), and [actual 3D renders — 10 views + contact sheet, 11 files](https://drive.google.com/drive/folders/1ZjnHmf8YpZxicHkORC2zELyR6hiynYXZ). All counts were confirmed by Google Drive readback.
9. **Quality risks.** The current geometry still has a blockout look. It lacks approved paleobotanical species, calibrated wet surfaces, physically accurate water and collision geometry, close-range lighting, atmosphere, in-engine screenshot confirmation, and browser/low-end GPU benchmarking. The next major goal should address these in the actual deployed environment rather than only creating new offline dioramas.
10. **Release boundary.** Do not alter `main` or published Pages until direct visual and performance review. Both Godot-native source and original offline GLB stay reversible and explicitly noncanonical.

## Download and navigation

- [Actual textured GLB](https://drive.google.com/file/d/1Dq8tWIWa4QPDculuxXrRGhsa5T-ogGh3/view)
- [Complete M6 source/render/texture archive](https://drive.google.com/file/d/1dmymmRG0QAI8LSih0yC6t5tIrv24R29t/view)
- [Ten-render contact sheet](https://drive.google.com/file/d/1KCwNQ5DrPSsSFFj7_zuAeOXl0yW2r9G5/view)

## Recommended Batch 07

**Engine visual review and scene-level performance.** Import the verified M6 GLB and PBR assets into a Godot candidate scene, review screenshots with matching cameras, reduce bad UV and draw-call artifacts, build collision/nav test cases, and test an actual Web export. A live build must not be described as upgraded until that work passes.
