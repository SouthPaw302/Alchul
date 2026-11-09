# Technical Precedent Audit (Read-only, November 9, 2026)

**This file is an inventory, not an import record.** The following past projects were inspected without changing them or adding them to Alchul as dependencies.

## GodRender — \`SouthPaw302/GodRender\`

- Primary purpose: dedicated audiovisual production, film, shot rendering, FX and review.
- Existing Godot examples: archived standalone 2D/3D proof scenes under \`upstream/mainv2-lab/lab/godot*/\`, using \`project.godot\`, \`.tscn\`, and \`.gd\`.
- Technical precedent: 2026-10-15 procedural 3D Godot movie proof logged as \`TECHNICAL_PROOF_PASS\` in \`upstream/mainv2-lab/lab/reviews/godot-procedural3d-20261015.json\`; 14 seconds, 336 frames, 960x540, 24 fps; **human visual approval pending**.
- Constraints: the proof was a pre-rendered cinematic, not browser interactivity, a science-backed extinct anatomy, a geological simulation, or an Alchul-world project.
- Action in this pass: **none**. No code or assets imported, no GodRender workflows modified or triggered.

## Older 3D/browser prototype — \`SouthPaw302/Alchul-Gemini-\`

- Historically prototyped an Alchul React/Three.js viewer, body model, research codex, scenes and interface.
- This user specifically requested leaving the branch aside; its contents are not imported or relied on.
- Action in this pass: **none**.

## Canonical Alchul archive — this repository

- The narrative foundation is already available locally at the repository root. It remains the single authority and is not duplicated as an alternative version of canon.
- \`godot/data/worldbook.json\` is a **small, offline, derived presentation layer** with source pointers, not an editable second worldbuilding authority.
- Working scenes require explicit status labels; no concrete model geometry is automatically promoted to \`CANON.md\`.

## Future imports: evaluation before copying

For any previous prototype feature: first list the requirement; identify which local implementation best satisfies it; review ownership/license/third-party assets, dependencies, specific useful algorithms, maintenance cost and reproduction tests. Prefer reimplementing from the needed behavior. Import source only if a user-approved provenance record and a corresponding native Alchul test justify it.

There is no need for Git submodules, symlinks to adjacent checkouts, automatic clone commands or other repository startup scripts.
