# ALCHUL — M9–M12 Media Integration and Peak-Surface Inhabitants Roadmap

**Status:** approved-to-plan / NOT locked canon / no game changes from this file.  
**Prepared:** 2026-11-18.  
**Full numbered plan with eight development phases, evidence gates, production deliverables and review boundaries:** [Google Drive production document](https://drive.google.com/file/d/1tjRAd_jF-6mHrX8HZxg76snYSXJhSxi4/view).  
**Drive project planning folder:** [M09–M12 plan](https://drive.google.com/drive/folders/1fYNQq85zFnjFG6n9KK1xoft6i9xLCBYo).

## Scope, not a canon edit

The existing Godot scene represents the **mature peak-surface Braided Reach-type settlement before sustained Long Descent**, with an unresolved absolute date. This is neither the founder population around 80–78 Ma nor modern New Madrid descendants. The separate ~70 Ma first-below research scenario is not the automatically assigned date of this surface settlement.

Reconstruct from the repo's causal history: Appalachian maniraptoran mesopredator -> naturally fermented Harvest aggregations -> social learning -> chemistry/fire/environmental engineering -> exceptionally trained physical sensing -> repeatable but unresolved Alchul-linked anomalies -> mature ecological technology -> later descent. Do not imitate human Iron Age or assume Alchul handed down machines.

Before new media or canon decisions, follow `AGENT_BOOT.md`, `CANON.md`, `TIMELINE.md`, `SPECIES.md`, `CIVILIZATION.md`, `ALCHUL.md`, `VISUAL_CANON.md`, `RESEARCH/FOUNDERS.md`, `RESEARCH/ECOLOGY.md`, `RESEARCH/PEAK_SURFACE_CIVILIZATION.md`, `RESEARCH/MATURE_SURFACE_BODY_EVIDENCE.md`, `WRITING/SETTLEMENT_01_BRAIDED_REACH_WORKING_RECONSTRUCTION.md` and `LORE/INDIVIDUAL_01_TESH_BODY_AND_LIFE.md`.

## Scientific method

Every contested trait or historical depiction gets an **evidence card** with:
1. Clear claim and date/setting to which it applies.
2. Source, direct measurement or comparable extant/fossil group.
3. **Evidence class:** established observation / plausible comparative inference / locked in-universe fiction / unresolved.
4. Proposed biological, ecological or mechanical mechanism.
5. Competing model, limitations, prediction and falsification test.
6. Visual/engine decision affected, owner, confidence, test result and review status.

Do not portray a hypothetical mechanosensory organ, body dimensions, language, egg anatomy or Cretaceous plant species as known. Retain the established fictional ~75%-internal egg-development premise without inventing gas-transfer organs. Ground locomotion in theropod body logic but allow evolved surface descendants to diverge from founders. Cultural/religious claims remain contested and explanatory, with science and ritual intertwined but not indistinguishable from experimental proof.

## Paired development tracks

**Environment and media:** independently review the Drive M1–M8 master images, GLBs and original 28 M6 PBR maps; archive source SHA-256; import originals into Alchul's `godot/assets/` only when their provenance is verified; optimize UVs, geometry, LOD, textures, normals, collisions and browser memory for a coherent river-reading station. Only then scale the import to Harvest, nursery, wetlands and witness circle. The current Godot `materials_m7.gd` falls back to 96px procedural maps because `godot/assets/` is not on `main`. The real GLBs and 768px maps are archived on Drive, not yet live assets.

**Biology, history and inhabitants:** develop two competing peak-surface anatomy hypotheses, with evidence matrices, not one immutable species blueprint. A parametric adult study should explore center of mass, digitigrade locomotion, tail options, three-digit manual bracing, breathing, feather-derived surfaces, substrate/air/visual channels and reproductive constraints. Build a rigged Godot resident only after anatomical review. Animate bank observation, independent testing, careful manipulation, route assessment, care and teaching. Explore Tesh as a **specific provisional individual** alongside peers, a juvenile, an egg-bearing adult and specialists without assigning rigid castes or sex roles. Test paths against derived movement envelopes before declaring them inhabitable.

## Eight gates, ordered

| Gate | Required evidence/output | Pass standard |
| --- | --- | --- |
| 0: Baseline | Drive-to-Git asset manifest, checksums, prior native captures and real browser benchmarks | Reproducible provenance and unchanged published site |
| 1: Historical science | Date/stratigraphy/paleoecology constraints, comparative anatomy and cultural-causality matrix | Sources, uncertainty and competing hypotheses visible |
| 2: Pilot import | One original GLB plus original PBR map set in a native Godot station subscene | Direct proof that **imported** source assets render and Web export works |
| 3: Biological study | Two competing adult designs, ten anatomical views, ~75%-retention feasibility register | Body constraints separate inherited, evolved, fictional and unknown |
| 4: Character engineering | Rig, LOD, collision proxy, foot/hand/tail animations and ten **actual Godot poses** | Testable gait, turns, grasp and balance; no human anatomy by shortcut |
| 5: Inhabited science | Two/three individual roles in river experiment with independent replication, disagreement and failed trials recorded | Functional scientific/cultural behavior, not decorative characters |
| 6: Full site retrofit | Nursery/Harvest/witness routes, species-clearance tests, lighting/ecology and ten comparable engine frames | Real, navigable ecological infrastructure with no regressions |
| 7–8: Release | Evidence-linked three-lens HUD, actual device/browser metrics, visual/canon QA, PR and deployment SHA | Explicit approval; native, image and browser tests pass; GitHub Pages verified |

## First execution increments

- **M9:** inventory/provenance + instrument the existing native and browser build. Establish a stable benchmark and archival registry.
- **M10:** import and optimize the actual M6 materials and M2 river-reading GLB as a *small verified pilot*. Produce ten genuine Godot before/after captures.
- **M11:** construct the mature-surface inhabitant scientific dossier, two alternative anatomies, 3D model and rigging/movement tests.
- **M12:** put a working resident, an independent tester and a physically meaningful experiment into the improved reading station. Benchmark its browser performance before extending to all sites.

Each increment: numbered artifacts, ten review views when appropriate, machine-readable manifest, research/canon uncertainty labels, Drive original masters and versioned folders, GitHub PR, native tests, browser measurements, and an exact published commit or an explicit not-published status. Preserve old media and rejected experiments. The GitHub Pages release is independent from whether any new biology is approved as canon.

## Known technical risk

The prior M8 headless SwiftShader run loaded the scene but missed the software-GL performance budget (~1.6 s p95 requestAnimationFrame). This is not real hardware FPS, but it is a warning. A rejected MultiMesh beam-batching experiment broke roof arches in screenshots. Never reintroduce an optimization without correct transforms and direct native image regression.

**Nothing in this roadmap alone changes world canon or the playable website.**
