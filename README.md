# Alchul

**The central and independent home for the Alchul universe and its native Godot 4 world.** This repository contains authoritative lore, scientific research, a playable native Godot Chapter I, the integrated M1–M6 first-party media atlas, M11 comparative anatomy research, local scene data, and native validation workflows.

**Science-first operating rule:** [Reconstruct the real Earth from the Late Cretaceous through the present (2026)](RESEARCH/SCIENCE_FIRST_EARTH_TO_PRESENT_T12.md), with its source limitations, **before** overlaying [T12 six provisional inhabitants](MEDIA/M11_T12_SIX_INHABITANTS_SCIENCE_FIRST_ATLAS.md) or imagined later history. Fossil evidence never establishes non-avian dinosaur survival beyond K–Pg, and the New Madrid seismic zone is an intraplate system within the North American plate. The hidden civilization is explicitly in-universe fiction.

**T14 body-plan approval review (creator decision PENDING):** [H-A / H-B / unbuilt hybrid anatomy evidence](MEDIA/M11_T14_CREATOR_ANATOMY_REVIEW_AND_DECISION_GATES.md) with a real standalone Godot skinned-mesh comparison, six unresolved biological/ergonomic gates and independent adversarial contract tests. This does **not** approve a character body, alter `CANON.md`, or turn any mature-surface candidate into a modern descendant.

