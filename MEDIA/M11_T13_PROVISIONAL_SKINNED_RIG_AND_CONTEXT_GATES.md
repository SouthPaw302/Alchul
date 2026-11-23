# ALCHUL — M11 T13: Skinned Rig Engineering, Motion Studies, and Canon Context

**Working date:** 2026-11-23. **Classification:** implementation research / NONCANONICAL morphology / not a released character.  
**Previous gates:** [T07 skeleton](M11_T07_SKELETAL_JOINT_ARCHITECTURE_AND_QA.md), [T08–T09 model](M11_T08_T09_BALANCE_CONTACT_STUDY_AND_GATES.md), [T10 dynamics proxies](M11_T10_BIOMECHANICS_FORCES_AND_CORRIDOR_VALIDATION.md), [T11 gas/egg-retention](M11_T11_REPRODUCTIVE_GAS_NURSERY_CONSTRAINTS.md), [T12 Earth through present](../RESEARCH/SCIENCE_FIRST_EARTH_TO_PRESENT_T12.md).

## 1. Historical and creator context reconfirmed before T13

The extinct **real** founder ecology is a Late Cretaceous Appalachian maniraptoran/dromaeosaur-grade predatory hypothesis, not a named fossil species. Pre-K–Pg surface descendants are hypothetical and already evolved beyond founders; no surviving non-avian dinosaur is evidenced by modern science. H-A and H-B are competing *pre–K–Pg surface* proxy geometry. Neither is a present-day person or valid anatomical identity.

The creator reaffirmed that naturally fermenting plant resources caused recurrent Harvest congregation. Fermentation is an ordinary biological process and a partial origin for social learning, chemistry, ritual and scientific inquiry. The accompanying altered-state perceptual aperture also operates toward Alchul: **Alchul is separate from the dinosaur lineage and uses the opening to peer into their reality**. This does **not** disclose Alchul's ontology, species, origin, motivation, prior awareness or whether the aperture was accidental. Alchul is not ethanol, yeast, one of the dinosaurs or a shortcut that gives the population finished technology. These statements reflect author intent and earlier September transcripts (see `ARCHIVE/`); the reciprocity of perception is an in-universe claim, NOT empirical neuroscience.

Their bodily sensitivity to material stress, airflow, fractures, gas, water, heat and substrate develops together with technical processes that act *through* matter. Early work uses practical tools, wedges, thermal gradients, chemicals and pressure; there is no unsupported stone telekinesis or human-style Iron Age. Over immense time, other-side physics evolves from perception to limited boundary effects and eventual matter/system displacement. A biologically evolved sensitivity and the technologies that exploit it are **mutually reinforcing**, not separate magical and scientific trees.

**Do not jump from a Cretaceous rig to a galaxy-scale present body.** The independent real-Earth chronology must be completed in evidence-qualified slices through 2026 first; fictional development across the 66 Ma interval is a separate track. No present-day lineage phenotype, ecology, galaxy transport device, actual New Madrid cavern or unmeasured physical parameter has been established by this study.

## 2. What T13 implements

- `godot/scenes/m11_t13_skinned_character_lab.tscn` is standalone. The playable `godot/scenes/main.tscn` is not modified.
- `godot/scripts/m11_t13_skinned_character_lab.gd` *extends* the T07 original reference skeleton lab. This ensures the same **43 named reference control bones** and blocked primate wrist/forearm assumptions instead of inventing new anatomy.
- Both H-A (longer tail) and H-B (shorter/raised) use true `Skeleton3D` objects with **weighted `ArrayMesh` vertices** attached by `MeshInstance3D.skin`; three tissue-appearance surfaces (soft volume / filament / keratin proxies) are separate.
- Two automatically generated mesh LODs (10 / 5 radial samples, normalized units) permit toggling without replacing the skeleton.
- Three deterministic UV procedural albedo + roughness texture/material variations: `river_silt`, `shade_moss`, `contrast_study`. They are intentionally non-realistic illustrative PBR maps; pigment/feather distributions have no biological approval.
- Five repeatable kinematic cycles: `walk`, `turn`, `grip`, `rest`, `communicate`. Their pose values remain clamped to T07's illustrative bone-control caps. These are **programmatic kinematic motion loops**, not validated muscle-driven gait, audio/vocal behavior, facial expression or contact IK.
- Each hypothesis has torso and rigid-tail clearance `CollisionShape3D` proxies. This is **not** a fit test against the settlement's real M1–M6 geometry; collision shapes are assumed.
- The native T13 smoke script checks **both actual skinned meshes**, vertex-to-bone indices, normalized weights, three surfaces, two LODs, three material sets, five reachable poses, changing hip rotations, rejected invalid inputs, collision proxies and explicit provenance flags.
- The export script writes separate skeletal **GLB candidates**, re-imports each and checks for an actual rig + skinned mesh. Exported geometry and materials are editable; **Godot procedural motion loops are not GLB-baked animation clips**. They should not be represented as a fully deliverable production animation library.
- The native capture script produces three actual Godot renderer images with a JSON manifest, from matched source scenes: walk comparison; grip contrast; lower-LOD communication.

### Reproduce

```bash
python3 godot/tools/validate_m11_t07_skeleton.py
godot --headless --path godot --editor --import --quit
godot --headless --path godot --script res://tests/m11_t13_skinned_lab_smoke.gd
godot --headless --path godot --script res://tests/export_m11_t13_glb.gd
# For actual screenshots run under graphical Godot or the pinned Xvfb CI capture job.
godot --path godot res://scenes/m11_t13_skinned_character_lab.tscn
```

Controls: 0 = both hypotheses, 1/2 = individual; 3–7 choose five motions; L switches LOD; V changes material; Space pauses. Each body is a design *hypothesis*, with nonmetric coordinates and biological unknowns visible in the HUD.

## 3. Acceptance boundaries and next decisions

**Technical prototype gate:** Confirm native Godot smoke, screenshots, three-stage CI, actual weighted-vertex GLB round-trip, source provenance and Drive archive before merge. Review any discrepancies rather than claiming graphics quality from source code alone.

**Not passed by this implementation:** production-quality deformation, proper subsurface mesh and keratin/feather anatomy, muscle-driven gait, IK contact closure, egg-bearing physiology, facial signaling, verified LOD visual equivalence, actual scene collisions, native hardware performance, approved body scale, and baked animation tracks in portable GLB. The scientific reconstruction and T14 creator-approved anatomy are independent gates. `CANON.md` may be updated only for **direct creator statements** about Alchul/Harvest/matter co-development, not for T13 shape, colors, gestures or organs.

**Provenance:** [Godot Skeleton3D](https://docs.godotengine.org/en/stable/classes/class_skeleton3d.html), [MeshInstance3D skinned mesh](https://docs.godotengine.org/en/stable/classes/class_meshinstance3d.html), [procedural ArrayMesh arrays](https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/arraymesh.html), [GLTFDocument round-trip](https://docs.godotengine.org/en/stable/classes/class_gltfdocument.html). These are *engine API* references, not evidence that a particular extinct organism had these proportions.
