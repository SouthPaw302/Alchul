# ALCHUL M11 — T10: Force Feasibility, Digitigrade Transfers and Tail Clearance

**Date:** 2026-11-21  
**Status:** Validated **mathematical model behavior**; biological/engineering hardware validation **not established**. H-A and H-B both remain **noncanonical hypotheses**.  
**Code:** `godot/tools/m11_t10_mechanics.py` and `godot/tests/test_m11_t10_mechanics.py`, plus native Godot T10 debug stage and CI smoke.  
**Authoritative input:** existing T07 skeletal graph (`m11_t07_skeletal_reference.json`); existing T08–T09 results and declared assumptions. We verify the exact T07 bone-array SHA-256 against the T08–T09 provenance rather than silently mixing models.

## 1. What was added and what “validation” means

This is not an animal-dissection validation, a finite element muscle model, a real-world force plate, a captured Godot gait animation, or an approval of the M11 inhabitants. Model validation here means the code and tests recompute the same input-dependent outcomes and reject contradictory assumptions. The tests include deliberately impossible gripping and substrate cases. Acceptance of this **software gate** is separate from physical biological plausibility.

The T10 bundle comprises:

- `godot/data/m11_t10_force_locomotion_config.json`: versioned normalized assumption and science-limit registry.
- `godot/data/m11_t10_force_locomotion_results.json`: exactly reproducible numeric results and input hashes.
- `godot/tools/m11_t10_mechanics.py`: 2D force equilibrium, friction and distal-torque proxies, quasi-static transfer checks, and sampled L-corridor clearance.
- `godot/tests/test_m11_t10_mechanics.py`: 12 deterministic unit tests, including source-hash checks and negative controls.
- `godot/tools/render_m11_t10.py`: numerical illustrations and an animated, sampled rigid-tail corner study. PNGs/GIF **are Python renders, not Godot engine captures**.
- `godot/scripts/m11_t10_corridor_lab.gd` and `godot/scenes/m11_t10_corridor_lab.tscn`: interactive 2D Godot diagnostic showing two competing model sweeps. Space plays; left/right steps; C compares width 2.8 and 4.6. Separate from Chapter I.
- `godot/tests/m11_t10_lab_smoke.gd`: native Godot scene smoke, verifying science status, frames and expected clearance outcomes.
- `godot/tests/render_m11_t10.gd` and `.github/workflows/alchul-t10-captures.yml`: optional **genuine Godot debug-scene** screenshots generated in Actions. Capture must be verified independently; Python diagrams cannot substitute for native screenshots.

## 2. Forces: what is genuinely solved

### 2a. Backed fixture (realistic first _strategy_, not measured ALCHUL hand)

The preceding T09 hand-tip solver demonstrated three tip points close to a fixture but **not** grip force. A 2D fixture model now posits three co-directional finger normals pushing an object against an **independent supporting wall**. Static equilibrium is checked using

`ΣFx = 0`, `ΣFy = 0`, `Στ = 0`, `|Ft| ≤ μFn`, `0 ≤ Fn ≤ assumed capacity`, and an assumed distal segment–lever upper-bound on flexion torque.

**Assumptions (normalized, not N or Nm):** object load 0.32 body weights, finger friction coefficient 0.52, support friction coefficient 0.50, digit normal-force capacity 0.22 bodyweights per digit, support normal capacity 0.75 BW, experimental torque cap 0.064 BW×reference-length. A symmetric equilibrium requires about 0.107 BW finger normal force per finger. Both anatomical variants use the same normalized force assumptions and the same T07-derived distal segment lengths; **both pass**. Removing the wall fails. Lowering both friction coefficients to 0.05 fails. Changing the digit torque capacity to 0.001 BW×reference-length fails. These are assumption-driven counterfactuals; actual pad friction, claw morphology and muscle tensions are unknown.

### 2b. Hypothetical opposed radial clamp — conditional only

A **separate** artificial three-finger 120° radial arrangement mathematically counters one chosen external planar force and torque, with an assumed normal force of about 0.280 BW per digit. Lowering assumed friction to 0.08 fails the force-capacity test. **This is not known reachable by H-A or H-B.** Neither T07 nor T09 establishes the requisite opposed surface normals. Passing one external wrench **is not force closure**. Full force closure additionally requires resisting arbitrary wrenches and meeting real muscle and friction limits. No tool handling, grasping, or manipulation is certified by this result.

