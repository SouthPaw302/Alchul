# Surface Zenith — fidelity development pass 02

Approx. 70 Ma fictional observation window. Reference art: [concept archive](https://drive.google.com/drive/folders/1Wegv8EieA8ho46WKjqrftmRiCmWtzTrY). Original T14 anatomy remains unapproved; no public Chapter I modifications.

## Implemented
- Continuous swept torso, neck and cranial meshes; rounded joints, eyelid ridge and detailed contour feathers. Three static provisional variants, not scientific predictions.
- Original 512×512 albedo and normal map pairs for skin, plumage, wood, stone, leaf, clay and woven fiber. Deterministically synthesized, not photographic scans. Maps are embedded into portable GLBs and exported separately.
- Continuous curved root beams, woven diagonal lattices, hanging fiber, expanded frond detail, moss and paving.
- Animated spatial river shader with time-dependent ripple normals and color; no hydraulic simulation.
- Original T16 weighted E2 rig accessible separately with A; 43-bone animation remains distinct from the new static sculpts. Minor whole-body movement of static actors is not skinning.
- Independent scene res://scenes/surface_zenith_fidelity_city.tscn. Left/right change camera view. A toggles separate rig study.

## Validation contract
CI must export ten GLBs with embedded color and normal textures, re-import all ten, preserve fourteen standalone maps, render ten new asset-backed views plus one weighted rig view, and verify the water clock advances. Results pending before native completion. Pass 01 is retained. No claim of final photorealism, full skinning, physical material measurements, production performance, or real historical evidence.
