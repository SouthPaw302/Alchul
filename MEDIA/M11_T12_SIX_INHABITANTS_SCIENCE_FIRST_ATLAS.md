# M11 T12 — Six provisional inhabitants, with real-Earth chronology to the present

**Date:** 2026-11-23  
**Study status:** six functional profiles and an independent Godot research atlas are implemented as **noncanonical design hypotheses**. No final species anatomy, sex differentiation, occupational caste, age-specific body size, reproduction organ or present-day descendant body is approved.

**Mandatory companion:** [real Earth to 2026, science-first evidence atlas](../RESEARCH/SCIENCE_FIRST_EARTH_TO_PRESENT_T12.md). This is the primary project policy: geological/biological reality is developed independently through the present; fictional inhabitants and civilizations are then layered onto each period, never used as evidence for real history.

## 1. Scientific boundary

Real Late Cretaceous eastern North America includes fragmentary evidence of dromaeosaurids and other theropods. It does **not** include a recovered ALCHUL founding specimen or a confirmed civilization. Non-avian dinosaurs are not supported as survivors of the K–Pg boundary; their later underground persistence belongs to the **fictional** track. [Fossil review](https://pmc.ncbi.nlm.nih.gov/articles/PMC6894593/); [NPS extinction research](https://www.nps.gov/subjects/fossils/extinction-events.htm).

The *working* mature-surface population is a pre–K–Pg story premise. The absolute age of the peak is **unresolved**, even though one First Below scenario uses ~70 Ma. The two H-A/H-B skeletons from T07 are unapproved comparative reference candidates, **not** dimorphism, separate species or real anatomical specimens. Every profile's activity is a falsifiable design task, not inherited biological destiny.

## 2. Six distinct individuals — roles are chosen tasks, not castes

| Research profile | Life stage / specific experience | Physical-science constraint to test | What must not be invented |
| --- | --- | --- | --- |
| River reader | Adult who interprets flow, water level and substrate vibration through repeat observations | Foot traction on wet stone; three-digit bracing without human pronation; physical noise and false positives | Alchul-only sensing organ, direct time displacement, magical water control |
| Independent observer | Adult who records a second interpretation, including disagreement | Independent measurement, reproducibility, multiple observer error | Telepathic unanimity, genetically fixed shaman caste |
| Egg-bearing adult | Adult in late internal egg retention with unknown structural changes | T11 oxygen/maternal load, T08 COM and T10 clearance; no invented numeric body enlargement | Mammalian womb, sex-specific status symbols, known clutch or extra organ |
| Juvenile learner | Juvenile whose age-specific proportions and developmental landmarks remain unstudied | Learning by observation, exploration safety, nonhuman physical development and ecology | Tiny scaled adult as approved anatomy, human schoolchild behavior |
| Nursery caretaker | Adult who tends protected external incubation spaces; not assumed the egg-bearer | T11 ventilation/humidity/heat, T09 contact task and accessible nursery routes | Automatic mother/female role, hereditary caregiving caste |
| Harvest specialist | Adult who studies naturally fermenting plant materials and preservation | Real microbial fermentation, chemistry, gas, toxics and physically grounded handling | Human-style factory, miraculous growth or required ALCHUL contact |

These are **six independent people**, not the six sexes, professions, classes, genetic lineages or body variants of a species. Multiple individuals could occupy any role, switch roles or work cooperatively. Human-language labels are temporary translations.

## 3. Shared comparative constraints vs open inferences

**Inherited / research-grounded comparative reference:**
- The founder is fictional but dromaeosaur/maniraptoran-grade: attention to grasping three-fingered forelimbs, digitigrade support, feathers and tail is justified as a *comparative starting point* by the wider clade, not by a discovered exact founding taxon.
- Work and shelter geometry must follow actual mechanics: gravity, footing, reach, oxygen, flood exposure, gas diffusion, heat, microbial activity and real-material strength.
- H-A and H-B each contain 43-bone demonstrator skeletons but none of the 43-bone definitions has been biologically validated. They cannot be turned into certified adult/juvenile/egg-bearing dimorphisms without separate study.

**Still unresolved for all six:**
- Height, weight, shoulder geometry, exact three-finger opposition, tail mobility, plume arrangement, eye/ear receptor anatomy, life stages, development rate, reproductive tract, clutch, incubation conditions, sex/gender, social status and acoustic language.
- Whether any trait or environment persists to the Paleogene, Neogene, Quaternary or present-day fictional descendants. **Do not reuse peak-surface people as modern forms.**
- Precise site positions and Cretaceous doorway/corridor dimensions; no measured M1–M6 collision geometry has yet been fitted to any body.

## 4. Functional studies required before character art/rigging

1. **Reader/observer A/B:** create paired records of a real water/stress condition, one blinded; demonstrate that disagreements can arise and be resolved without postulating a new physical field.
2. **Egg-bearer movement:** perturb assumed mass distribution, breathing demand and clearance, and measure existing Godot nursery corridors only after source geometry is validated. T11's percentage describes **developmental progress**, not 75% of chronological time.
3. **Juvenile learning:** reconstruct plausible ontogeny by comparative dinosaur and living archosaur evidence, then model task learning with no predetermined human developmental milestones.
4. **Nursery:** produce explicitly bounded atmosphere/humidity/heat proxies and nonhuman ergonomic paths, with negative controls for flooding, blocked gas exchange and crowding.
5. **Harvest:** show actual chemistry, fermentation and contamination before any anomaly interpretation. Do not automatically assign technological achievements to Alchul.
6. **Era-specific body-plan evolution:** independently research each Cenozoic Earth period, then evaluate hypothetical deep-world selection pressures. The **present** requires its own future body registry and scientific gate, not a scaled version of the peak surface model.

## 5. Deliverables and reproducibility

- \`godot/data/m11_t12_real_earth_timeline.json\`: nine independently sourced geological/historical periods from ~80 Ma to 2026, each with real-science claims, uncertainties, URLs and a **separate** fictional overlay.
- \`godot/data/m11_t12_inhabitant_candidates.json\`: six independent research profiles, role-scoped environmental questions and explicit prohibition on sex/caste/anatomy/modern inferences.
- \`godot/tools/validate_m11_t12_science_first.py\`: standard-library contract validator, verifying the real K–Pg boundary, intraplate New Madrid, modern endpoint, complete epochs and explicit fictional counters.
- \`godot/tests/test_m11_t12_science_first.py\`: 18 adversarial tests: rejects fossil-survivor claims, missing epochs, unknown modern body portrayed as fact, misrepresented tectonics, caste/gender stereotypes and fixed numerical dates.
- \`godot/scenes/m11_t12_era_people_lab.tscn\` and \`godot/scripts/m11_t12_era_people_lab.gd\`: independent research-only Godot viewer. Press **R** for 9-era real Earth (default 2026), **P** for six provisional pre–K–Pg person studies, number keys to select, left/right for real-world chronology. The symbols are **abstract task markers** and never anatomical reference art.
- \`godot/tests/m11_t12_lab_smoke.gd\`: true-engine scene contract; \`godot/tests/render_m11_t12.gd\`: three genuine Godot screenshots (modern Earth, K–Pg, six-person study), with manifest.
- Native validation workflow: new offline tests, native Godot smoke, three capture images with manifests, exact source archive. Existing Chapter I and original media remain unaffected.

**Acceptance commands:**
\`\`\`sh
python3 godot/tools/validate_m11_t12_science_first.py --check
python3 -m unittest discover -s godot/tests -p 'test_m11_t12_science_first.py'
godot --headless --path godot --editor --import --quit
godot --headless --path godot --check-only --script res://scripts/m11_t12_era_people_lab.gd
godot --headless --path godot --script res://tests/m11_t12_lab_smoke.gd
\`\`\`

## 6. Decision gates and what T12 does NOT close

**Software acceptance (verified):** nine eras, six profiles, scientific provenance, separate science/fiction modes and actual Godot images. [PR #13 merged into main](https://github.com/SouthPaw302/Alchul/pull/13), with [18 Python checks, Godot native and twelve research captures passed](https://github.com/SouthPaw302/Alchul/actions/runs/45117710002), [actual Chromium browser preview passed](https://github.com/SouthPaw302/Alchul/actions/runs/45117710001), and [Windows/Linux/macOS builds passed](https://github.com/SouthPaw302/Alchul/actions/runs/45117710016). Post-merge [native validation](https://github.com/SouthPaw302/Alchul/actions/runs/45117997978), [Web export](https://github.com/SouthPaw302/Alchul/actions/runs/45117997918), and [GitHub Pages deployment](https://github.com/SouthPaw302/Alchul/actions/runs/45117998027) also passed on merge commit `fe170988`. [All T12 research sources and genuine Godot captures are archived in Drive](https://drive.google.com/drive/folders/1bZO3yKznh2vou7tX1is7T_Cz6G6dhAli). **Scientific acceptance remains open** for the exact founder taxon, H-A/H-B, the six bodies, reproduction feasibility, fossil survival and a functioning subsurface civilization. **Current species anatomy is deliberately UNKNOWN**; a modern living ALCHUL descendant in our world is *not* real scientific evidence.

**T13 should not just rig these into generic NPCs.** First complete the real comparative anatomy, growth, aerodynamics/respiration and age/era mechanics needed for candidate bodies, with the T12 Earth-chronology through-present requirement still enforced. Creator approval precedes final visible characters or canon edits.
