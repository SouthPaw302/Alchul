# Alchul

**The central and independent home for the Alchul universe and its native Godot 4 world.** This repository now contains authoritative lore, research, a first Godot runtime study, self-contained scene data, tests, and its own validation workflow.

**Start here:** [Centralization policy](CENTRALIZATION.md) · [Native Godot project](godot/README.md) · [Prototype provenance](godot/PROVENANCE.md) · [Read-only prototype audit](godot/PROTOTYPE_AUDIT.md).

### Run in a browser — no local installation required

The native Godot 4 project **passes its engine smoke test**, and a single-threaded **Godot Web export builds successfully in GitHub Actions**. Use [the no-local publishing instructions](godot/WEB_PUBLISHING.md).

A GitHub Pages publishing workflow has been added at [.github/workflows/alchul-pages.yml](.github/workflows/alchul-pages.yml). The build and artifact upload passed, but publishing is **blocked only because GitHub Pages has not yet been enabled** for this repository. To allow the cloud deploy, open [Alchul Settings → Pages](https://github.com/SouthPaw302/Alchul/settings/pages), choose **Source: GitHub Actions**, then [rerun the publishing workflow](https://github.com/SouthPaw302/Alchul/actions/workflows/alchul-pages.yml) against `main`. The expected address after a successful deploy is `https://southpaw302.github.io/Alchul/` (not verified live yet).

Vercel project creation returned **HTTP 403**, so no Vercel project was created. Previous repositories were not touched.


To run after pulling this GitHub branch into your local checkout:

```sh
python3 godot/tools/validate_worldbook.py
godot --path godot --editor
godot --path godot
```

Requires a locally installed Godot 4 executable (possibly named `godot4`). This does **not** fetch or clone any other user repository, and there is no configured Vercel deployment. The world scene is a **working noncanonical study**, not a finished game. The native Godot engine smoke test is defined in `godot/tests/smoke.gd` and the Alchul-only GitHub workflow.

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
