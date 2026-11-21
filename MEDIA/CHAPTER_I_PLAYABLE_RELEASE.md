# ALCHUL — The Braided Reach · Chapter I

**Version:** 1.0.0 — complete standalone **exploration chapter**  
**Date:** November 19, 2026  
**Status:** Playable self-contained field expedition; historical material is explicitly a fictional/scientific reconstruction, **not approved character/canon**.  
**Scope:** Current available M1–M10 first-party environment, original M6 PBR maps, four existing worldbook sites and native Godot mechanics. No new source art, no external API, no online dependency, no copied projects.

## What is finished in this chapter

- Native Windows 64-bit, Linux x86_64 and unsigned macOS universal standalone applications, from one pinned Godot 4.7.2 export pipeline.
- Opening menu, new expedition and continue saved game. The scene is the original Braided Reach world with authored M1–M8 environment modules, 28 archived source material maps and optimized opaque static geometry.
- Four places visitors can physically reach: river-reading station, nursery approach, Harvest processing, and testimony circle. Stone markers and a live field-map pinpoint each place without inventing new canon architecture.
- Contextual `E` examination: three explicit interpretations (outside structural evidence, resident lived-work interpretation, and unclosed contact testimony) drawn **verbatim from** `godot/data/worldbook.json`.
- An interactive finite objective: record all four places, **return to the bank**, and finish the expedition by comparing the accounts. No repetition or grinding required.
- Real map with river and moving visitor heading; progress status and dynamic nearest location distances.
- Saved expedition progress on the local machine, resume option, field journal, pause/help, lens controls and replay.
- A story-complete ending centered on experimental uncertainty, shared care, cumulative work and ecological engineering—not on premature disclosure of Alchul's ontology.

## Controls

`WASD` or arrow keys walk; `Shift` faster; right-drag to look; `E` read marker; `TAB` open/close journal; `H` help; `Escape` pause; `1`/`2`/`3` switch lenses. `Enter` dismisses a field entry.

## Scientific integrity

Site descriptions are read from the existing local worldbook and preserve its provisional status. The game does not prove a real Cretaceous civilization, an exact evolved body plan, a geographic settlement, a technological method, Alchul's identity or the late-egg-retention mechanism. `CANON.md` and `SPECIES.md` remain untouched. The interpretive camera is an outside visitor. The 3D figure is an unapproved silhouette rather than approved character anatomy. No source scene has been silently replaced by the isolated no-UV M2 GLB asset pilot.

## Acceptance evidence

- `godot/tests/chapter_full_loop_smoke.gd`: real Godot native test instantiating the playable scene, testing title freeze, start, all four separate source-grounded observations, journal, save/reload, return-to-bank ending, replay and pause.
- `godot/tests/render_chapter_states.gd`: five **actual Godot-generated native screenshots** (title, exploration, recorded bank, journal, conclusion), not conceptual art. CI workflow uploads evidence.
- `godot/tests/render_m7.gd`: the original ten matched world-only camera views, with new UI temporarily hidden so original geometry baselines remain directly comparable. M10 untouched-source model and real material hashing gates remain.
- `godot/tools/build_desktop.sh` and `.github/workflows/alchul-desktop-build.yml`: native executable exports for 3 OS families, hash/ZIP validation and a real Linux desktop boot test. Windows/macOS are not signed, notarized or tested on physical machines by GitHub CI.
- `godot/scripts/game_loop.gd` handles menu, gameplay, evidence, persistence and conclusion; `godot/scripts/game_map.gd` draws the actual local site pins and river.

## Completion boundary

This is **a finished Chapter I based on available assets**, not a claim that the larger ALCHUL world, deep-era chronology, creature rigs, cinematic art, accessible controls, full voiceovers, or 66-million-year society are complete. Those creative strands continue independently, and no further game-engine work is required merely to resume the universe's historical development. Public distribution beyond source/review copies should add actual-device QA, platform signing and notarization, license audit, package hosting and user feedback.

## Build/release references

- Game branch: `game-braided-reach-complete-chapter-20261119`.
- Stacked game PR: #5 (on candidate M10 PR #3; M9 PR #2 is earlier dependency). Preserve review until release gates passed.
- Desktop CI and screenshot job report actual exact SHA. Do not claim the published GitHub Pages site has been updated because this desktop app is separately packaged.
