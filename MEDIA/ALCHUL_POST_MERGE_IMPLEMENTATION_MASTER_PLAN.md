# ALCHUL — Post-Merge Numbered Implementation Master Plan

**Checkpoint:** November 20, 2026 (America/New_York)  
**Authority:** `CANON.md` controls fictional facts; `RESEARCH/` contains external evidence; all M11 designs remain **provisional**.  
**Integration baseline:** GitHub PRs #2 (M9), #3 (M10), #5 (Chapter I), #6 (original-media atlas), and #4 (M11 dossier) have all been merged to `main` in dependency order. No open source PR remains at this checkpoint.  
**Implementation rule:** do not confuse a successful source merge with a working signed production app, completed biological simulation, approved canon, or measured browser-GPU performance. Every task has an acceptance gate.

## Priority 0 — Consolidated repository and reproducible baseline

1. **[IN PROGRESS] Baseline verification on merged `main`.** Check changed source provenance and run native Godot import/game loop/original-mesh tests on the *merged commit*. **Gate:** current `main` CI passes; resolve any regressions before a public release.
2. **[TODO] Harmonize post-merge documentation and entry points.** Update root `README.md`, Godot README, release notes and screenshots to describe the actual current game and distinguish experimental scenes. **Gate:** no stale “prototype only” or “branch only” claims.
3. **[TODO] Establish release manifest, exact build checksums, and versioning.** Store source commit, Godot version, platform binaries, permissions, source-media hashes, licenses and known defects together. **Gate:** an exported archive can be traced back to a commit and verified.
4. **[TODO] Preserve the original-media audit.** Keep all M1–M6 source GLBs, verified 28 M6 textures, partition triangle counts, and matching Drive provenance. **Gate:** repeatable automated digest/geometry comparisons and no silently replaced originals.

## Priority 1 — Inhabitants: defensible body plan before final character design

5. **[STARTED] Create an M11 comparative anatomy registry and separate native Godot inspection scene.** Put H-A and H-B beside the same pelvis/ground reference datum with explicit illustrative, nonmetric dimensions. **Gate:** standalone scene loads and independently tests both forms; neither changes `CANON.md`.
6. **[TODO] Re-render ten independent high-resolution anatomy plates.** Replace low-resolution crops from the first concept sheets with separately rendered 01–10 plates, mirrored views and complete provenance. **Gate:** matched scale and camera geometry, no misleading biological labels.
7. **[TODO] Build a bone/joint reference hierarchy.** Establish nonhuman theropod-derived skull, neck, shoulder, wrist, pelvis, knee, ankle and digit axes for each model. **Gate:** manipulative poses do not depend on mammalian palms or primate thumb opposition.
8. **[TODO] Perform center-of-mass and support-envelope tests.** Proxy mass distribution, three task poses, tail swing, turning footprint and contact positions. **Gate:** assumptions reported, unstable hypotheses rejected or revised, no static mesh called a verified gait.
9. **[TODO] Implement three-digit bracing and tool interaction tests.** Model reachable tool/wedge/resonance-frame contacts using actual limited joint axes and distinct three fingers. **Gate:** repeatable grip poses with explicit constraints and failures.
10. **[TODO] Test digitigrade locomotion and tail clearance.** Study toe contacts, turns, uneven/soft ground and shared work-lane width for H-A and H-B. **Gate:** motion tests and annotated pass/fail envelope.
11. **[TODO] Study respiratory and late egg-retention trade-offs.** Maintain the canon ~75% internal development; test mechanical/energetic and gas-exchange demands without drawing invented organs as fact. **Gate:** evidence/inference ledger and nursery design implications.
12. **[TODO] Design varied provisional inhabitants.** Include adult reader, independent colleague, an egg-bearing individual, a juvenile learner, nursery worker and Harvest specialist without assigning default human sex or caste roles. **Gate:** individual differentiation without an unapproved master morphology.
13. **[TODO] Produce a production-ready rig, textures and animation set.** Skin, feather/keratin coverage, walk/turn/grip/rest/communicate cycles, facial nonhuman signals, LODs, collision. **Gate:** reproducible rig exports with anatomy and render QA.
14. **[TODO] Obtain explicit creator anatomy approval.** Compare H-A, H-B or hybrid only after science and task-fit review. **Gate:** written decision before promotion to canon or shipped primary NPC species.

## Priority 2 — World integration and grounded systems

