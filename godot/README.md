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
