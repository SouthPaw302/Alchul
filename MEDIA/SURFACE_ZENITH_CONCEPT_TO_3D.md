# Surface Zenith — concept-to-3D batch 01

An isolated fictional ~70 Ma mature-surface concept reconstruction. The ten generated cinematic image studies inform silhouette, layered plumage, stone/wood root architecture, river terraces, nursery and fermentation stations. This is manual procedural interpretation, not image photogrammetry or exact image-to-mesh conversion. No photos used as billboards.

## Deliverables
Ten reusable GLBs: adult rust, adult slate, juvenile color variant (scaled in scene), living root hall, bridge, culture vessel, nursery nest, material workbench, plant cluster, river retaining bank. Original Godot mesh generator uses parametric primitive and custom feather-blade geometry. Source includes materials and deterministic placement. A standalone native city scene creates additional terrain and trees, uses real GLB imports if ALCHUL_ZENITH_GLB_DIR is provided, otherwise uses the same generator. Left/right keys change between ten camera positions.

## Constraints
Static posed body prototypes, not a replacement for T16 weighted rigs or T14 anatomy approval. No production skinning, validated gait/contact, calibrated dimensions, photorealistic texture maps or accurate reconstruction of a specific Cretaceous site. No public Chapter I or T22 registry changes. Real Earth and fiction remain separate. 
## Verification
Native CI generates GLBs, reimports each and renders the city from ten positions using the reimported assets. Results pending until CI completes. Source scene res://scenes/surface_zenith_city.tscn. 
