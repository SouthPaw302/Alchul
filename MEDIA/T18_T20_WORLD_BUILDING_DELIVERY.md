# T18–T20 — The River Answered Twice: Worldbuilding Delivery

**Date:** 2026-11-23 · **Delivered:** [PR #22 merged into main](https://github.com/SouthPaw302/Alchul/pull/22), [T18–T20 Drive archive](https://drive.google.com/drive/folders/1mKZuLh-Y17EJ_6BChZN-h7tEw3Q3IVI_). **Scope:** mature surface ALCHUL, undated fictional scene. **Purpose:** build culture through scenes, not label an imaginary event as Earth history. This material is a proposed culture layer compatible with established canon, not an anatomy or language lock.

## Three linked completed worldbuilding modules

| Milestone | What now exists | Where to explore |
| --- | --- | --- |
| **T18 — The Unclosed Account** | Three kinds of account: material trace, interpreted reading and reported Alchul-linked experience, each honored but held separately | [Worldbuilding study](../LORE/T18_THE_UNCLOSED_ACCOUNT.md) |
| **T19 — The Language of Weights** | Twelve context-sensitive communication cues: substrate rhythm, body orientation, tail-bar, stillness, touch and shared work | [Proposed nonhuman signal lexicon](../LORE/T19_THE_LANGUAGE_OF_WEIGHTS.md) |
| **T20 — The Two Readings** | One river-gate incident with independent observers, blind alterations, repeatable readings, a Keeper's safe-route decision and three mutually different endings | [Branching incident](../LORE/T20_THE_TWO_READINGS.md) |

Read the complete fictional scene: [The River Answered Twice](../WRITING/T18_T20_THE_RIVER_ANSWERED_TWICE.md). Its four residents are possible people, not universal castes, fixed sex roles, or a replacement for the evolutionary T16 models. No Alchul body or narrative from Alchul's own viewpoint is portrayed.

## Explore the interactive scene

`godot/scenes/t18_t20_living_world_scene.tscn` loads the actual first-party **M2 river-station GLB** (not a new fictional site mesh), places a stylized three-reed account bed and overlays three *editorial lenses* over the **same scene**. Its physical signal values come directly from the T17 Godot sensing scene; the narrative meaning is a different layer.

- **Space:** advance the scene's four opening beats
- **L:** cycle The Trace / The Reading / The Unclosed Account
- **1:** change river flow, then investigate “The river answered”
- **2:** alter the loaded support, then investigate “The support answered”
- **3:** leave two causes active and allow uncertainty: “The account stays unclosed”
- **T:** record a blind repeat reading after an intervention; earlier records remain separate
- **R:** return to the beginning

Two readers can **disagree honestly about the same physical signals** because experience changes interpretation; the Keeper's safety action remains cooperative and the witness account is not promoted to a measured Alchul signal. Captions present the translation to players without assuming literal English or approved vocal anatomy.

The 3D reed markers are **story-signs**, not alleged excavated instruments or an in-universe global writing system. The candidate living bodies remain offscreen to avoid selecting E1/E2/E3 as a caste or prematurely certifying the mature surface anatomy.

## Reproduce (authoring and small technical sanity checks)

```bash
python3 godot/tools/validate_t18_t20_story.py
godot --headless --path godot --editor --import --quit
godot --headless --path godot --script res://tests/t18_t20_living_world_smoke.gd
godot --path godot res://scenes/t18_t20_living_world_scene.tscn
```

Native Godot's story test passed (three lenses, seven encoded signals, three endings, genuinely different readings and repeatability). The initial graphical GitHub Actions capture run rendered four genuine Godot views: account bed, opposed readings, a support answer and an unclosed account. It also archives the markdown stories, scene source and interaction data.

**Canon respected:** ALCHUL's separate real existence, the two-way Harvest opening, the evolutionary co-development of perception and matter process, nonhuman ecological language, and the distinction between testimony and physical evidence. **Not declared canon:** particular gestures, their formal grammar, characters, a legal system, dates, native vocabulary, apparatus design, a proven contact episode or an approved T16 body. These are now usable story materials, which was the requested milestone.
