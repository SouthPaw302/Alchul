# ALCHUL — T21.2: The Living Process Terrace

**Working era:** mature surface civilization, before the Long Descent and long before any modern awareness of Alchul. **Status:** original worldbuilding/working Godot extension, **not** an archaeological reconstruction, numerical hydraulic model or approved inhabited city.

## 1. Goal and where the work sits

T21.1 proved that the Braided Reach's bank, intake, culture stores, nursery temperature and gas relief are **interdependent** over a costly eight-watch day. T21.2 extends those systems with **visible operations in a native Godot scene** rather than replacing the existing story game.

The original [T21.1 scene and its tested action dynamics](../godot/scenes/t21_living_systems_scene.tscn) remain intact. The experimental [T21.2 lived-process terrace](../godot/scenes/t21_p2_living_terrace.tscn) subclasses the original gameplay logic without overriding its intervention, drift, numerical bounds or conclusions.

The environment uses the **original imported M2 Braided Reach river station**, then locates an explicitly interpretive, procedurally built work terrace along the near margin. These added structures are not claimed to be present inside the original source mesh or archaeologically verified. The terrace visualizes what we would need to commission as final, original, higher-detail art.

## 2. Implemented visual systems

1. **Bank sensing and practical excavation:** two distinct listening staves, cultivated root braces, a loaded wooden support that only appears after the player installs a brace, and a dark relief cut that visibly fills with water after the deliberate sacrifice. Flowing particles travel the side-channel; their speed is keyed to *the game's pressure index*, not a physical fluid solver.
2. **Native fermentation and filtration:** four planted culture vessels contain maintained biomass. A replaceable wall of twelve reed filter elements only appears when the intake is screened. The flood diversion spoils some unrescued cultures while protected storage visually changes the remaining vessel surfaces.
3. **Nursery care:** a curved organic root canopy and three guarded external eggs are surrounded by six removable warm stones. Their material glow changes with the **authored nursery-warmth meter**. Seven route markers illuminate only after the protected path has actually been inspected. The existing premise of approximately three quarters of gestation occurring internally is not used to infer unsupported organs or modern anatomy.
4. **Material workshop and safe venting:** a fractured mineral work surface, reusable shaped timbers and a covered air-exchange shaft. The vent cap changes position after opening, and light airborne particles follow its plume; **dangerous gases are not assumed detectable by smell**. The visual system remains qualitative and interpretive.
5. **Shared carrier route:** a regularly supported narrow load-way and an **abstract moving two-rail transport frame** representing ongoing collective labor. There is deliberately **no humanoid, dinosaur, approved worker skeleton or character animation** here; the moving object is a material activity trace and cannot prove physical ergonomic compatibility.
6. **Distributed warnings and records:** spaced resonant/stake elements link the work regions, recalling the earlier multimodal signaling studies while not inventing a universal script, caste or settled Silurian language.

## 3. How actions make the physical environment visibly change

| Existing action | Observable T21.2 change | What stays explicitly unmeasured |
|---|---|---|
| Survey | Existing listening staves are inspected; comparative information recorded in inherited game | An exact sensory organ or actual acoustic signal spectrum |
| Brace | Wooden brace and cross-wedge appear on bank | Elastic stress, seismic wave speeds, archaeological support loads |
| Relief | Sacrificial channel visibly floods; unrescued vessels darken | Real river flow, sediment transport or vessel contamination probabilities |
| Screen | Reed-filter lattice appears on culture inlet | Water potability or microbial safety |
| Vent | Covered vent cap opens; plume rate changes | Human/animal toxicity of gas mixtures or safe exposure limits |
| Warm | Heating reserve stones glow in response to warmer nursery state | Actual incubation thermodynamics or reproductive physiology |
| Store | Cultivated surfaces indicate rescued, maintained biomass | Exact fermentation species or true nutritional outcomes |
| Route | Checked emergency path lights | Final inhabitant dimensions, evacuation capacity or accessibility proof |

All action effects and terminal conditions remain those of [T21.1 data](../godot/data/t21_living_systems.json); no new "magic" causes are introduced. This is a material process exhibit, not a hidden numerical physics model.

## 4. Narrative continuity

[Chronicle 04 — The Work Between Warnings](../WRITING/CHRONICLE_04_THE_WORK_BETWEEN_WARNINGS.md) follows the Braided Reach during ordinary maintenance, not just catastrophe: learning from unsuccessful sample cultures, carrying stored heat to the nursery, repairing water screens and teaching the young to test a listening stave with a control. This is **the community's own invention**. Dreams and Alchul are left offstage; the fictional contemporary framing remains distinct.

The short names used to render personalities are translation conveniences for the project's nonhuman vocal/postural/chemical signals, not proof of their actual language. Roles remain situational, not anatomical castes.

## 5. Validation and screenshots

- Data provenance check: `python3 godot/tools/validate_t21_p2_terrace.py` plus the unchanged T21.1 validation.
- Native parse: `godot --headless --path godot --check-only --script res://scripts/t21_p2_living_terrace.gd`.
- Native scenario: `godot --headless --path godot --script res://tests/t21_p2_living_terrace_smoke.gd`.
- Render review: four actual Godot captured states via `godot/tests/render_t21_p2_living_terrace.gd` under virtual display. The new GitHub Action is `.github/workflows/alchul-t21-p2-living-terrace.yml`.
- **Acceptance pending until the new native CI has run successfully:** sources and added scene exist but this document does not itself constitute a verified render. Later pass records may be appended with exact run and Drive archive references.

## 6. What T21.2 does not claim

- **No finished, embodied inhabited scene:** the full species anatomical design remains subject to creator approval (T14 gate). No castes, anthropomorphs, modern descendants or known dinosaur skeletal outcomes are being introduced.
- **No quantitative hydrogeology, gas toxicology, fluid solver or certified food safety.** The scene retains T21.1's deliberately dimensionless narrative meters.
- **No evidence for the supposed Silurian civilization in real Earth history.** This remains fiction, with scientific ideas used as constraints and comparative inspiration.
- **No technological instructions from Alchul, and no literal ChatGPT–Silurian connection.**
- **No change to the game's public main scene, playable Chapter I, or release artifacts.** T21.2 is a separate review environment.

**Next quality gates:** genuine process animations at closer range (not particles alone), procedural or original art for phase-by-phase root engineering, confirmed species body size/abilities and work ergonomics, multi-day social rhythms, seasonal chemistry/flow calibration, soundscape, access-path testing and meaningful fictional resident decisions.
