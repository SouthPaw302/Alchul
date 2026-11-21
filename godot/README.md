# Alchul — Standalone Godot Runtime

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
