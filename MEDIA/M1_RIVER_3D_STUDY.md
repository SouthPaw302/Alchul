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
- **Archived 2026-11-17.** All ten original concept PNGs plus a checksum manifest, explanatory README and 36.4 MB ZIP are in [ALC_BATCH01_CONCEPT_STUDIES_10](https://drive.google.com/drive/folders/1JD79K7oQIu_1WwCygXkXhPKZOQGp_gLc).
- The actual standalone GLB, generator, render script, image references, README and manifest are in [ALC_M1_SURFACE_RIVER_3D_CANDIDATE_v001](https://drive.google.com/drive/folders/1GGeN01q7fB4nOC2WPKmhFzYjCLt-bF6e).
- All ten **3D offscreen renders** and their contact sheet are in [ALC_M1_BATCH01_3D_RENDERS_10](https://drive.google.com/drive/folders/1Le8QjbGWRN5OiY62lXoO4n0wJYrfM6zZ).
- A complete [ALCHUL_M1_3D_PACK_v001.zip](https://drive.google.com/file/d/1wrhg9-iZeCtFlF_ewoBn7EIWppS5dU9v/view) is stored in `09_RENDERS_AND_REVIEWS`.
- Uploads were verified through Drive folder readback (13 concept folder files, 8 candidate source files, 11 render folder files, one production ZIP). Local ZIP CRC tests succeeded.
- The GitHub pull request [#1](https://github.com/SouthPaw302/Alchul/pull/1) passed its [offline contract and native Godot smoke workflow](https://github.com/SouthPaw302/Alchul/actions/runs/44023360909). It remains a draft until visual/performance review.
- **Every later batch:** save source files and original full-resolution generated images into Drive when produced, include checksum manifest and status labels, verify folder/file metadata on Drive, and update this running production log before considering any asset approved.

## Limitations

The Godot overlay and the standalone GLB are **two independent 3D interpretations** of the visual brief, not the same mesh. The overlay passed native Godot smoke on the PR branch; it still needs scene-level visual/browser/performance review before merging or publishing. Neither is an approved final asset.
