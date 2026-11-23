# ALCHUL M11 / T14 — Evidence-led Character Anatomy Approval Review

**Date:** 2026-11-23. **Classification:** Decision-ready comparative evidence, not a scientific claim of real dinosaur survival or a creator approval. **Decision status:** AWAITING THE CREATOR.

## Context and meaning of this decision

A pre-K–Pg surface descendent could be a highly modified member of a fictional Appalachian dromaeosaur/maniraptoran-derived lineage, but neither the exact founder fossil species, the exact mature surface body, nor the ancestral transition sequence is established. The extinct fossil evidence supplies constraints, not a true recovered species. Present-day ALCHUL inhabitants are **66 million years removed and cannot inherit the approved design automatically**.

The Harvest-associated altered state facilitates Alchul's perception of the residents as well as their contact with Alchul. Alchul is **not** their biological relative and has no defined ontology. Material-sensing biological capacities and tool/ecological engineering co-evolve; a T14 sketch is not a magical stone-levitating organism or a modern galaxy-scale body.

T14 scientific evidence categories: (A) published comparative paleobiology; (B) explicit parameterized model assumptions; (C) established fictional creator canon; (D) unsolved hypotheses. Native Godot meshes are not a fifth evidence class.

## H-A vs H-B vs unconstructed H-C

| Criterion | H-A, long-tail continuity | H-B, compact-tail manipulation | H-C, hypothetical hybrid |
| --- | --- | --- | --- |
| Fossil basis | Maniraptoran architecture as comparator only | Same comparator, not direct anatomy | No actual model |
| T07 reference | 43 named control bones, nonmetric | 43 named control bones, nonmetric | Not built |
| T08 arbitrary tail mass fraction | 14% assumed | 7% assumed | **Unknown; no interpolation** |
| T10 required lateral COM transfer proxy | 0.205 normalized | 0.265 normalized | **Unknown** |
| T10 fixed 2.8 normalized corridor | 55 of 101 rigid-sweep frames reject | 0 of 101 reject | **Unknown** |
| First fully clear sampled width | 4.6 normalized units | 2.8 normalized units | **Unknown** |
| T09 forelimb | Finite sample of finger-point nearness; NO force closure | Same methodological limitation | Not constructed |
| T11 reproductive study | No candidate-specific physiological feasibility shown | No candidate-specific physiological feasibility shown | Unknown |
| Scientific verdict | **Unmeasured alternative; cannot approve** | **Unmeasured alternative; cannot approve** | **Not a scored candidate** |
| Creator approval | **Not provided** | **Not provided** | **Not provided** |

These numbers are *code checks of art-tool assumptions* under normalized model units. They are **NOT** measured species lengths, meters, force plates, real walking collision, biological feasibility, or statistical confidence. The H-B rigid-sweep clearance is a valid *within-model engineering distinction*, not proof nature evolved that morphology. The T10 source test has an artificial L-shaped corridor and preselected path; a flexible tail, different gait, alternate building architecture or substrate response could change the outcome. A center of mass cannot be inferred from tail length alone; fossils preserve partial anatomical clues, not a living soft tissue mass distribution.

## Published real-world comparison anchors

