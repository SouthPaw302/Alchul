# ALCHUL — Chapter I 1.1: The Braided Reach Gameplay and Visual Rebuild

**Date:** 2026-11-23. **Status:** candidate implementation, undergoing native CI and visual acceptance; no canon or historical date promoted.  
**PR:** [#15](https://github.com/SouthPaw302/Alchul/pull/15).  
**Media archive:** [Drive — Chapter I 1.1](https://drive.google.com/drive/folders/1dekaiLmENEAtx40OKz_KDBVViXRMiDFh).  
**Production authority:** `CANON.md`, `ALCHUL.md`, `RESEARCH/SCIENCE_FIRST_EARTH_TO_PRESENT_T12.md`, and `godot/data/worldbook.json`.

## 1. Why the upgrade was necessary

The first playable chapter reached a complete four-location state but remained much too close to an exploratory software prototype. Real visual review showed a dense, scene-obscuring HUD, oversized media-export dropdown, text-heavy opening and generic primitive vegetation/architecture. Interaction was largely a walk-and-read activity despite the richer scientific method established in the fiction. The replacement is an **actual modification of the public game's source**, not an offscreen marketing mockup or another character concept.

## 2. Delivered changes

1. **A coherent starting environment.** The game now opens in its integrated M7–M8 geography (`OriginalFirstPartyMediaAtlas.select_stage(0)`) rather than forcing the independent M1 source model. All six original M1–M6 GLB source studies are preserved, importable and testable under the optional source inspector (F8, F1–F7).
2. **Cinematic, readable UI.** Concise introduction and call to action; the native field HUD occupies less of the 1280×720 screen, with optional map visibility (M) and optional source media inspector (F8). Material/resident/contact interpretation lenses remain explicitly separate.
3. **Visible destination context.** Four named visitor-navigation landmarks and source-neutral field markings; no unapproved historical sign or Alchul figure is introduced.
4. **Native visual uplift.** Procedural sky/late-day lighting, light distance mist, 360 extra deterministic reed instances, and 142 multi-lobed canopy/trunk formations using four batched `MultiMeshInstance3D` groups. Early uniform cone trees remain unmodified in archival geometry, but are hidden from the released scene. Actual original M6 PBR albedo/normal/roughness families are applied to the native generated study meshes where UV material support exists, preserving the source GLBs and 28 texture files.
5. **Four playable site-comparison activities.** A player-controlled HSlider tunes two simulated, normalized physical-control signals. The task is to distinguish a strong repeatable difference from the control trace at bank, nursery, Harvest and witness sites; weak/untuned readings cannot be archived. The witness-site task explicitly states that contact testimony is **not** measured physical evidence.
6. **Progress and saved state.** Four original evidence entries and four optional successful paired comparisons are tracked independently in the same `alchul.braided-reach-save.v1` format. The added optional `surveyed` array is backward-compatible with earlier local progress. New journey resets evidence and comparisons; older Chapter I return-to-bank conclusion remains accessible without requiring an invented perception mechanism.
7. **No cartoon placeholder NPC.** The primitive body candidate is not rendered as a historical inhabitant in Chapter I. The separate T13 real skinning laboratory still exists; none of its shapes is approved.
8. **Native acceptance evidence.** New `godot/tests/chapter_v2_play_smoke.gd` tests actual four-site instrument interaction, rejection cases, UI, local persistence, four waypoints, source PBR fidelity and provenance. Native Godot capture `godot/tests/render_chapter_states.gd` now produces six real 1280×720 screens: title, exploration, site evidence, field instrument, journal and finale. Existing M1–M6 exact triangle/source import test and chapter smoke remain mandatory.

## 3. How to play Chapter I 1.1

**Controls:** WASD/arrows move, right-drag look, Shift move faster, E examine nearby marked site, M show/hide field map, Tab journal, 1/2/3 change material/resident/testimony lens, F8 optional original media inspector; F1–F7 source comparisons; Esc pause. At each site choose **Run paired field study**, move the dial to distinguish the gold condition from the blue reference, and record the comparison. Return to the river bank after observing all four sites to complete the chapter.

## 4. What this does NOT establish

- A historical New Madrid civilization or non-avian dinosaur survivor is not real-world archaeological evidence.
- No specific extinct species, valid anatomy, communications organ, true measured chemical or physical field reading, or real supernatural/Alchul mechanism has been demonstrated.
- The native Game Chapter I is an undated **fictional mature surface-era** reconstruction, *not* a current-day inhabited settlement and *not* a completed independent geological timeline.
- The waveform's 0–100 display is dimensionless **interactive teaching fiction**, not material strength, Hertz, field voltage, respiration, geography, or genuine scientific instrument data.
- This is a stronger playable stylized research game, not proof of final photorealistic art quality. Continued graphics development needs improved source topology/UVs, calibrated photometric lighting, deliberate art direction, real shaders, independent texture acceptance, asset optimization, and approved anatomy before populated scenes.

## 5. Acceptance and publishing

Required before merge: previous Chapter I native smoke, new V2 native smoke, original six M1–M6 source triangle tests, independent M7 native visual regression, six actual native Chapter I screenshot captures, Chromium Web preview, Windows/Linux/macOS desktop PR CI. Validate screenshot composition visually, not by self-reported build success alone.

When approved, merge PR #15 to `main` and verify **three distinct actions** on merge: native engine, standalone Web export and GitHub Pages publishing. The live URL is https://southpaw302.github.io/Alchul/. A passing PR is not a published update; even a successful Pages action is not a guarantee of mobile/hardware rendering quality.

This chapter quality task is a **separate user-prioritized interlude before T14**. Do not mark creator anatomy approval as passed, or replace character placeholders with research models without the creator's decision.
