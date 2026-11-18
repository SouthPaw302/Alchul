# ALCHUL — M9 Source Integrity and Import Feasibility Check

**Date:** 2026-11-18  
**Status:** Independent source-byte verification for the first pilot assets; **Gate 0 still open**.  
**Target:** Preserve canonical history and live site; no game files changed.

## Materials actually inspected

- M2 station original: [ALC_M2_RIVER_STATION_v001.glb](https://drive.google.com/file/d/1f-iQjSM6P7m4StfFaECLh0Kb6Q_NacPN/view), downloaded as actual binary source and independently hashed.
- M6 production archive: [ALC_M6_COMPLETE_VISUAL_PACK_v001.zip](https://drive.google.com/file/d/1dmymmRG0QAI8LSih0yC6t5tIrv24R29t/view), downloaded and inspected as ZIP contents.
- Expected M2 digest/shape: `ASSET_MANIFEST.json` in the station source folder; expected M6 digests: `BATCH06_PACKAGE_MANIFEST.json` in the M6 source folder.

### M2 station

| Check | Observation |
|---|---|
| File size | 2,364,296 bytes |
| Direct original SHA-256 | `4e1a48850ea6d3e2b50e2a923ac07d11f637b9629090e7bcda5f3299ab5822c3` |
| Matches archived M2 manifest | Yes |
| glTF geometry meshes | 19 |
| Scene geometry nodes | 19 |
| Triangles | 93,114 (manifest agrees) |
| Vertices (sum over meshes) | 78,493 |
| Meshes containing UV coordinates | **0 / 19** |
| Scene bounds, meters (X,Y,Z) | min (-41.836, -1.995, -41.000); max (41.836, 7.340, 41.000) |
| Source coordinate convention | Y-up, meters (archive manifest) |

**Significant integration finding:** the original M2 GLB is not UV-unwrapped. Conventional `albedo_texture` / `normal_texture` placement using per-mesh UVs will not work as-is. Avoid claiming that all M6 PBR textures can simply be applied to the M2 meshes. M10 should preserve the M2 original as a separate geometry baseline and either prepare an intentional UV/lightweight triplanar mapping for chosen station surfaces or apply the genuine M6 PBR maps to their **own UV-ready M6 geometry**.

### M6 complete source archive

| Check | Observation |
|---|---|
| ZIP bytes | 33,021,813 |
| ZIP SHA-256 | `fd9a1a4b861fb950955f40c9b4b8b859c061a81abf62aac0768ac94b6a63ac64` |
| ZIP CRC test | Passed |
| ZIP members | 47 total, including package manifest |
| SHA-256 and size matches vs manifest | **46 / 46**, 0 mismatches |
| M6 original 768×768 texture members | **28 / 28 independently hash-verified** |
| PNG channel formats | 14 RGB + 14 grayscale |
| Original packaged GLB SHA-256 | `0f640fc0a5bc8dd385d272a7d4bde33af110931f26da785d5546150b7a42c606` |
| Packaged GLB meshes | 7 |
| Packaged GLB triangles | 141,176 |
| Packaged GLB vertices | 139,280 |
| Meshes containing UVs | **7 / 7** |
| Packaged GLB bounds (m) | min (-25.008, -1.330, -25.000); max (25.279, 9.808, 25.000) |

**Verification precision:** these successful M6 digest checks prove bytes of ZIP **members** agree with the archived M6 package manifest. They do not independently prove the content of all 28 separate Drive PNG objects, which remain pending direct downloads. The M6 model SHA is likewise for the packaged GLB, not the separately listed Drive GLB object.

## Consequences for Batch 10

1. **Import the archived M2 station GLB as independent original geometry** into a candidate, with a visible source label, native screenshot and corrected axis/scale. Keep the existing procedural station intact for A/B comparison.
2. **Introduce authentic M6 PBR maps with the UV-ready M6 model** as the first material-fidelity test. Do not use M2’s absent UVs as though they existed.
3. For station material refinement, select which surfaces need either generated UVs, authored geometry, vertex-color retention or triplanar texturing. Do this deliberately and include close native screenshots of arches and bracing.
4. Test collision, walking surface normals and Web budget. M2 is 93k triangles and M6 is 141k; including both adds approximately 234k unoptimized source triangles **before** existing scene geometry, and cannot be assumed browser-appropriate.
5. Run pinned native + browser smoke and full ten-view visual comparison. Use the rejected M8 spike images only as a regression example.

## Remaining Gate 0 blockers

- Complete direct-byte verification of each independently stored M6 PNG / GLB, other M1–M5 source packs and archive descendants.
- Baseline new Godot native captures from the exact M9 base/branch, with real draw calls, memory and bundle metrics.
- Complete material/UV audit for other source modules, unapproved variants and duplicate ZIP entries.
- No model or scene has yet been imported into the repository, and no new performance tests were run during this verification.
- No canon status changed.

## Local reproducibility

A reproduction with downloaded source ZIP, extracted original M2 GLB and archived expected manifests:

```bash
sha256sum ALC_M2_RIVER_STATION_v001.glb ALC_M6_COMPLETE_VISUAL_PACK_v001.zip
python3 - <<'PY'
import zipfile, hashlib, json
z = zipfile.ZipFile('ALC_M6_COMPLETE_VISUAL_PACK_v001.zip')
assert z.testzip() is None
m = json.load(open('BATCH06_PACKAGE_MANIFEST.json'))
for rec in m['files']:
    payload = z.read(rec['path'])
    assert len(payload) == rec['bytes']
    assert hashlib.sha256(payload).hexdigest() == rec['sha256']
print('Verified', len(m['files']), 'package members')
PY
```

Geometry observations were obtained using Python `trimesh.load(..., force='scene')`, inspecting `scene.geometry`, total triangle/vertex counts, mesh UV data and world bounds. PNG dimensions and formats were inspected with Pillow. These source-file checks **are not direct Godot engine render validation**.

Related: [machine-readable registry](ASSET_INTEGRATION_REGISTER.json), [M9 audit](ASSET_INTEGRATION_REGISTER.md), [M9–M12 roadmap](ROADMAP_M9_M12_ASSETS_AND_INHABITANTS.md).