15. **[TODO] Fit actual bodies to settlement ergonomics.** Circulation/doorway/nursery workstations, flood crossings, tail clearance and shared material-handling stations. **Gate:** scene-based collision/clearance tests in M1–M6.
16. **[TODO] Replace generic figure placeholders only after approval.** Integrate rigged inhabitants into Godot stages, retain provenance and the option to disable experimental models. **Gate:** character import/native smoke and stable frame budget.
17. **[TODO] Simulate physical environmental sensing.** Water, vibration, stress, heat, pressure, gas, substrate and acoustic clues must have causal observable sources. **Gate:** inspectable stimulus → sensor → reaction loop, with false positives.
18. **[TODO] Separate Alchul-linked testimony from physical signal detection.** Three existing interpretation lenses remain distinct; no visible Alchul body or direct mind-powered levitation. **Gate:** ambiguity survives gameplay.
19. **[TODO] Implement nonhuman interaction and communication.** Posture, tail, plumage, touch, substrate contact and optional patterned sound, with accessibility translations. **Gate:** understandable to player without anthropomorphic dialogue dependence.
20. **[TODO] Implement controlled replication and conflicting observers.** A river stress / resonance experiment with blind observations, logged disagreements and an explicit failure path. **Gate:** two observers can reach different, recorded interpretations.
21. **[TODO] Expand lived settlement systems.** Working nursery environments, Harvest fermentation, maintenance, food/predation, flood control, preservation, shelter upkeep and cross-specialist dependencies. **Gate:** process-driven systems rather than inert props.
22. **[TODO] Add era-state boundaries.** Mature surface, First Below, Long Descent, K–Pg aftermath and modern New Madrid must not share unapproved anatomy, technology or geology. **Gate:** explicit history/scene state tags and provenance.
23. **[TODO] Extend narrative beyond Chapter I.** Research and build Chapter II: deliberate first below-ground trials, cost/failure, sensory engineering and unresolved catastrophe evidence. **Gate:** full narrative loop, save/continue, testable ending.

## Priority 3 — Rendering, audio, performance, and presentation

24. **[TODO] Complete first-party UV/PBR and material fidelity.** Retain original vertex-color M2, handle UV-less source honestly, assign compliant materials only where geometry supports it. **Gate:** original-source screenshots and mapped 28 textures verified.
25. **[TODO] Improve visual quality without breaking original geometry.** Lighting, atmosphere, water response, terrain details, vegetation diversity, animation quality and anti-aliasing. **Gate:** actual Godot before/after visual review.
26. **[TODO] Optimize native and web separately.** LOD, draw calls, import sizes, occlusion and load times; browser SwiftShader timing is not a hardware-GPU benchmark. **Gate:** reproducible device-specific frame/timing and memory data.
27. **[TODO] Add first-party layered soundscapes.** River, wetland, contact/footfall cues and species communications without falsely presenting invented voices as confirmed. **Gate:** offline asset provenance, mixing controls and performance.
28. **[TODO] Improve accessibility and player guidance.** Remappable controls, readable scale, keyboard/controller navigation, motion/contrast options, captions, discovery hinting and save safety. **Gate:** documented usability pass.
29. **[TODO] Implement automated visual regression and asset lint.** Capture true Godot comparison angles and interaction states, ensure original asset hashes and manifests remain stable. **Gate:** CI catches material/geometry/UI drift.

## Priority 4 — Desktop, web and publishing

30. **[TODO] Validate physical Windows, Linux and macOS builds.** GPU, input, audio, save path, sleep/resume, packaged shaders and installer/extraction behavior; CI Linux boot alone is not enough. **Gate:** signed off platform matrix.
31. **[TODO] Establish trustworthy desktop distribution.** Versioned apps, platform signing and macOS notarization where applicable, malware checks and reproducible release archives. **Gate:** verifiable public binaries.
32. **[TODO] Decide the web-rendering release scope.** Current Pages workflow may publish from merges on `main`; evaluate web export bundle and performance separately from native game. **Gate:** browser smoke, known limitations and deliberate approval to expose the build.
33. **[TODO] Refresh public presentation.** Root website, media comparisons, supported platforms, release notes, credits, scientific caveats and downloads. **Gate:** live URL works and matches exact release version.
34. **[TODO] Formalize creative and release decision ledger.** Record approvals/rejections, outstanding biology, M11 reproducibility, external literature sources, gameplay changes and world-canon changes separately. **Gate:** no art hypothesis enters locked canon by accident.
35. **[TODO] Archive every batch to Drive and GitHub.** Source renders, full source files, validated native screenshots, rigs, manifests, checksums and independent research documentation. **Gate:** independently retrievable, traceable revisions rather than an unlabelled media folder.

## Immediate execution contract

The first new deliverable is **#5**: a distinct `m11_anatomy_lab.tscn` Godot scene plus a checked dimensionless JSON registry, Python research-constraint validation and a native Godot smoke test. It must be labelled **research-only**, show both alternatives together, display three non-primate functional digits per hand, and preserve the Chapter I game unchanged. The next work item will be #6 and then #7–#11. Parallel release/hardware tasks (#1–#4, #30–#33) remain tracked, not silently waived.
