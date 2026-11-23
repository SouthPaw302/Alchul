# M11 T16 — Evolutionary Reconstruction of Three Provisional Mature-Surface Inhabitants

**Date:** 2026-11-23. **Scope:** fictional pre–K–Pg mature-surface lineage, NOT the modern New Madrid descendants. **Anatomical approval:** NOT GIVEN. **Distribution:** isolated Godot research lab, 3 exportable skinned GLBs and local-only opt-in game hook; never included visibly in the default public Chapter I.

## Problem

Treating H-A and H-B as an arbitrary aesthetic vote was inadequate. A plausible hypothetical descendant needs a transparent chain from fossil-informed **ancestral character constraints** through ecology, functional selection pressures, mass distribution, locomotion, object handling, reproduction, sensory ecology, and technical co-development.

No paleontologist can predict a unique phenotype for an entirely fictional unsampled lineage after millions of years, or validate a hypothetical non-avian dinosaur civilization surviving the K–Pg boundary. We therefore implement a **falsifiable, bounded design-space simulation**, not a true evolutionary forecast, and explicitly limit artistic freedom.

## Method and scientific basis

1. **Topology/phylogenetic prior:** T07 H-A/H-B have matching 43-control theropod-derived bone architectures, including digitigrade hindlimb options, three major manual digits and a caudal axis; no primate palm, independent thumb or free axial wrist pronation. New E1/E2/E3 use parent-local skeletal displacement transformations of this reference topology, not an invented mammalian plan.
2. **Transparent developmental/allometric assumptions:** Only eight named geometry factors, ranging 0.88–1.13 in the central alternatives, modify tail, trunk reach, neck height, forelimb reach, hindlimb elevation, lateral pedal spread, integument volume and cranial anterior reach. The distinction between **reference-model assumptions** and **real measured archosaur allometry** is enforced in code.
3. **Functional pressure hypotheses:** E1 river-margin stress reader, E2 material-process instrument maker, E3 sheltered route/nursery tasker. These are *alternate candidate pathways and individual task configurations*, not three taxonomic species, sex roles, castes or demonstrated adaptations.
4. **Volume and COM sensitivity:** A transparent segment volume × assumed region-density-weight proxy estimates **relative** 3D COM location and gross length/foot width. Twenty-four deterministic random perturbations (±5.5% for geometry factors, ±0.045 for reference mixture) per candidate give **bounded scenario sensitivity ranges**, NOT statistical confidence intervals or likelihood. No muscle force, gait or actual center-of-mass measurement is obtained.
5. **Soft-tissue visualization:** The two LOD actual Godot `Skeleton3D` skin-weighted `ArrayMesh` characters have additional modest, movable bone-attached volume primitives for trunk, skull, neck and tail. Pigment and sparse filament materials are *stylized study hypotheses*; not fossil evidence. Five T13 procedural skeletal motion cycles remain available; not force/IK-validated or baked into GLB.
6. **Reproduction:** The ~75% **developmental-progress** internal egg-retention canon imposes oxygen-transfer, burden and safe-route constraints. We do not infer a placenta or an egg-bearing sex anatomy from an untested mesh. Gas-exchange evolution remains independent T11 science gate.
7. **Matter perception and technology:** Contact and substrate sensitivity and technical manipulation co-evolve in canon, without a specified ESP organ, supernatural stone lifting or an invented sensory bone. Fermentation-associated contact is a fictional reciprocal perceptual aperture with Alchul, who is separate from this dinosaur lineage; no anatomical part claims to be Alchul.
8. **Era boundary:** modern descendant phenotype remains entirely unknown; none of these mature surface proxies is a present-era body.

### Evidence hierarchy / methods worth using

