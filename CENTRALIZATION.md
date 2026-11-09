# Alchul — Centralized Runtime Policy

**Established:** 2026-11-09.
**Authority:** The user's explicit direction is to centralize Alchul into one independent local repository, without touching other prototype repositories.

## Single active Alchul home

**Repository:** \`SouthPaw302/Alchul\`.
**Native engine:** Godot 4, inside \`godot/\` within this repository.
**Runtime assets:** Store scene data, material definitions, characters, simulations, shaders, audio, references and approved generated outputs here or under explicitly managed, hash-verified Alchul-owned artifact storage; never resolve another project's GitHub branch at runtime.
**Lore authority:** Existing \`CANON.md\`, \`TIMELINE.md\`, \`SPECIES.md\`, \`ALCHUL.md\`, \`CIVILIZATION.md\`, \`DEEP_EARTH.md\`, \`VISUAL_CANON.md\`. Native scene records are *derived nonbinding working reconstructions*, not an alternative canon.
**Optional web publishing:** A static Godot web export can be hosted wherever technically suitable after export validation. Vercel is not assumed, required or currently connected.
**Locally required software:** A compatible Godot 4 editor/runtime. This is a toolchain requirement, not a network connection to another repository.

## Protect the prototypes

No edits, commits, pull requests, release changes, workflow triggers, imports or refactors are authorized against any other repository by this centralization pass.

For example, \`SouthPaw302/GodRender\`, \`SouthPaw302/Alchul-Gemini-\`, and any historical AIVideoEdit projects are **read-only historical/technical references**. Reading a repository is not a permission to lift all its contents, execute its boot process, copy its dependencies, use its old media, or mutate it.

**No git submodules. No runtime GitHub fetches. No second “authoritative” rendering repo. No copying Git history. No hidden cross-repo build steps.**

A specific reusable algorithm can be reimplemented inside Alchul after reviewing functionality and provenance. If a true source import is desired in the future, record source path, source commit, exact license/permission, adaptation, local tests, and why it is necessary in \`godot/PROVENANCE.md\`. Do not silently mirror code or import media.

## How centralization proceeds

1. Inventory *existing* source systems read-only, distinguishing reusable technique from unverified or project-specific content.
2. Establish a standalone native \`godot/\` project, local data, self-contained representative scene, and tests.
3. Validate Godot on a compatible local installation; never claim a successful engine run from static inspection.
4. Build Alchul-owned assets, rigging, life simulation, multisensory overlays, geological environments, cultural interactions, and chronicle layers incrementally.
5. Keep “real research,” “locked canon,” “working reconstruction,” and “fictional character” statuses visible in both data and UI.
6. Only after native autonomy is proven, add optional *Alchul-owned* export scripts for video and browser builds. External renderers are never mandatory.

## What this initial pass creates

- \`godot/project.godot\` — engine project and input controls
- \`godot/scenes/main.tscn\` — boot scene
- \`godot/scripts/world.gd\` — provisional Braided Reach-like study environment
- \`godot/scripts/observer.gd\` — moveable human-visitor camera, not a biologically exact Alchul eye
- \`godot/data/worldbook.json\` — self-contained scene interpretation and four contextual study sites
- \`godot/tests/smoke.gd\` — native Godot smoke assertions
- \`godot/tools/validate_worldbook.py\` — Python standard-library data/project check
- \`godot/README.md\`, \`godot/PROVENANCE.md\` — launch and integrity contracts

No Godot engine executable, media pack or third-party source code is vendored at this stage. A Godot installation is needed to run it.

## Approval boundaries

- Existing canon is not edited without authorization.
- A working scene is not evidence that any exact Cretaceous cave, city or anatomy has been established.
- Do not conflate a visual depiction of an Alchul-associated report with Alchul's actual body, motives, or viewpoint.
- Build and technical smoke tests are not evidence of visual quality, biological validation or historical canon approval.