**Chapter I 1.1 gameplay and art upgrade (2026-11-23):** [The revised Braided Reach chapter](MEDIA/CHAPTER_I_V1P1_GAMEPLAY_VISUAL_REBUILD.md) defaults to a coherent playable landscape with a compact immersive HUD, original M6 source PBR textures, 142 instanced multi-lobed tree forms, four physical waypoints and four optional interactive paired-control experiments. This remains a stylized reconstruction, not approved species anatomy. [Public Pages](https://southpaw302.github.io/Alchul/) reflects the change only after the new PR is merged and publishing passes.

**T17 physical sensing prototype (merged 2026-11-23):** [Six ordinary physical stimulus classes and four independent proxy readers](MEDIA/M11_T17_PHYSICAL_SENSING_CAUSAL_ENGINE.md) with a replayable false-positive demonstration. No physical Alchul detection, new organ or Chapter I UI changes.

**T16 evolutionary reconstruction (merged 2026-11-23):** [Three separately constrained, reproducible mature-surface anatomy hypotheses](MEDIA/M11_T16_EVOLUTIONARY_INHABITANT_MODELS.md) link fossil-informed theropod controls, physical functional ecology, lineage morphology, 72-case sensitivity tests and live Godot skeletal models. They reside strictly in isolated native research scenes, not the playable chapter or Web build; neither a modern descendant body nor creator anatomy approval is being inferred.

**T15 original-settlement geometry research (merged 2026-11-23):** [Actual M2–M5 imported triangle-mesh intersection audit](MEDIA/M11_T15_ORIGINAL_SETTLEMENT_GEOMETRY_AND_BODY_PROBES.md) runs H-A/H-B synthetic, uncalibrated geometric envelopes against actual first-party Godot mesh physics; no species anatomy or corridor clearance is proven. [PR #18](https://github.com/SouthPaw302/Alchul/pull/18) passed offline, native, desktop and Chromium Web PR checks; [actual Godot screenshots and study source archived to Drive](https://drive.google.com/drive/folders/11jUeNGrx-3alWqk935bsc10oYu7PDHx8). The T14 creator decision remains open and Chapter I content is not modified by this research.

**Latest T13 technical milestone (merged 2026-11-23):** [Noncanonical skinned H-A/H-B anatomy and motion prototypes](MEDIA/M11_T13_PROVISIONAL_SKINNED_RIG_AND_CONTEXT_GATES.md) with two Godot Skeleton3D-weighted 43-control rigs, five programmatic motion cycles, two LODs, three PBR study materials, real engine screenshots and two GLB skin exports. [GitHub PR #14](https://github.com/SouthPaw302/Alchul/pull/14) passed native, Chromium Web and desktop CI; assets are [archived on Drive](https://drive.google.com/drive/folders/12MUqdfvCfZq4v-B87LQlTv7aAAs5EoIt). No biological approval, finished production character, or present-day descendant is implied. The creator's reciprocal Harvest/Alchul perceptual aperture and matter-sensing/technology co-evolution are documented in `CANON.md`, `ALCHUL.md`, `TIMELINE.md` and `CIVILIZATION.md` without defining Alchul.

**Previous research milestone:** [T11 reproductive gas and nursery constraint study](MEDIA/M11_T11_REPRODUCTIVE_GAS_NURSERY_CONSTRAINTS.md) — provisional, independent Godot study and reproducible dimensionless screening; no approved organ anatomy or biological viability claim.

**Post-merge implementation:** [35-step master plan](MEDIA/ALCHUL_POST_MERGE_IMPLEMENTATION_MASTER_PLAN.md) · [M11 comparative anatomy lab](MEDIA/M11_LAB_IMPLEMENTATION_01.md) · [M11 Godot lab scene](godot/scenes/m11_anatomy_lab.tscn).

**Start here:** [Centralization policy](CENTRALIZATION.md) · [Native Godot project](godot/README.md) · [Prototype provenance](godot/PROVENANCE.md) · [Read-only prototype audit](godot/PROTOTYPE_AUDIT.md).

### Browser preview and public site — independently validated

The playable desktop Chapter I source and its original-media atlas are now merged into **main**. The independent Godot 4 native checks have passed on the new M11 comparison implementation; the desktop export and browser pipeline remain separate release surfaces. Use [the no-local publishing instructions](godot/WEB_PUBLISHING.md) for Web builds.

The [GitHub Pages publishing workflow](.github/workflows/alchul-pages.yml) triggers on relevant changes to `main`. The [public ALCHUL site](https://southpaw302.github.io/Alchul/) is an independently deployed browser release surface; **do not assume it matches Chapter I merely because the code was merged**. Verify the latest publish workflow and site build before advertising a current-game release. The browser performance budget remains separate from native validation.

Vercel project creation returned **HTTP 403**, so no Vercel project was created. Previous repositories were not touched.


To run after pulling the repository's current `main` branch:

```sh
python3 godot/tools/validate_worldbook.py
godot --path godot --editor
godot --path godot
```

Requires a locally installed Godot 4 executable (possibly named `godot4`). This does **not** fetch or clone any other user repository, and there is no configured Vercel deployment. The current Chapter I is a **playable, finite exploration game**, not completion of the wider Alchul universe or approval of provisional species anatomy. The native Godot engine smoke test is defined in `godot/tests/smoke.gd` and the Alchul-only GitHub workflow.

Canonical repository for the Alchul universe.

This project is written as reconstructed natural history and deep-time history. Real geology, paleontology, evolution, ecology, and human folklore are researched separately from in-universe interpretation.

## Core rule

The world is built from evidence outward.

Real-world facts are documented as research. Fictional history is layered on top without changing the underlying science unless canon explicitly says so.

## Current focus

The first continuously occupied underground frontier after the peak surface civilization, before the final Long Descent. The founder population remains a Late Cretaceous Appalachian maniraptoran/dromaeosaur-grade lineage associated with the northern Mississippi Embayment / future New Madrid region.

**Phase 1 completed (2026-11-09):** research-grounded constraints in `RESEARCH/FIRST_BELOW.md` and a nonbinding settlement model in `WRITING/SETTLEMENT_02_FIRST_BELOW_WORKING_RECONSTRUCTION.md`.

**Phase 2 corridor pass (2026-11-09):** selected a *working regional candidate* on the southeastern Ozark carbonate margin, documented evidence and uncertainties in `RESEARCH/FIRST_BELOW_CORRIDOR.md`, and drafted the deliberately unscaled `MEDIA/FIRST_BELOW_CROSS_SECTION.svg`.

**Phase 3 time-slice and chronicle (2026-11-09):** tested a provisional early–middle Maastrichtian window centered ~70 Ma in `RESEARCH/FIRST_BELOW_TIME_SLICE_70MA.md`, then wrote `WRITING/CHRONICLE_02_THE_SECOND_BREATH.md` as **nonbinding narrative**. No actual Cretaceous cave site, permanent-occupation date, storyline, shoreline, settlement population or exact subsurface anatomy has been promoted into canon.

## Repository layers

- `CANON.md` — locked in-universe facts
- `TIMELINE.md` — deep-time historical sequence
- `SPECIES.md` — biology and evolutionary development
- `ALCHUL.md` — observed effects and interpretations; identity remains unresolved
- `CIVILIZATION.md` — culture, technology, social systems
- `DEEP_EARTH.md` — subterranean world and later expansion
- `VISUAL_CANON.md` — approved morphology and visual constraints
- `RESEARCH/` — sourced real-world research
- `WRITING/` — prose, chapters, scenes, drafts
- `AGENT_BOOT.md` — required reading order for future agents

## Inside-out civilization study — three lenses (2026-11-09)

The next creative focus is no longer only archaeological chronology: **what it is like to inhabit the world as these people**, how their evolved bodies structure space, how multiple beliefs and moral traditions form, and how their descendants reinterpret history. Begin with:

- `LORE/EMBODIED_WORLDVIEW_ATLAS.md` — outside anatomy / resident sensory life / Alchul-associated testimony, with era distinctions;
- `LORE/BELIEF_HISTORY_ARCHETYPES.md` — candidate traditions, contested myths, ritual, kinship, seven story archetypes (not an approved pantheon);
- `LORE/THREE_LENS_3D_STORYBOARD.md` — annotated 3D viewpoints and integrity rules for the interactive console;
- `WRITING/PERSPECTIVES_01_THE_SAME_CHAMBER.md` — one event told by external observer, resident, witness and later descendant.

**Status:** exploratory lore and narrative, **not canon promotion**. Actual Alchul viewpoint remains unknowable. **Historical prototype note:** an earlier companion browser console offered Outside / Resident / Contact Reports lenses. The newly centralized Godot runtime implements its *own* interpretation controls and scene data. The previous console is not an Alchul runtime dependency, and its source is not imported.

## Mature surface individual and working 3D anatomy (2026-11-09)

The next inside-out study is **Tesh**, a deliberately provisional adult surface reader. Relevant files:

- `RESEARCH/MATURE_SURFACE_BODY_EVIDENCE.md` — comparative biomechanics, feathers, hands, respiration, sensory analogy and late egg retention, with uncertainty gates;
- `LORE/INDIVIDUAL_01_TESH_BODY_AND_LIFE.md` — individual profile, nonhuman body, social relationships and five lived contexts;
- `WRITING/SCENE_03_FIVE_DISTANCES_AROUND_TESH.md` — five scenes from external observation through work, nursery, disagreement and contact testimony.

**Historical prototype note:** a former companion browser model explored Tesh's anatomy and activities. The new self-contained `godot/` environment contains a *separate native study silhouette*, not a direct copy of that implementation. Species-specific measurements and receptor geometry remain unapproved. `CANON.md` is unchanged.
