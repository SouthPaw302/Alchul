# Source and Asset Provenance — Alchul Native Runtime

**Initial pass date:** 2026-11-09.

| Resource | Origin | License/provenance status | Imported or depended upon? |
| --- | --- | --- | --- |
| Alchul canonical lore | This repository: \`CANON.md\`, \`TIMELINE.md\`, \`SPECIES.md\`, \`VISUAL_CANON.md\` and research | First-party authored worldbuilding | Referenced; summary worldbook is local derived data |
| Alchul working characters | This repository: \`LORE/INDIVIDUAL_01_TESH_BODY_AND_LIFE.md\` and stories | Unapproved exploratory lore | Reinterpreted as a nonbinding scene figure |
| Godot Engine | Public official engine, installed by the operator | External toolchain; no binary vendored | Required to open/run Godot scenes |
| GodRender | \`SouthPaw302/GodRender\` | Read-only technical precedent | **No copied files, imports, or runtime references** |
| Prior Alchul browser prototype | \`SouthPaw302/Alchul-Gemini-\` | Read-only prototype | **No copied files, imports, or runtime references** |
| Older AIVideoEdit Godot studies | Preserved under GodRender historical upstream | Read-only technical precedent | **No copied files, imports, or runtime references** |
| Initial terrain / tree / stone / water meshes | New native GDScript primitives in this repository | First-party source | Generated at runtime; no external assets |

All scenery and movement are provisional editor-side artistic studies, not literal geographic/topographic or biomechanical truth. No imported media, character mesh, texture, audio master, shot package, plugin, third-party script or cached rendering engine is used.

Future imports must record: repo/source link, pinned commit, file(s), license/ownership and granted use, SHA-256 of received bytes, any transformations, runtime requirements, acceptance status, and Alchul-specific test results. **Prefer native reimplementation and owned geometry over copying an entire prototype.**
