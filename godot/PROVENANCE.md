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

## M10 candidate original asset imports (2026-11-18)

**Review gate only; not approved canon or a production release.** These assets were created as first-party Alchul exploratory studies and archived in the user's Alchul Google Drive production folders. No other user repositories or external runtime asset hosts are used. Source bytes were independently checked against archived build manifests.

| Tracked local resource | Original source | Verification and intended use |
| --- | --- | --- |
| `assets/m2/ALC_M2_RIVER_STATION_v001.glb` | [M2 original Drive GLB](https://drive.google.com/file/d/1f-iQjSM6P7m4StfFaECLh0Kb6Q_NacPN/view) | **Exact source byte copy**, SHA-256 `4e1a48850ea6d3e2b50e2a923ac07d11f637b9629090e7bcda5f3299ab5822c3`. 19 meshes/93,114 triangles. No source UV coordinates; preserve vertex colors for pilot. Provisional station/terrain stage; no collision claim. |
| `assets/m6/textures/ALC_M6_*_768.png` | [M6 28 original Drive maps](https://drive.google.com/drive/folders/1BfJvpQr4Ml2Lhp56spU6BEUhYA-Gp7xw) | **28 exact original 768-pixel PNGs**: seven families × albedo/normal/roughness/height. Independently downloaded per-file, SHA-256 and byte length verified against source archive manifest. Native `materials_m7.gd` binds the first three maps per family; **height maps preserved but not yet used by runtime**. |
| `data/m10_m6_archive_manifest.json` | [M6 source package manifest](https://drive.google.com/file/d/1RJw_UrIKTQwdPdEjNqlBHFTNY7Cs7Q_f/view) | Original manifest copied unchanged as an automated reproducibility fixture for 28 original texture hash checks; also describes the archived M6 GLB, which is **not yet imported** to this pilot. |

**Derived implementation:** `scenes/m10_import_pilot.tscn` + `scripts/m10_import_pilot.gd` instantiate the original imported M2 GLB as a separate diagnostic world, with seven deliberately **UV-ready native material sample boxes**. This does **not** imply the UV-free station itself has the M6 maps applied. The existing procedural M2 station in `scenes/main.tscn` remains unchanged; the existing M7 renderer automatically prefers original textures when they are present in the Godot workspace.

**Verification scope:** source SHA check on M2 and 28 M6 PNGs, 19+ loaded Godot mesh nodes, native material initialization, compatibility renderer screenshots, and separate Web export candidate CI. This is not a claim of mobile readiness, collision, performance budget success, or character/archaeological accuracy.

**Original M6 GLB remains in Drive** (13,728,468 bytes, SHA-256 `0f640fc0a5bc8dd385d272a7d4bde33af110931f26da785d5546150b7a42c606`). A GitHub blob upload was attempted but did not complete due transport limits; do not describe it as tracked source. Later optimize/split it with documented geometry/texture lineage or use smaller native UV-ready geometry for targeted tests.

**Reproduction:**
```sh
godot --headless --path godot --editor --import --quit
godot --headless --path godot --script res://tests/m10_import_smoke.gd
ALCHUL_M10_RENDER_DIR=/absolute/output/path xvfb-run -a godot --path godot --script res://tests/render_m10.gd
```

All source graphics remain **candidate not canon**, and the main published site must not be switched to this pilot without native and web review.
