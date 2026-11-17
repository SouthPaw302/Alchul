# M1 — River Settlement 3D Study (v001)

**Status:** exploratory technical candidate; NOT visually approved; does not amend CANON.md.
**Date:** 2026-11-17
**Source authority:** SouthPaw302/Alchul.

## Numbered production record

1. **Design references.** Batch 01 contains ten new chat-generated studies: establishing river city, river-reading station, protected nursery route, Harvest precinct, dusk overview, terrace hydraulics, root causeways, civic galleries, materials board and stormwater resilience. These are *concept images*, not meshes, calibrated plans, or photogrammetry.
2. **Sandbox model.** A separate reproducible Python/trimesh generator constructed a true 3D glTF/GLB scene with river terrain, flow ribbons, bridges, terraces, protected arches, a measurement area, planted wood-and-root reinforcements and vegetation. Geometry is a simplified study, not a frame-exact conversion of any image. Its source, exported GLB, SHA-256 manifest and three VTK camera renders are distributed together as the M1 sandbox artifact pack. This standalone GLB has not been committed to GitHub or imported into the Godot project.
3. **Native Godot candidate.** `godot/scripts/environment_m1.gd` builds an additive 3D interpretation entirely inside the existing engine. `world.gd` instantiates it as `M1RiverEnvironment_Candidate` alongside the original world. The original four local sites, observer controls and three interpretation lenses remain in place.
4. **Technical gates.** Run `python3 godot/tools/validate_worldbook.py`, `godot --headless --path godot --editor --import --quit` and `godot --headless --path godot --script res://tests/smoke.gd`. A successful smoke test does **not** certify aesthetic quality.
5. **Visual review.** Compare the Godot candidate with the original Batch 01 concepts using matching camera views. Flag weak historical botany, schematic arches, floating geometry, simplified river fluid and excessive human-like paving. Do not treat an attractive generated image as paleontological evidence.
6. **Performance / browser gate.** Measure generated mesh count, frame time and WebGL 2 compatibility before publishing this revision. Consider replacing repeated MeshInstances with MultiMesh or baked GLB, importing appropriate PBR source maps, and adding LOD.
7. **Promotion.** Explicit creative review is required before any design becomes a production reference or alters the live default. Keep the old baseline as an easy rollback.

## Canon constraints

- Nonhuman theropod-derived inhabitants (not depicted in this environment batch).
- Ecology/wood/stone/water/pressure/chemistry as infrastructure, not a human iron-age city.
- No depicted body or known shape of Alchul.
- Exact site and mature architecture remain hypothetical.

## Storage

- GitHub is the authoritative native Godot runtime and source code.
- Drive /Alchul is the intended durable source-media archive.
- Initial ten images and sandbox candidate mesh pack require separate review and archiving before calling them approved or production-ready.

## Limitations

The Godot overlay and the standalone GLB are **two independent 3D interpretations** of the visual brief, not the same mesh. The overlay needs an actual Godot engine smoke test and visual/browser review before merging or publishing. Neither is an approved final asset.
