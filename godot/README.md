# Alchul — Standalone Godot Runtime

## ALCHUL — The Braided Reach: playable Chapter I (November 19, 2026)

The available native scene and current first-party media now support a **complete short offline desktop game**, with four explorable places, a field map, evidence journal, persistent local save/continue, start/pause/controls, three worldbook interpretation lenses, a return-to-bank conclusion and replay. This closes the **existing-assets game chapter**; it does not claim to have finished the full fictional universe or locked speculative historical canon.

**Merged branch status:** On November 20, 2026, M9 provenance, M10 original media, Chapter I, the full M1–M6 media atlas, and M11 scientific studies were merged into the repository's default `main` branch. The original source media and game are not a final approved historical reconstruction. [Post-merge implementation plan](../MEDIA/ALCHUL_POST_MERGE_IMPLEMENTATION_MASTER_PLAN.md).

**Chapter I 1.1 — real gameplay + graphics upgrade:** [Full implementation and QA](../MEDIA/CHAPTER_I_V1P1_GAMEPLAY_VISUAL_REBUILD.md). New `scripts/chapter_game_v2.gd`, `scripts/chapter_signal_instrument.gd` and `scripts/chapter_atmosphere_v2.gd` improve UI, in-world wayfinding, source-PBR material treatment, foliage and four site instrument challenges. Start in the coherent integrated scene, not a standalone GLB review. Press M for map; F8 shows optional M1–M6 source gallery; E examine; use the dial to compare a normalized paired control; Tab journal; 1/2/3 change evidence lenses. Scientific testimony and controlled physical evidence remain separate. New `tests/chapter_v2_play_smoke.gd` and six actual native captures provide release gates. No T13 rig is an approved game NPC.

**M11 T14 provisional anatomy side-by-side review (creator decision PENDING):** Run `scenes/m11_t14_creator_anatomy_review.tscn` independently from Chapter I. This native review renders the true weighted-skinned H-A and H-B engineering alternatives with data cards for T08/T10 assumptions. Buttons 0/1/2 focus both, H-A or H-B; no automatically approved body or constructed H-C hybrid. The decision is reserved for explicit creator written approval after scientific review. Offline gate `python3 godot/tools/validate_m11_t14_anatomy.py`, adversarial tests `python3 -m unittest discover -s godot/tests -p 'test_m11_t14_anatomy.py'`, native smoke `godot --headless --path godot --script res://tests/m11_t14_review_smoke.gd`. See [T14 review](../MEDIA/M11_T14_CREATOR_ANATOMY_REVIEW_AND_DECISION_GATES.md).

**M11 T16 bounded evolutionary reconstruction:** `scenes/m11_t16_evolutionary_lab.tscn` creates **E1 river margin, E2 material work, E3 protected-route** alternative 43-bone skinned pre-K–Pg body graphs using parent-local ancestor reference morphometrics, restrained texture/soft-tissue visualizations and deterministic GDScript poses. Run `python3 godot/tools/m11_t16_evolutionary_models.py --check`; `godot --headless --path godot --script res://tests/m11_t16_evolutionary_smoke.gd`; reproducible three independent skin-weighted GLBs via `python3 godot/tools/m11_t16_export_glb.py --out ./m11-t16-evolved-glb`. `scenes/m11_t16_experimental_inhabitants.tscn` puts the 3 real skinned rigs alongside original M2–M5 source assets for **research only**. Normal Chapter I does **not** import or instantiate the experimental module at all; open the isolated T16 research scene instead. This avoids modifying Web performance or shipping unapproved characters. No T14 anatomical decision, true evolutionary prediction, production model or scene fit is claimed. [T16 scientific methods and limitations](../MEDIA/M11_T16_EVOLUTIONARY_INHABITANT_MODELS.md).

