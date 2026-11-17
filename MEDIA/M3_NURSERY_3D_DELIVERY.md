# Alchul Batch 03 — protected nursery and circulation

**Updated:** 2026-11-17  
**Status:** EXPLORATORY / NOT APPROVED AS CANON  
**Period:** mature Late Cretaceous surface civilization, specific site and date unconfirmed

## Numbered production record

1. **Creative brief.** Explore sheltered protected reproduction-related circulation that respects a terrestrial theropod-derived, egg-retaining lineage, without assigning sex roles, egg dimensions, clutch sizes, or species-specific clearances.
2. **Reference media.** Four original full-resolution nursery environment concepts and one intact 2×5 concept storyboard were preserved. Ten separately stored panels are **crops of that one storyboard**, *not* ten independent images. Conflicting human/blue-tech visuals from other experimental generated sheets were excluded from this approved-to-archive reference pool.
3. **Real 3D geometry.** Built a standalone, noncanonical `ALC_M3_NURSERY_CIRCULATION_v001.glb` using reproducible Python/trimesh source: modeled a braided river edge, tapered approach, root galleries, three sheltered chamber shells, drains, planting, and structural ribs. The GLB has **63,244 triangles**, **56,793 vertices**, **17 grouped geometries** (file 1,680,296 bytes; SHA-256 `afb40744b5cb57b43c5554a6f413370723a043b61b8619a095e0c872647781db`).
4. **Ten actual 3D renders.** Used an offscreen VTK camera to capture ten unique views of that GLB, with a contact sheet. These are engine-generated visualizations of actual mesh geometry, not concept art relabeled as renders.
5. **Source + checksums.** Stored generator, renderer, packaging script, manifests, original concepts, GLB, renders, contact sheet, and ZIPs. ZIP archive CRC integrity passed. Local GLB was parsed successfully by trimesh.
6. **Godot candidate.** Added `godot/scripts/nursery_m3.gd` as a self-contained, no-network procedural module. In `godot/scripts/environment_m1.gd`, replaced the older shelter blockout call with `M3ProtectedNursery_Candidate`. The existing four worldbook sites, lenses, and observer remain.
7. **Native test.** `godot/tests/smoke.gd` now explicitly checks that both the Batch 02 station and Batch 03 nursery candidate nodes are instantiated. The strengthened native smoke initially exposed a GDScript type inference bug in the Batch 02 module. That bug was fixed. **GitHub Actions run [44027966628](https://github.com/SouthPaw302/Alchul/actions/runs/44027966628) passed both offline-contract and Godot native smoke**. This is not a visual/mobile/performance test.
8. **Review gates.** Need species body-plan measurement, path reach/turn radius, hydrogeology review, physics/collision, optimization, surface/material quality, lighting, Cretaceous vegetation taxonomy, and direct screenshot review before approval. The sandbox GLB and in-engine procedural model are independent alternatives, not the same imported mesh.
9. **Release safety.** Changes remain in **[draft PR #1](https://github.com/SouthPaw302/Alchul/pull/1)**. Do not silently merge or represent them as deployed live.
10. **Drive verification.** Read back and confirmed 17 files in concepts, 9 files in 3D source, 11 files in true 3D renders on 2026-11-17. All source/master media was preserved without replacing M1/M2 archives.

## Drive archive

- [Concepts: four full-size images, 2×5 original storyboard, ten panel crops, manifest, ZIP](https://drive.google.com/drive/folders/1TNL3Bj5VKALfEBdg4h13f-E8oTB2Rmjb)
- [3D geometry, generator, rendering source, checked manifests, ZIP](https://drive.google.com/drive/folders/1-HYjSaca0bfkxbbgFrBOi6DuGyN-lNPo)
- [Ten true GLB camera renders plus contact sheet](https://drive.google.com/drive/folders/1EQGsiakas7lMRmedK5J8t15W9b0i02Yl)
- [Complete 3D production ZIP](https://drive.google.com/file/d/13THW8OWHuJFdPtWi9bkFrpwpSJJLovsQ/view)
- [Original exported model (GLB)](https://drive.google.com/file/d/13yVVCVbWmbZNsyGf4gxlWnUsra2Drddc/view)

## Canon and source policy

This working design is an *architectural hypothesis*, not evidence of actual Cretaceous human-like buildings, a particular prehistoric cave, a native mythology, a verified reproduction mechanism, or Alchul's shape. No inhabitants or eggs are drawn. Focus on permeability, drainage, multiple sensory paths, stress distribution, environmental control, and safe family circulation. All geometry/color parameters need later creative approval.
