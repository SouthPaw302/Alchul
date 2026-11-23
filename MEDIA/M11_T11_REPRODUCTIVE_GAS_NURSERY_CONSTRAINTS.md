# ALCHUL — M11 T11: Internal Egg Retention, Oxygen Constraints and Nursery Engineering

**Date:** 2026-11-22  
**Stage:** mature/peak-surface descendant only  
**Status:** reproducible **dimensionless screening implementation**, biologically unresolved, **not canon approval**.  
**Authority:** [CANON.md](../CANON.md), line under Reproduction: eggs are retained internally for approximately **three quarters of embryonic development**, with the remainder externally incubated. This is not a known elapsed-time percentage. No organ geometry, clutch size, shell chemistry, tissue perfusion, oxygen tolerance, measured atmospheric composition, or reproductive social role is approved.

## 1. Evidence ledger: what biology actually supports

| Evidence class | Finding | Transfer to Alchul |
| --- | --- | --- |
| Real-world comparative biology | Squamate reptiles can retain eggs to advanced embryonic stages; low oxygen exchange is a well-documented constraint on prolonged retention. [Andrews 2002](https://pubmed.ncbi.nlm.nih.gov/12024290/); [Andrews & Mathies 2006](https://pubmed.ncbi.nlm.nih.gov/16691524/). | Mechanistic **challenge**, not proof an archosaur-descended species could do the same. |
| Real-world comparative biology | Experimental work on turtles finds strong intra-oviductal hypoxia and reduced diffusivity; prolonged development is **not** generally available in all reptiles. [Andrews et al. 2013](https://pubmed.ncbi.nlm.nih.gov/23348778/). | Explicit negative comparative control. Do not assume extant birds/crocodilians already exhibit this system. |
| Real-world comparative biology | Embryonic developmental arrest and the physiology of egg retention differ across reptile clades. Eggshell changes can trade gas diffusion against water balance and mechanical protection. [Arrested embryonic development review (2012)](https://pmc.ncbi.nlm.nih.gov/articles/PMC3350689/); [Shine & Thompson (2006)](https://researchers.mq.edu.au/en/publications/did-embryonic-responses-to-incubation-conditions-drive-the-evolut/). | A candidate for **new selection pressures**, not a designed organ. |
| Real-world paleobiology | Fossil eggshell pores and gas conductance can constrain inferred nest microenvironments; open and covered nests show systematic differences in studied archosaurs. [Tanaka et al. 2015](https://pmc.ncbi.nlm.nih.gov/articles/PMC4659668/); [Deeming 2018](https://pmc.ncbi.nlm.nih.gov/articles/PMC6030333/). | Testable architecture/ecology logic, **not a measured Alchul nest**. |
| Real-world comparative biology | Reptilian egg temperature, moisture and oxygen can alter hatchling developmental outcomes; response varies by species, eggshell and context. [2022 review](https://pmc.ncbi.nlm.nih.gov/articles/PMC8894305/). | Requires distinct external incubation controls; no direct thermal set point is known. |
| Real-world comparative biology | Eggshell structure, water handling and fluid storage change with reproductive mode. [Stewart 2017](https://pubmed.ncbi.nlm.nih.gov/28221829/); [2024 eggshell chemistry and hydration](https://doi.org/10.1093/icb/icae040). | Prevents assuming that greater gas diffusion is harmless or free. |
| Fictional established canon | The later peak-surface descendants achieve ~75% **developmental progress** internally, then lay eggs for external incubation. | Fixed narrative boundary; not experimentally derived. |
| Open fictional hypothesis | They evolved some **unspecified** suite of transfer, shell, metabolic and developmental accommodations through deep-time selection. | No placenta, uterus shape, embryo sac physiology, organ count, sex role, fossil specimen, or reproductive body plan is presently established. |

**Important phylogenetic caveat:** Squamate egg retention is a useful example of evolutionary solutions and constraints, but our founders are dromaeosaur/maniraptoran-grade archosaurs, not squamates. This extrapolation is *especially* uncertain. A canon stipulation does not turn a proposed transfer mechanism into observed biology.

## 2. Computational screening — mathematical behavior, not animal physiology

The code is in:
- \`godot/data/m11_t11_reproductive_constraints.json\` — immutable 0.75 story boundary, 7 scenario assumptions, unknowns, external sources and guardrails;
- \`godot/tools/m11_t11_reproduction.py\` — standard-library deterministic stage sampling and negative controls;
- \`godot/data/m11_t11_screening_results.json\` — reviewed scenario outputs and reference curve;
- \`godot/tests/test_m11_t11_reproduction.py\` — 16 offline adversarial/provenance tests;
- \`godot/scenes/m11_t11_reproductive_lab.tscn\` and \`godot/scripts/m11_t11_reproductive_lab.gd\` — separate Godot viewport showing assumptions and failures (keys 1–7);
- \`godot/tests/m11_t11_lab_smoke.gd\` and \`godot/tests/render_m11_t11.gd\` — native scene regression and two true-engine screenshots.

We use an **artificial developmental index** \`s\` in [0,1]. For \`s <= 0.75\`, embryo oxygen-demand **index** \`D(s)=0.18+0.82*s²\` is compared with an assumed internal exchange **index** \`C_internal=conductance*driving_gradient\`. For \`s >= 0.75\`, it is compared with assumed external nest exchange \`C_external=egg_exchange*external_gradient*ventilation\`. Maternal carrying-cost index is \`C_maternal=burden_coefficient*clutch_load_index*(0.20+0.80*s²)\`, compared with an arbitrary unit budget. Independent moisture and heat-stress index bounds screen external nursery scenarios.

**These are toy indices**, not physiological equations calibrated to an animal. In particular, there is **no** tissue oxygen partial pressure, egg-shell porosity measurement, diffusion coefficient, energy expenditure, embryo mass, development rate, pregnancy duration, uterine vasculature, gas-transfer organ, humidity percentage or temperature in degrees. The 0.75 cutoff does not imply a chronological 75% pregnancy or a 25% incubation duration.

## 3. Reproducible scenario results (all numbers dimensionless and invented)

| Scenario | Internal O2 margin | External O2 margin | Maternal budget margin | Screening |
| --- | ---: | ---: | ---: | --- |
| Reference comparison | +0.35875 | +0.14750 | +0.82125 | Pass |
| Internal hypoxia | -0.20375 | +0.14750 | +0.82125 | Fail: internal exchange |
| Restrictive internal exchange | -0.28125 | +0.14750 | +0.82125 | Fail: internal exchange |
| Stagnant nursery air | +0.35875 | -0.52750 | +0.82125 | Fail: external exchange |
| Excessive maternal load | +0.35875 | +0.14750 | -0.17000 | Fail: maternal burden |
| Desiccating nursery | +0.35875 | +0.14750 | +0.82125 | Fail: water index |
| Overheated nursery | +0.35875 | +0.14750 | +0.82125 | Fail: heat index |

**Interpretation:** The tests correctly reject obviously adverse cases *within chosen algebraic assumptions*. A green reference scenario does **not** demonstrate that 75% retention is possible in any real bird, dinosaur, or fictional organism. It only prevents this provisional design from hiding obvious constraints. No relative H-A/H-B reproductive feasibility is claimed: both have unknown tissue and reproductive anatomy.

## 4. Nursery architecture implications — hypotheses, not installed game assets

1. **Ventilated incubation recesses.** The last period of external development needs exchange of gas; do not make hermetically sealed display nests. Air circulation, flooding, CO2 accumulation and sheltering are causal challenges worth modeling, not arbitrary magical features.
2. **Moisture with gas access.** Protect against drying without assuming saturated substrate is harmless. Porosity and water exchange are a coupled trade-off, not a single "more humidity is better" slider.
3. **Thermal buffering and monitored shelters.** Architecture can offer several protected microclimates, shaded channels and maintenance points; exact temperature targets cannot be set from this dossier.
4. **Adult movement and transfer.** An egg-bearing worker may need secure, short approaches, cooperative material transfer and turning clearance. Use **real imported M1–M6 collision geometry later**; T07/T10 normalized body measurements are not nursery dimensions.
5. **Collective care, not invented reproductive caste.** Protection, observation and egg transport must be socially available without attaching these responsibilities to a sex, status or genetic parenthood rule.
6. **No body cutaway or living embryo shown.** The T11 2D Godot scene visualizes proxy indices only. Final anatomy requires separate comparative scientific and creator review.

## 5. Test/acceptance protocol

\`\`\`sh
python3 godot/tools/m11_t11_reproduction.py --check
python3 -m unittest discover -s godot/tests -p 'test_m11_t11_reproduction.py'
godot --headless --path godot --editor --import --quit
godot --headless --path godot --check-only --script res://scripts/m11_t11_reproductive_lab.gd
godot --headless --path godot --script res://tests/m11_t11_lab_smoke.gd
\`\`\`

The existing GitHub native validation workflow runs these alongside previous T07–T10, Chapter I and original media regressions. Real-engine reference and internal-hypoxia images are captured in the same consolidated workflow under \`ALCHUL_T11_CAPTURES\`; the source PNGs and render manifest require independent visual review. Never describe Python charts as engine screenshots.

## 6. Open gates before T12 production characters

- Biophysical plausibility of late retention in an **archosaur-derived** lineage; comparative tissue and shell mechanics, respiratory and maternal transfer routes, gas-exchange efficiency, developmental arrest and possible evolutionary transition paths.
- Distinguishing *fraction of developmental progress* from chronological duration; no valid conversion exists yet.
- Independent paleontological/comparative review of high-energy embryogenesis, nutrient/water access, shell evolution, maternal costs and oviposition timing.
- Physically measured nursery geometry and sustained air/thermal/hydric operating envelope, integrated with proven M1–M6 scenes.
- Explicit creative authorization before declaring organ anatomy, clutch size, sex roles, hatchling abilities or an H-A/H-B species form to be canon.

**Implementation receipt:** [Merged PR #12](https://github.com/SouthPaw302/Alchul/pull/12); [passing T11 native checks and real Godot captures](https://github.com/SouthPaw302/Alchul/actions/runs/45105480573); [passing desktop builds](https://github.com/SouthPaw302/Alchul/actions/runs/45105480554); [passing actual Chromium Web preview](https://github.com/SouthPaw302/Alchul/actions/runs/45105480593). Original versioned source and rendered evidence: [T11 Google Drive archive](https://drive.google.com/drive/folders/1wcJKPyhqq-GFvv263Hi69Qu-zKVuUSwk). These support engineering/software acceptance only.

**Decision:** T11 is an implemented and reproducible *research feasibility screen*, with biological acceptance open. Proceed to T12 with alternative adult/juvenile/egg-bearing social roles marked provisional; do not replace the Chapter I figure or modify \`CANON.md\`.