**M11 T15 imported-settlement geometry audit (not canon or traversability):** `scenes/m11_t15_settlement_geometry_lab.tscn` loads the actual original M2/M3/M4/M5 GLBs and uses their original imported triangles for a 3D physics-intersection study. Source SHA-256, mesh counts, triangles, UV surfaces and dimensionless H-A/H-B envelope variants are inspectable. Controls 1–4 select a source, 5–7 filter hypotheses, S rotates deliberately unverified body/asset ratios and C queries five synthetic points at each ratio. A collision is **not** a blocked historical door; a noncollision is **not** a verified path. Run `python3 godot/tools/validate_m11_t15_geometry.py`, `python3 -m unittest discover -s godot/tests -p 'test_m11_t15_geometry.py'`, `godot --headless --path godot --script res://tests/m11_t15_settlement_smoke.gd`; Godot CI captures four real original-asset scene views. No published Chapter I changes. See [T15 engineering evidence](../MEDIA/M11_T15_ORIGINAL_SETTLEMENT_GEOMETRY_AND_BODY_PROBES.md).

**M11 T13 provisional rig/skin/animation engineering (NOT CANON):** `scenes/m11_t13_skinned_character_lab.tscn` is an isolated skinned 43-control H-A/H-B comparison, built on the original T07 skeleton. It has two LODs, three procedural albedo/roughness material variants, five deterministic movement/posture cycles, collision proxies, a GLB export/round-trip script and native capture tests. The pre-K–Pg characters' proportions, feather distribution, muscles and performance are illustrative, not approved science; the five cycles are not GLB-baked. Run `godot --headless --path godot --script res://tests/m11_t13_skinned_lab_smoke.gd` and `godot --headless --path godot --script res://tests/export_m11_t13_glb.gd`; CI also renders three real Godot images. Controls 0/1/2 for H-A/H-B comparison, 3–7 for motions, L for LOD and V for appearance. See [T13 engineering and creator context](../MEDIA/M11_T13_PROVISIONAL_SKINNED_RIG_AND_CONTEXT_GATES.md). Creator-restated Harvest contact and matter/technology co-development are separate from H-A/H-B art and are reflected in `CANON.md`/`ALCHUL.md`.

**M11 T12 real Earth through 2026 + six provisional individuals:** `scenes/m11_t12_era_people_lab.tscn` is a separate research-only Godot viewer. Press `R` for nine sourced regional time-slices (default **present-day New Madrid**, correctly on the North American plate), `P` for six candidate pre-K–Pg functional people, and number keys to select. It never claims fossil non-avian dinosaur survival, modern descendant anatomy, locked H-A/H-B body plan, human sex/caste jobs, an exact ancient cave or a known present-day hidden site. Run `python3 godot/tools/validate_m11_t12_science_first.py --check`, `python3 -m unittest discover -s godot/tests -p 'test_m11_t12_science_first.py'`, and `godot --headless --path godot --script res://tests/m11_t12_lab_smoke.gd`. Science baseline: [Earth history to 2026](../RESEARCH/SCIENCE_FIRST_EARTH_TO_PRESENT_T12.md); profile atlas: [T12 report](../MEDIA/M11_T12_SIX_INHABITANTS_SCIENCE_FIRST_ATLAS.md). Abstract task markers are **not anatomical depictions**.

**M11 T11 reproductive oxygen / nursery screen:** `scenes/m11_t11_reproductive_lab.tscn` shows seven fully provisional scenario curves (keys `1`–`7`) for internal/external oxygen capacity indices, maternal burden and nursery moisture/heat gates. Fixed 75% refers to **developmental progress**, not gestation time. Use `python3 godot/tools/m11_t11_reproduction.py --check`, `python3 -m unittest discover -s godot/tests -p 'test_m11_t11_reproduction.py'`, and `godot --headless --path godot --script res://tests/m11_t11_lab_smoke.gd`. Source evidence and unknowns: [T11 report](../MEDIA/M11_T11_REPRODUCTIVE_GAS_NURSERY_CONSTRAINTS.md). This isolated laboratory does not modify Chapter I or establish egg anatomy, oxygen pressures, clutch size or sex roles.

