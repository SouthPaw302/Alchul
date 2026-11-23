# ALCHUL — M11 / T15 Original-Asset Settlement Geometry and Provisional Body Envelope Audit

**Date:** 2026-11-23  
**Status:** working *native 3D engineering study* awaiting CI / sample inspection. **Not** a selected body plan, demonstrated corridor access or valid historical architecture.  
**Depends on:** [T14 creator anatomy evidence](M11_T14_CREATOR_ANATOMY_REVIEW_AND_DECISION_GATES.md), [T13 genuine skinning source](M11_T13_PROVISIONAL_SKINNED_RIG_AND_CONTEXT_GATES.md), [T10 mechanics lab](M11_T10_BIOMECHANICS_FORCES_AND_CORRIDOR_VALIDATION.md), [Godot original media atlas](../godot/scripts/original_media_atlas.gd).

## 1. Work completed toward the settlement fit problem

Previous T10 artificial corridor was explicitly *not derived from any existing settlement GLB*. T15 changes the test surface: it loads all four original first-party settlement resource files through **Godot's native GLB importer**, without reconstructing their triangles as new boxes.

| Study | Actual first-party source file | Archaeological meaning |
|---|---|---|
| River station M2 | `godot/assets/m2/ALC_M2_RIVER_STATION_v001.glb` | Visual concept, NOT a surveyed site |
| Nursery M3 | `godot/assets/m3/ALC_M3_NURSERY_CIRCULATION_v001.glb` | Visual concept; no confirmed nurseries |
| Harvest M4 | `godot/assets/m4/ALC_M4_HARVEST_PRECINCT_v001.glb` | Visual concept; no proven fermentation chamber |
| Connective settlement M5 | `godot/assets/m5/ALC_M5_CONNECTIVE_SETTLEMENT_v001.glb` | Visual concept, NOT a dimensional floor plan |

`godot/scripts/m11_t15_settlement_geometry_lab.gd` inventories each source file's mesh nodes, surface triangle totals, source UV-bearing surfaces, coordinate-space bounds, and SHA-256. It builds a real physics **ConcavePolygonShape3D** from each available imported mesh, not a made-up proxy wall. Those collider geometry data derive directly from the scene's original mesh triangles. Original vertex colors are preserved in the standalone review viewport without fabricated UV coordinates.

Two alternative synthetic body **BoxShape3D** envelopes use the extremal anchors of each real T07 43-control H-A/H-B registry, plus openly stated arbitrary soft-tissue margins. T15 queries five *arbitrary* axis-aligned bounding-box fractional positions per source, each at three deliberately uncalibrated body-to-source scale factors (0.22, 0.44 and 0.88). The resulting `PhysicsDirectSpaceState3D.intersect_shape` hit counts say only whether synthetic boxes intersect the imported triangle mesh at those positions and scales.

The 3D viewer displays imported **actual original artwork**, with deliberately translucent orange H-A and teal H-B *bounding boxes*, not misleading model animations. Keys 1–4 select source; 5/6/7 select candidate or both; S changes hypothetical relative body size; C runs collision samples. A screenshot from this viewer is an actual Godot render, not an anatomical illustration, archaeological scan or physical clearance certification.

## 2. Technical acceptance

- Offline source/science validator: `python3 godot/tools/validate_m11_t15_geometry.py`.
- Adversarial offline tests: `python3 -m unittest discover -s godot/tests -p 'test_m11_t15_geometry.py'`.
- True native engine/mesh physics test: `godot --headless --path godot --script res://tests/m11_t15_settlement_smoke.gd`. Loads **each** original M2–M5 file, verifies triangle mesh collider types and hashes, inventories source geometry and performs 2 candidates × 3 ratio assumptions × 5 sample positions **per site** (120 shape queries).
- Four 1280×720 actual Godot screenshots: `godot/tests/render_m11_t15.gd`, with a machine-readable manifest including actual per-file source hash, mesh triangles, imported UV and probe counts.
- Native viewer: `godot --path godot res://scenes/m11_t15_settlement_geometry_lab.tscn`. This **does not edit Chapter I** and is not accessible from the public game.

**A true pass means:** source asset identity is known, imported geometry—not guessed labels—is checked, physics intersections are reproducible, and scientific uncertainty survives every validation. No health or actual ancient inhabitants are represented.

## 3. Scientific and engineering barriers that remain

1. Original GLB coordinate units do not establish physical metres. A synthetic relative ratio, even if two candidates differ, **cannot** prove any specific historical stature, door height, nursery fit, swimming capacity or corridor passage.
2. Axis-aligned mesh bounds are not architectural semantics. The five probes are arbitrary source-bounds fractions, **not routed paths**, recognized walkways, doorway positions, child-safe lanes or measured workstations. A hit may be ground or an intentionally load-bearing support; a zero-hit sample may be outside a valid platform. Therefore every result's traversability is `UNKNOWN`.
3. Simple boxed bone-anchor extremes are not anatomical soft-tissue bodies. Tail deflection, compliant grasping, pedal contact, gravid load, duty cycles, fatigue, actual tissue shape and joint dynamics remain missing. H-A/H-B are distinct hypotheses, H-C not constructed.
4. The original source files are creative design media, not measured Late Cretaceous excavations; neither the setting nor physical matter influence is established real-world science.
5. *Do not combine previous T10 2.8/4.6 normalized corridor numbers with these source coordinates.* They have independent arbitrary units and cannot be compared as if metres.
6. The real evolutionary time sequence across K–Pg through present-day New Madrid must be researched independently. T15 studies **undated mature surface** concepts only and cannot define modern descendants.
7. T14 creator anatomy approval remains open. T15 produces comparative evidence only, does not write `CANON.md`, does not promote bodies into Chapter I, and does not define Alchul.

## 4. Next scientific/production gate

A defensible T15 completion needs deliberate hand-authored or verified semantic route markers in the original M2–M5 assets, a consistent art-system metric or explicitly defined scale calibration (not a fossil measurement), nonconvex body/tail proxies with physical contact, repeated path and functional tasks, and creator-approved scope. **The delivered synthetic collision audit is the first measurable imported-geometry subgate, not completion of historical settlement ergonomics.** The publishing and Chapter I redesign tracks are intentionally untouched.
