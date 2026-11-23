# ALCHUL M11 — T08–T09 Center-of-Mass and Three-Digit Contact Study

**Status:** Prototype implemented; scientific acceptance OPEN. **No species anatomy has been approved.**  
**Date:** 2026-11-21  
**Archive:** [Full source, numerical results, comparison renders and QA files](https://drive.google.com/drive/folders/1kb3m4MiwMZ05_usRmSqP11_6ZMLdky2l)  
**Charts:** [T08 COM and support](https://drive.google.com/file/d/1zW5Qz4cwKGIC96aUEG5soLPg-iDPLTCA/view) · [T09 fingertip proximity](https://drive.google.com/file/d/1WSe0IJV7LK4APhpHcJS_2ASHfm4X5dS_/view)  
**Complete reproducibility report:** [T08–T09 research dossier](https://docs.google.com/document/d/1wGkQa-MwJVjdu7WAqWp7KWMVqb8K9gPs/edit).

## 1. Actual implementation

- `godot/data/m11_t08_t09_experiment.json`: explicit **assumed** mass-region fractions, foot envelopes, movement cases, deterministic sampling seed and 3D fixture targets.
- `godot/tools/m11_t08_t09_analysis.py`: standard-library COM and projected support-margin calculations, 256 deterministic randomized mass profiles, and an enumerated three-digit kinematic proximity search using T07 permitted angular ranges.
- `godot/data/m11_t08_t09_results.json`: tracked reproducible result file with SHA-256 of relevant T07 bone geometry and experiment config; `--check` fails when outputs and inputs diverge.
- `godot/tests/test_m11_t08_t09.py`: 9 automated checks covering mass normalization, deterministic runs, in/out contact scenarios, range rejection, forbidding invalid science status, and separate fingers.
- `godot/scripts/m11_t08_t09_lab.gd`, `godot/scenes/m11_t08_t09_lab.tscn`, `godot/tests/m11_t08_t09_lab_smoke.gd`: isolated Godot study scene overlays computed COM and support rectangles on the **real T07 Skeleton3D scaffolds**, and displays separate modeled fixture/hand-tip points; no Chapter I edits.
- `godot/tools/render_m11_t08_t09.py`: optional accurate numerical Matplotlib diagrams; screenshots from this script **are not Godot renders**.
- `godot/tests/render_m11_t08_t09.gd` and `.github/workflows/alchul-native-validation.yml (m11-native-captures job)`: separate true native-engine screenshot candidate workflow, requiring independent build-artifact confirmation.
- `.github/workflows/alchul-native-validation.yml`: standard offline verification and native smoke regressions.

## 2. T08 computed outcome, not historical measurement

| Assumption-driven computed metric | H-A long-tail | H-B compact-tail |
|---|---:|---:|
| Projected COM anterior X, neutral | 0.15168 | 0.40811 |
| Neutral two-foot margin within assumed rectangular support patch | +0.08168 | +0.29189 |
| **Unshifted** right-foot-only margin | −0.18000 | −0.24000 |
| Positive neutral margin in **256 assumed mass jitters** | 91.4% | 100% |
| Arbitrary tail mass share | 14% | 7% |

The COM is the normalized weighted average of six proxy region centers at T07 coordinates. The support patch is a rectangular approximation around metatarsal markers, **not a force plate**, true convex polygon, anatomical footprint, or measured stance. The one-foot trial intentionally does not shift body mass, making a negative margin a **diagnostic requirement for moving COM** and not a prediction of falling. An arbitrary 10% added cargo case is a **generic external payload** and not a pregnant individual, egg mass, clutch size, or reproductive mechanism. The 256 perturbations uniformly rescale regional masses by assumed factors 0.7–1.3 and renormalize; their percentages are **software sensitivity outcomes**, not probabilities for living or extinct organisms. Neither this static model nor any output determines which hypothesis actually balances better.

## 3. T09 computed outcome, not proof of manipulation

| Finite-sample contact search | H-A | H-B |
|---|---:|---:|
| Three fingertips near assumed fixture (tolerance 0.12 normalized) | 3/3 | 3/3 |
| Max near-target 3D distance | 0.06395 | 0.04282 |
| Three fingertips near an intentionally distant fixture | 0/3 | 0/3 |
| Max far-target 3D distance | 1.11698 | 1.04321 |

Targets are placed relative to each candidate's right scapular reference; the near fixture was selected as a toy reachable target. Shoulder, elbow, and wrist orientations are enumerated **within T07 art-tool demonstration limits**; each finger then gets its own bounded flexion. The solver minimizes worst-case 3D fingertip-target error, and declares a provisional *point proximity* match if below an assumed threshold. This does **not** test a real grasp, force closure, friction, joint torque, muscle activation, tendon performance, object motion, left/right coordination or viable tool manufacture. Full axial forearm pronation and opposable human thumb controls are excluded.

## 4. Reproduce and inspect

```sh
python3 godot/tools/m11_t08_t09_analysis.py --check
python3 -m unittest discover -s godot/tests -p 'test_m11_t08_t09.py'
# Only when intentionally changing assumptions:
python3 godot/tools/m11_t08_t09_analysis.py --write
# Optional charts (needs matplotlib, not a runtime dependency):
python3 godot/tools/render_m11_t08_t09.py --out /tmp/t08-t09-charts
# Native Godot 4:
godot --headless --path godot --editor --import --quit
godot --headless --path godot --script res://tests/m11_t08_t09_lab_smoke.gd
godot --path godot res://scenes/m11_t08_t09_lab.tscn
```

Inside the Godot study scene, **Space** cycles stance trials and **G** switches near/distant fixtures; the T07 scaffold retains its 0/1/2 candidate controls. All are diagnostic visuals only. No Godot runtime network access or remote asset dependency is added.

## 5. Real evidence and open scientific gates

Background comparative studies, **not evidence that the proxy fractions/angles are true**:

- [Decoupling body shape and mass distribution in birds and their dinosaurian ancestors (2023)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10033513/) — mass distribution and body proportions are not reducible to tail length alone.
- [Linking the evolution of body shape and locomotor biomechanics in bird-line archosaurs](https://pubmed.ncbi.nlm.nih.gov/23615616/) — multi-factor body and posture reconstructions.
- [Estimating Mass Properties of Dinosaurs Using Laser Imaging and 3D Computer Modelling](https://pmc.ncbi.nlm.nih.gov/articles/PMC2639725/) — mass modeling uncertainty.
- [Assessing Arboreal Adaptations of Bird Antecedents](https://pmc.ncbi.nlm.nih.gov/articles/PMC3153453/) — non-avian paravian forelimb limitations.
- [Forelimbs of Dilophosaurus wetherilli: range of motion, soft tissues and carpal](https://doi.org/10.26879/900) — comparative forelimb ROM; do not assume shared limits across unrelated taxa or deep-time descendants.

**T08 technical gate:** reproducible output with explicit assumptions and invariant tests. **T09 technical gate:** distinguish sampled point reachability from a real multi-contact grasp; reject wrong thumb and pronation. **Science gate STILL OPEN:** anatomically grounded tissue mass/volume, validated support contours, actual stepping/shifted COM, object constraints and contact normals/friction/forces, tendon/joint coupling, plausible locomotion and independent biological review. T10 and later must address these before choosing H-A/H-B or changing canon.

No scientific interpretation, including exact plate dimensions or body weights invented in T06 illustrations, is promoted to canon by these analyses.