**M11 T10 force feasibility and corridor lab:** `scenes/m11_t10_corridor_lab.tscn` independently displays normalized T07 body turns against a hypothetical L-shaped passage (no surveyed city dimensions), while `tools/m11_t10_mechanics.py` performs 2D backed-fixture force balance, friction and distal torque *proxy* checks and six-step contact transfer/clearance calculations. Run `python3 godot/tools/m11_t10_mechanics.py --check`, `python3 -m unittest discover -s godot/tests -p 'test_m11_t10_mechanics.py'`, and `godot --headless --path godot --script res://tests/m11_t10_lab_smoke.gd`. `SPACE` plays the diagram, arrows step and `C` changes trial width. No real force-closed grip, biological gait, verified muscle limits, or game NPC is established. [T10 validation boundaries and reproducibility](../MEDIA/M11_T10_BIOMECHANICS_FORCES_AND_CORRIDOR_VALIDATION.md).\n\n**M11 T08–T09 analysis lab:** `scenes/m11_t08_t09_lab.tscn` is a separate, noncanonical Godot view of T07 bones plus **model-only** COM markers, assumed foot-support rectangles and fingertip fixture proxies. Run `python3 godot/tools/m11_t08_t09_analysis.py --check`, `python3 -m unittest discover -s godot/tests -p 'test_m11_t08_t09.py'`, and `godot --headless --path godot --script res://tests/m11_t08_t09_lab_smoke.gd`. Space cycles cases; G switches near/far. No physical grip, muscle mechanics, dynamic gait or scientific validation is claimed. See [T08–T09 engineering and science report](../MEDIA/M11_T08_T09_BALANCE_CONTACT_STUDY_AND_GATES.md).

**M11 T07 skeletal lab:** `scenes/m11_t07_joint_lab.tscn` contains two standalone Godot `Skeleton3D` references (43 named control bones each) with conservatively bounded joint test actions. This is a noncanonical engineering test, not skinned character animation or validated biomechanics. Verify with `python3 godot/tools/validate_m11_t07_skeleton.py` and `godot --headless --path godot --script res://tests/m11_t07_joint_smoke.gd`. Controls 0/1/2 select both/H-A/H-B. See [T07 skeletal and joint report](../MEDIA/M11_T07_SKELETAL_JOINT_ARCHITECTURE_AND_QA.md).

**M11 provisional anatomy lab:** `scenes/m11_anatomy_lab.tscn` is an independently launchable scientific concept scene comparing H-A and H-B and **not part of Chapter I**. The script `scripts/m11_anatomy_lab.gd` reads `data/m11_anatomy_candidates.json` and depicts nonmetric schematic forms. Use `0` (both), `1` (H-A) or `2` (H-B). Run `python3 godot/tools/validate_m11_anatomy.py` and the native `tests/m11_anatomy_lab_smoke.gd` before interpreting any screenshot. See [M11 lab implementation and limitations](../MEDIA/M11_LAB_IMPLEMENTATION_01.md).

**Windows, Linux and unsigned macOS builds** are generated through `.github/workflows/alchul-desktop-build.yml`. The game's Chapter I source is now merged into `main` (original review branch: `game-braided-reach-complete-chapter-20261119`). Download the three platform artifacts from the passing CI workflow or the associated ALCHUL Drive release folder. Windows: run `Alchul.exe`; Linux: run `Alchul.x86_64`; macOS: open the unsigned application subject to OS protection. No Godot editor installation is required to play.

**Controls:** WASD/arrows move; right-drag look; Shift faster; E examine; Tab field journal; H help; Escape pause; 1/2/3 select interpretive lens. Inspect bank, nursery, Harvest and witness circle, then return to the bank to finish. Saves reside in the platform's Godot user-data directory; no network activity.

Tests: `tests/chapter_full_loop_smoke.gd`, `tests/render_chapter_states.gd`, original native `tests/smoke.gd` and ten-view `tests/render_m7.gd`. See `../MEDIA/CHAPTER_I_PLAYABLE_RELEASE.md` for scope and scientific caveats.


This native Godot 4 workspace is **inside** the authoritative Alchul repository. It has no submodules, network fetches, live dependencies on other GitHub repositories, or hidden media services. It is a first environmental/interaction proof, **not** a finished game or final depiction of any historical individual.