- Witmer (1995), *Extant Phylogenetic Bracket*. https://people.ohio.edu/witmerl/Downloads/1995_Witmer_Extant_Phylogenetic_Bracket.pdf — structured inference from living relatives, not proof of novel organs.
- Macaulay et al. (2023), *Decoupling body shape and mass distribution in birds and their dinosaurian ancestors*. https://pmc.ncbi.nlm.nih.gov/articles/PMC10033513/ — COM must be estimated with segment volume/density rather than equated to tail length.
- Sullivan et al. (2010), *The asymmetry of the carpal joint and the evolution of wing folding in maniraptoran theropod dinosaurs*. https://pmc.ncbi.nlm.nih.gov/articles/PMC2880093/ — folding wrist constraints; not primate pronation.
- Turner et al. (2007), *Feather quill knobs in Velociraptor*. https://pubmed.ncbi.nlm.nih.gov/17885130/ — fossil feather comparator, not precise later descendant plumage.
- Bishop et al. (2013), *Linking evolution of body shape and locomotor biomechanics in bird-line archosaurs*. https://www.nature.com/articles/nature12059 — digital 3D morphology/COM reconstruction precedent.
- Bishop (2019), *Testing dromaeosaurid sickle claws through musculoskeletal modelling*. https://pmc.ncbi.nlm.nih.gov/articles/PMC6717499/ — pedal digit II function is specialized, not automatically load bearing.
- Andrews (2002), *Low oxygen: a constraint on evolution of viviparity in reptiles*. https://pubmed.ncbi.nlm.nih.gov/12024290/ — egg retention O2 trade-off, *not* a viable theropod mechanism.

## Three models to compare, not choose by aesthetics

| Hypothesis | Ecological/functional scenario | Key deliberate changes | Primary falsification problem |
| --- | --- | --- | --- |
| **E1** Riverbank stress reader | Unstable substrate, repeated tactile readings, lower reach | T07 H-A leaning (0.12 toward H-B), caudal 0.99, hindlimb height 1.03, lateral pedal spread 1.08 | Longer tail may impose real corridor constraints; zero verified gait or tactile receptor |
| **E2** Material-process instrument maker | Braced handling, repeated station turns and precise contact | 0.72 toward H-B, caudal 0.88, forelimb x 1.10, trunk x 1.02 | No demonstrated opposition, wrist rotation, grip closure, joint forces or true station accessibility |
| **E3** Sheltered-route/nursery worker | Stable shared routes, safe retreat, physical support | 0.41 toward H-B, caudal 0.92, foot spread 1.13, torso volume +8% | No actual embryo oxygen organ, gravid loading, balance or source-site scaled routes |

The interpolation parameter is **between two prior fictional model geometries**, not phylogenetic ancestry, survival probability or a justified number of millions of years; an extinct fossil species and evolved descendants have not been directly observed.

## Reproducibility

- Profiles: `godot/data/m11_t16_evolutionary_profiles.json`.
- Source archosaur-inspired 43-control rigs: `godot/data/m11_t07_skeletal_reference.json`.
- Independently replayable profile/COM/sensitivity predictor: `python3 godot/tools/m11_t16_evolutionary_models.py --check`. Optional generation of a machine-readable hypothesis report: same command without `--check` (writes `godot/data/m11_t16_evolved_candidate_bones.json`; it is a reproducible output, not canonical source).
- Actual native three-model Godot scene: `godot/scenes/m11_t16_evolutionary_lab.tscn` and code `godot/scripts/m11_t16_evolutionary_lab.gd`. Controls 0–3 show all/individual, Space pause.
- Native true skinned model smoke: `godot/tests/m11_t16_evolutionary_smoke.gd`.
- Skinned glTF/GLB export and round trip: `godot/tests/export_m11_t16_evolutionary_glb.gd`, 3 separately editable GLBs, original Godot cycles **not** baked to portable animation.
- Native three-view capture: `godot/tests/render_m11_t16_evolutionary.gd`.
- Local opt-in settlement integration: `godot/scenes/m11_t16_experimental_inhabitants.tscn` and `godot/scripts/m11_t16_experimental_inhabitants.gd`. These load real original M2–M5 first-party assets, with candidate geometry visually positioned near them; scale is not calibrated.

## Remaining scientific and artistic gates

No measured mature surface body skeleton, validated musculature/soft tissue, foot-ground forces, ecological fitness values, quantitative climate constraints, sensory organs, late-retention embryonic oxygen physiology, mapped settlement passageways or phylogenetically reconstructed descendant divergence times. Do not falsely claim this implements a validated evolutionary simulator, species prediction or production-ready anatomy. T14 creator approval remains separate and explicitly pending.

**Technical T16 criterion:** three distinct real weighted rigs + source GLB interaction + optional local-only game integration, actual Godot renders, noncanonical scene test, safe zero-NPC Web default, GLB exports and offline model ensemble checks. **Production-quality and final species canon gates remain open**.
