# Agent Boot

Before writing, researching, designing, or modifying canon:

1. Read `README.md`.
2. Read `CANON.md`.
3. Read `TIMELINE.md`.
4. Read `SPECIES.md`.
5. Read `ALCHUL.md`.
6. Read `CIVILIZATION.md`.
7. Read `DEEP_EARTH.md`.
8. Read `VISUAL_CANON.md`.
9. Read relevant files in `RESEARCH/`.
10. Read `ARCHIVE/SESSION_2026-09-28_29_ORIGIN.md` when reconstructing intent, unresolved questions, or conversation history.
11. Read prose only after canon and research.

## Rules

- Treat Git as canonical authority.
- Do not turn the founders into generic "raptors," birds, or reptilian humanoids.
- Do not assume human-style civilization, technology, writing, government, industry, or spacecraft.
- Do not define Alchul's true nature.
- Real science and in-universe interpretation must remain visibly separate.
- `RESEARCH/` may contain only sourced real-world research and explicit inference labels.
- When evidence is uncertain, record uncertainty instead of silently inventing certainty.
- New canon should grow causally from biology, environment, culture, and prior canon.
- The civilization is already significantly advanced before the Long Descent.
- Geological sensing is subtle perception of stress, pressure, heat, gas, water, fracture, and material readiness—not early telekinesis.
- The mature luminous deep world is partly created by the civilization through ecological and environmental transformation.
- Present-day descendants must reflect ~66 million years of evolution, divergence, self-modification, and contact with other Earth life. Do not freeze founder morphology.
- Writing voice: reconstructed history/natural history, plain visual prose, cause-and-effect, minimal exposition, no fantasy-lore voice.

## Centralized native runtime rule — 2026-11-09

The only active Alchul universe/runtime source is this repository: `SouthPaw302/Alchul`. See `CENTRALIZATION.md`, `godot/README.md` and `godot/PROVENANCE.md` before touching rendering, assets, build or engine code.

- Native Godot 4 project lives in `godot/`. Do not make the world depend on another user's repository, checkout, networked API, submodule or externally managed asset bundle.
- Other prototypes (including GodRender and the earlier Alchul browser console) are **read-only references**. Never edit them or silently import their media/code/build systems; user preference explicitly protects them.
- A locally installed Godot engine is a toolchain requirement, not an imported application repository. Keep runtime scene data and assets in Alchul.
- Run `python3 godot/tools/validate_worldbook.py` and, with Godot installed, `godot --headless --path godot --script res://tests/smoke.gd` before claiming validated scene behavior.
- Explicitly state whenever only GitHub source was changed; a local user's checkout is not automatically updated, and a GitHub CI result is not a live deployment.
- Preserve locked lore canon separately from experimental scene/character choices.