- **Macaulay et al. (2023)**, *Decoupling body shape and mass distribution in birds and their dinosaurian ancestors*, *Nature Communications* 14:1575. https://www.nature.com/articles/s41467-023-37317-y — body shape does not uniquely determine COM; caution against judging A/B by tail appearance.
- **Sullivan et al. (2010)**, *The asymmetry of the carpal joint and the evolution of wing folding in maniraptoran theropod dinosaurs*, *Proceedings of the Royal Society B*. https://pmc.ncbi.nlm.nih.gov/articles/PMC2880093/ — inherited carpal folding is mechanically specialized; none of the two fictional wrists are measured.
- **Bishop (2019)**, *Testing the function of dromaeosaurid ‘sickle claws’ through musculoskeletal modelling*, *PeerJ*. https://pmc.ncbi.nlm.nih.gov/articles/PMC6717499/ — inherited digit II specialization constrains ancestor foot interpretation, not the ungual load in fictional late descendants.
- **Andrews (2002)**, reptilian egg retention oxygen constraints. https://pubmed.ncbi.nlm.nih.gov/12024290/ — a comparative challenge, not an archosaur inner-egg respiratory design.
- **Internal reproducible proxy sources:** `MEDIA/M11_T07_SKELETAL_JOINT_ARCHITECTURE_AND_QA.md`, `MEDIA/M11_T08_T09_BALANCE_CONTACT_STUDY_AND_GATES.md`, `MEDIA/M11_T10_BIOMECHANICS_FORCES_AND_CORRIDOR_VALIDATION.md`, `MEDIA/M11_T11_REPRODUCTIVE_GAS_NURSERY_CONSTRAINTS.md`, `MEDIA/M11_T13_PROVISIONAL_SKINNED_RIG_AND_CONTEXT_GATES.md`.

## Six open approval barriers

1. **Osteology/soft tissue:** approximate muscle wrapping, joint ranges, segmental volumes and mass inertia from suitable comparative anatomy; T07 numbers are unmeasured.
2. **Grip:** surfaces, contact normals, pads, claw interaction, tendon moment arms and actual force-closure across repeatable tasks; near-point matching is not grasp.
3. **Gait:** true dynamics, support polygon/foot pressure, digit II behavior, wet-ground friction, compliant tail and real torque limits.
4. **Settlement fit:** collisions/clearances with actual M1–M6 imported 3D assets, including nursery and turns; 2.8/4.6 are not site meters.
5. **Reproduction:** ~75% internal embryonic developmental progress is established fiction; gas transfer, burden, shell and nursery ecology remain unspecified and must not be invented as a ready organ.
6. **Creator signoff:** no user has selected H-A, H-B or a new hybrid; the program has no authority to do it. No change to `CANON.md` or replacement of Chapter I's body placeholder is allowed without that external written decision.

## Technically implemented T14 review

- `godot/data/m11_t14_anatomy_review.json`: versioned, cited, falsification-minded evidence table; explicitly no current decision; third candidate is NOT constructed or scored.
- `godot/tools/validate_m11_t14_anatomy.py`: adversarial validator; `godot/tests/test_m11_t14_anatomy.py`: negative tests rejecting invented approvals, a fabricated hybrid score, modern body promotion, false units and closed evidence gates.
- `godot/scenes/m11_t14_creator_anatomy_review.tscn` and `godot/scripts/m11_t14_creator_anatomy_review.gd`: inherited **actual skinned** T13 H-A/H-B Godot meshes with side-by-side evidence cards and review focus controls 0/1/2. An attempted `record_creator_approval` command always fails by design.
- `godot/tests/m11_t14_review_smoke.gd`: Godot-native regression, verifies original 43-bone rig references, no invented hybrid, no authorization and all open gates.
- `godot/tests/render_m11_t14.gd`: three actual Godot 1280×720 screenshots under CI (pair, H-A and H-B). Images remain engineering graphics and must not be mistaken for an approved archaeological reconstruction.

**Review acceptance:** all source code and data pass offline/native visual CI and are archived to Drive. **Creator signoff remains pending**, and that is a correct outcome, not a software failure.

## Next creator-facing decision when evidence improves

Choices: retain H-A as provisional study; retain H-B as provisional study; commission and test a true new H-C hybrid; or defer the choice until force/gait/archaeo-ergonomic evidence improves. Even a provisional *preference* is not approval of a final species or actual ability to evolve. A genuinely **locked anatomy canon** needs an affirmative statement identifying which features are established and which remain hypothetical.

The natural next engineering job after this review is measured scene ergonomics (T15) for both hypotheses, **without selecting one**. No current-day descendant is to be inferred from it.