**Technical literature:** Lynch and Park, *Modern Robotics*, §12.2.3, [Force Closure](https://modernrobotics.northwestern.edu/nu-gm-book-resource/12-2-3-force-closure/). It distinguishes a grasp that can resist arbitrary wrenches from an equilibrium found for a single load, and notes that even force-closure contact geometry does not guarantee sufficient joint actuation force.

## 3. T10 transfer/contact checks

- T07 hip/foot marker references are reused; the baseline T08 projected COM remains deliberately assumed.
- Single-foot right support is false without lateral COM translation. To reach a model-only +0.025 contact margin, **H-A requires 0.205 normalized units** lateral shift, **H-B 0.265**. With an assumed 0.35 shift limit and 0.15 BW×length stance roll-moment ceiling, both nominal model transfers pass. These are *not demonstrated joint- or muscle-achievable displacements*.
- Contact fractions are foot-rectangle proxies, not anatomically reconstructed toe pads. Weight-bearing candidates are modeled as pedal digits **III and IV**; the special digit II remains **retracted** in this baseline. The species could conceivably evolve something else, but that remains a separate falsifiable hypothesis.
- Toy slip criterion compares normalized assumed acceleration-to-gravity demand with friction. Firm/wet-stone proxy `μ=0.34` passes; slippery-mud proxy `μ=0.055` fails. No measured substrate, acceleration waveform, GRFs, pressure or dynamic momentum is supplied.

**Comparative evidence:** Gianechini et al. (2020), *Differential locomotor and predatory strategies of Gondwanan and derived Laurasian dromaeosaurids*, [Journal of Anatomy](https://onlinelibrary.wiley.com/doi/10.1111/joa.13153), describes inherited pedal-digit-II specialization and III/IV support tendencies. [Reconstructing dinosaur locomotion](https://pmc.ncbi.nlm.nih.gov/articles/PMC11732409/) reviews how body volumes, segment masses, and muscle reconstruction are required before predicting real movement performance. Neither source establishes our fictional descendant's gait or force capacities.

## 4. T10 corridor turn / sweep test

All candidate poses use **one identical sampled path**: horizontal approach, 90° rounded corner of radius 1.10 model units, vertical exit. The rigid-body envelope samples 9 longitudinal stations from tail tip to head with left/right assumed widths and +0.08 safety allowance. Occupancy is checked against the *union* of two axis-aligned strips that form a normalized L-shaped corridor. The design intentionally does **not** permit voluntary lateral tail curling, gait stance adjustment, changing turn radius, or real collision response. Station geometry is sourced from the actual T07 anchors, not from images in T06.

| Body plan | First fully clear trial in checked width grid | At width 2.8 | Rejected path samples at width 2.8 |
|---|---:|---|---:|
| H-A, long tail | 4.6 normalized units | Fails | 55 / 101 |
| H-B, compact tail | 2.8 normalized units | Passes | 0 / 101 |

The widths are **not meters** and have never been matched to an actual M1–M6 corridor measurement. This *does* demonstrate the implemented test reacts correctly to tail length: substituting H-B's tail anchors into H-A reduces required width in a negative-control test. It **does not** settle which design the civilization evolved, or whether real architecture accommodates either.

## 5. Gates and next milestone

Technical acceptance when the exact source is committed, the 12 Python tests and reproducibility check pass on GitHub, the isolated native T10 Godot scene boots and responds correctly, and existing Chapter I/M1–M6 regressions stay passing. Visual native screenshots are an independent auxiliary CI surface; inspect them before claiming real-engine visual acceptance.

**Open scientific gates (do not waive):** fossil-comparative musculoskeletal constraints and calibrated range of motion; tissue-volume mass estimates; real distal tendon moment arms and pressure limits; true 3D object contact normals, force closure, friction and compliant pad model; time-dependent dynamics/GRF under substrate conditions; nonrigid tail response; actual imported city collision geometry and physically measured corridor widths; observed viable landing/step kinematics. Until those gates are satisfied, mark as `engineering_feasibility_only`, keep the original H-A and H-B models provisional, and do not update `CANON.md`.

**Next T11:** constrained gas exchange, embryonic oxygen delivery, structural/energetic limits and nursery ergonomics around the canon ~75% internal egg-development fraction, without claiming a known reproductive organ system.
