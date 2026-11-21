# ALCHUL — M11 / T07 Skeletal and Joint Architecture

**Date:** November 21, 2026
**Status:** FUNCTIONAL GODOT SKELETAL REFERENCE / NONCANONICAL RESEARCH, NOT A FINISHED ORGANISM, NOT AN IK RIG
**Implementation review:** [PR #8](https://github.com/SouthPaw302/Alchul/pull/8)
**T07 native validation:** [Passing Godot + graph CI](https://github.com/SouthPaw302/Alchul/actions/runs/44871598124) — after correcting JSON null-root parsing, 43-bone Skeleton3D construction, bounded pose controls, and existing M1–M6/chapter tests all passed. This validates **software behavior only**. Independent visual screenshot workflow remains separately subject to capture review.
**Rendering and art archive:** [M11 T07 Google Drive folder](https://drive.google.com/drive/folders/1AM7a2CZEpoTmczjJ558-hQTjtVPIjyEh)
**Reference diagram:** [See 2D render](https://drive.google.com/file/d/1kxS4xFrqVIFtSV3z0KAx1ijAab4JZUyE/view)
**Distinct production artifact types:** The linked PNG is a *programmatic Python/Matplotlib 2D anatomical-graph reference illustration*, not a Godot screenshot. A separately configured GitHub workflow attempts actual native Godot screenshots for the T07 scene. Do not conflate their provenance.

## 1. What is implemented

T07 adds the following **entirely isolated** Godot 4 source:

- `godot/data/m11_t07_skeletal_reference.json`: a versioned, evidence-qualified parent/child bone graph for both H-A and H-B, with 43 reference bones each. This is a sparse kinematic control scaffold, **not** all the bones in any complete animal skeleton.
- `godot/scripts/m11_t07_joint_lab.gd`: creates genuine Godot `Skeleton3D` instances, parents and rests bones, associates geometric joint/segment visualizers, accepts bounded one-axis test pose requests, supports resets, and displays scientific uncertainty.
- `godot/scenes/m11_t07_joint_lab.tscn`: standalone study scene. It does not replace `scenes/main.tscn`, edit the existing M11 T05 lab, or add a production character to Chapter I.
- `godot/tools/validate_m11_t07_skeleton.py`: a standard-library validator for parent graph integrity, named digits, mirrored attachments, bound joint controls and source status.
- `godot/tests/m11_t07_joint_smoke.gd`: a *real Godot* test of hierarchy, controlled pose requests, prohibited motions and both modes.
- `godot/tests/render_m11_t07.gd` plus `.github/workflows/alchul-t07-capture.yml`: an independent native Godot image-capture route, with provenance manifest. Render acceptance must be verified from actual workflow artifacts, not inferred from a source commit.
- `.github/workflows/alchul-native-validation.yml` runs both Python and Godot native validations.

**Compared body designs:** H-A preserves a longer articulated tail and lower forward-reading orientation. H-B has a shorter tail and raised neck/orientation. Both carry three separate manual digits on each side and a digitigrade hindlimb reference. Mirror names are `L` and `R`, not anthropomorphic left/right handedness or social roles.

## 2. Skeletal topology

The **43 reference bones per candidate** are:

- Axial/cranium/caudal: pelvis, spine, thorax, cervical 01/02, skull, mandible, caudal 01–04 = **11**.
- Each appendage side: scapula, humerus, antebrachium, carpus = **4**.
- Each appendage side: manual digits I, II, III, each with two reference segments = **6**.
- Each hindlimb side: femur, tibia, metatarsus = **3**.
- Each foot side: pedal digits II, III, IV = **3**.

Counting: 11 + 2×(4+6+3+3) = **43**.

Important: a *parented bone* here means a named control reference, not a strict osteological bone homology statement. For example, `antebrachium` collapses the forearm complexity and `caudal_01`–`04` sparsely samples a series. The digital set represents the inherited functional-manus architecture and provisional pedal options, **not** a proven number of load-bearing toes in mature descendants.

## 3. Joint-control policy

Supported *test* motions include neck pitch, mandible motion, caudal yaw, shoulder swing, elbow flexion, asymmetric wrist folding, individual digit flexion, hip/knee/ankle pitch, and pedal digit II candidate retraction. Test values are stored as degree **engineering control envelopes** rather than fossil measured limits. A request outside an allowed interval is clamped; one not in the registry is rejected.

**Deliberately absent:** active full axial forearm pronation; primate opposable thumb; omnidirectional wrist rotation; sprawling hip. These remain design guards, not a claim that natural evolution cannot ever alter the body plan. They prevent silent introduction of prohibited human analogues before functional comparative review.

The scope does **not** include solved inverse kinematics, muscular tendon actuation, constraint collision, center-of-mass computation, ground reaction forces, grip force, foot pressure or a believable gait. Such tasks belong to T08–T11.

## 4. Scientific evidence, analogy, and uncertainty

**In-universe authority:** `CANON.md` locks Earth-born feathered Appalachian maniraptoran ancestry, approx. 75% internal egg development by peak-surface age, sensory and process-engineering evolution, and unresolved Alchul ontology. None of these prove our chosen mature body proportions.

**Comparative paleontology:**

- Sullivan et al. (2010), *The asymmetry of the carpal joint and the evolution of wing folding in maniraptoran theropod dinosaurs*, [Biology Letters](https://pmc.ncbi.nlm.nih.gov/articles/PMC2880093/): asymmetrical wrist/carpal folding; does not provide universal wrist angles for this fictional descendant.
- *Resting Orientations of Dinosaur Scapulae and Forelimbs: A Numerical Analysis*, [PLOS ONE](https://pmc.ncbi.nlm.nih.gov/articles/PMC4684415/): shoulder/elbow/wrist orientation differs across dinosaur groups, so generic humanoid shoulder assumptions are unsafe.
- *Assessing Arboreal Adaptations of Bird Antecedents*, [PLOS ONE](https://pmc.ncbi.nlm.nih.gov/articles/PMC3153453/): non-avian paravian shoulder motion differs from birds/mammals; passive carpal motion does not imply active forearm pronation.
- *Differential locomotor and predatory strategies of dromaeosaurids*, [Journal of Anatomy](https://pmc.ncbi.nlm.nih.gov/articles/PMC7163733/), and *Testing the function of dromaeosaurid sickle claws*, [PeerJ](https://pmc.ncbi.nlm.nih.gov/articles/PMC6717499/): specializations in the foot (particularly digit II) and hindlimbs vary; don't claim all depicted digits share load in the same way.

The exported graph **cannot be dated** to an exact peak-surface calendar year or used to identify a known Appalachian fossil species. Its coordinate values are deliberately *not metres* and remain hypothetical.

## 5. Reproducibility and next gates

Run from repository root with Python 3 and compatible Godot 4:

```sh
python3 godot/tools/validate_m11_t07_skeleton.py
godot --headless --path godot --editor --import --quit
godot --headless --path godot --script res://tests/m11_t07_joint_smoke.gd
godot --path godot res://scenes/m11_t07_joint_lab.tscn
```

Inside the lab, press **0** for comparison, **1** for H-A, **2** for H-B. Pose controls are currently callable via script/tests, **not** a polished animator UI.

**Accept when:** graph and native test pass in a named CI run; 2 comparison bodies and three visibly separated digits are shown in the scene; any provided native screenshot is verified as an actual engine render. This is a **technical prototype gate** only. The scientific review of joint axes and body proportions remains open.

**Next implementation:** T08 segmentation, mass proxy and support polygon sensitivity; T09 hand-object contact / inverse kinematics; T10 ground/traversability and tail corridor clearance; T11 reproduction constraints. Require independent source review before treating any of their outputs as science.

See also [T06 visual QA](M11_T06_TEN_INDEPENDENT_PLATES_AND_SCIENCE_QA.md), [M11 hypotheses](M11_PEAK_SURFACE_INHABITANTS_COMPARATIVE_DOSSIER.md), and [master roadmap](ALCHUL_POST_MERGE_IMPLEMENTATION_MASTER_PLAN.md).
