# ALCHUL — M11 Native Comparative Anatomy Lab 01

**Implemented on:** 2026-11-20 (New York)  
**Status:** runnable provisional **scientific illustration**, not a reviewed rig, fossil reconstruction, mature-species canon, or final NPC.  
**Game impact:** no change to `scenes/main.tscn`, existing Chapter I scenes, saves, release binaries or approved canon.

## First implementation

- `godot/data/m11_anatomy_candidates.json` records two explicit, competing adult peak-surface hypotheses, ten pending anatomical study targets and locked nonhuman constraints, with all dimensions labeled **arbitrary normalized illustration units — not meters**.
- `godot/scripts/m11_anatomy_lab.gd` programmatically assembles two comparable feather-mantled nonhuman body studies with digitigrade legs, three distinct manual digits on each forelimb, tail variants, torso/neck variants, reference marks and shared side camera. Geometry is merely a *sculptural proxy*, not bones, measured COM, force simulation, joint constraint solving or motion capture.
- `godot/scenes/m11_anatomy_lab.tscn` is a standalone native Godot research stage. It is intentionally excluded from the four-site game and the original-media atlas.
- `godot/tools/validate_m11_anatomy.py` verifies data shape, status, matched hip datum and required research boundaries.
- `godot/tests/m11_anatomy_lab_smoke.gd` instantiates real native nodes, checks two hypotheses, paired three-digit hands and toe sets, camera, uncertainty HUD, and isolate/restore controls. CI runs both Python and native checks.

### Open the lab

```sh
python3 godot/tools/validate_m11_anatomy.py
godot --headless --path godot --editor --import --quit
godot --headless --path godot --script res://tests/m11_anatomy_lab_smoke.gd
godot --path godot res://scenes/m11_anatomy_lab.tscn
```

Press **0** to compare both, **1** for H-A and **2** for H-B. The camera/view datum is held fixed. The component displays the research-only warning.

## Explicit limitations

- The drawing parameters are *not* paleontological estimates of mass, hip height, reach, joint range, respiratory capacity, incubation physiology, balance forces or contact speed.
- H-A and H-B are **not** coherent validated skeletons. Their hands are separate articulated *visual strokes*, not a kinematic IK rig. Existing hand work constraints prohibit imagining free mammalian palm rotation.
- Three-dimensional geometry is deliberately primitive. It should be replaced or rebuilt with a justified skeletal reference and properly meshed surfaces after comparison testing; do not sell this as final creature graphics.
- The source of the circa 75% internal egg-retention period is locked fictional canon; the actual oxygen-transfer mechanism remains unresolved. No sexual assignment or specific clutch/womb organ is depicted.
- The laboratory renders no visible body for Alchul and does not assume a precise Late Cretaceous date.

## Next four acceptance experiments

1. Capture matched same-camera H-A and H-B lateral/dorsal/front native Godot plates at consistent reference and log screenshot provenance.
2. Build at least one permitted three-digit bracing task with joint-axis constraints; reject impossible opposition/pronation.
3. Compute approximate segment-mass center-of-mass and support footprints under disclosed mass assumptions; label results quantitative only after validation.
4. Compare corridor/turn/nursery route envelopes in M1–M6 scenes and maintain individual differences without inventing a finished species template.

## Source authority

- [Canon](../CANON.md)
- [Comparative body evidence](../RESEARCH/MATURE_SURFACE_BODY_EVIDENCE.md)
- [M11 competing-hypotheses dossier](M11_PEAK_SURFACE_INHABITANTS_COMPARATIVE_DOSSIER.md)
- [M11 visual-review limitations and first batch](M11_BATCH_01_VISUAL_REVIEW_AND_GATES.md)
- [Master implementation plan](ALCHUL_POST_MERGE_IMPLEMENTATION_MASTER_PLAN.md)