## Open locally

1. Install a compatible **Godot 4** editor locally.
2. Open/import \`godot/project.godot\`.
3. Run the main scene (F6) or project (F5).

From the repository root, with a Godot executable available:

\`\`\`sh
godot --path godot --editor
godot --path godot
\`\`\`

Some installations name the executable \`godot4\`. The renderer is configured for the **Godot 4 Compatibility** rendering method to reduce hardware requirements. This is a design choice, not proof that web export works.

## Controls

- **W/A/S/D** or arrow keys: move the visiting observer.
- **Right mouse drag**: look around.
- **Shift**: move faster.
- **E**: inspect the nearest marked place.
- **1 / 2 / 3**: select Outside / Resident / Contact Reports lens.
- **Escape**: release pointer state.
- Buttons in the on-screen dock provide the same lens choices.

The observer camera is **not** a direct simulation of Alchul sight. It is an outside-accessible camera with text translations of what one period-specific inhabitant might find salient.

## What the first scene is

A small riverbank research stage with terrain relief, a sinuous water margin, flora placeholders, a provisional nonhuman study figure, a nursery access, a water-reading platform, a Harvest preparation site, and a contact-report circle. The environment is a **fictional composite**, not a geological survey. No visible object is the being Alchul.

\`data/worldbook.json\` contains the displayed status and three interpretations for the marked places. It travels with the exported project: no runtime access to Alchul's Markdown files or another repository is necessary.

## Validation

\`\`\`sh
python3 godot/tools/validate_worldbook.py
godot --headless --path godot --script res://tests/smoke.gd
\`\`\`

The Python standard-library checker validates the local manifest and files; the Godot command requires a Godot 4 installation and checks the scene. **These tests must be run before claiming the scene is functional.**

A Git checkout on its own is not a runnable deployed website. No Vercel endpoint is configured.

## Next native modules

- Character rigs, movement calibration, physically plausible three-digit articulation
- Atmosphere, water-route and substrate sensing systems (measured environmental behavior vs interpretive overlays)
- Multi-individual household/community simulation and event records
- Surface / First Below / post-K–Pg era separation
- Local asset and scene-build registry with reproducible provenance
- Optional Godot web and cinematic exports *after* runtime validation

Do not copy code, media, or build tools from other repositories into this folder without a distinct provenance/permission review. See \`../CENTRALIZATION.md\` and \`PROVENANCE.md\`.

## Batch 10 — Original 3D station and 28 authentic PBR maps (review branch only)

The M10 branch now carries **exact original source assets**, with no network downloads at runtime:

- `assets/m2/ALC_M2_RIVER_STATION_v001.glb` — original River-Reading Station GLB, first-party, verified SHA-256.
- `assets/m6/textures/ALC_M6_*_768.png` — all 28 original 768px M6 albedo/normal/roughness/height maps. Source hashes pinned in `data/m10_m6_archive_manifest.json`.
- `scenes/m10_import_pilot.tscn` — **separate, unapproved** original-source Godot review stage. This does **not** replace `scenes/main.tscn`.
- `scripts/materials_m7.gd` automatically prefers the real M6 albedo/normal/roughness maps in the original procedural world once they exist; fallback maps are retained for absent-source robustness. M6 height maps are archived but not bound in the native material pass.

**M2 is unwrapped, with no UVs**. This pilot preserves its original vertex color data, and displays the real M6 PBR textures on seven intentionally UV-ready native sample objects; it does not pretend the station has UV coordinates.

Run with official Godot 4 after an import pass:

```sh
godot --headless --path godot --editor --import --quit
godot --path godot res://scenes/m10_import_pilot.tscn
godot --headless --path godot --script res://tests/m10_import_smoke.gd
```

CI also captures ten actual engine screenshots from `tests/render_m10.gd`; review its artifacts before any release or accepting the geometry. The source M6 UV-ready GLB is **not** yet tracked due upload size; source copies remain verified in Drive. See `../MEDIA/M10_ORIGINAL_SOURCE_IMPORT_AND_VALIDATION.md`, and `PROVENANCE.md` for limitations.
