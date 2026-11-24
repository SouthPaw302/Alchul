extends "res://tests/export_surface_zenith_assets.gd"
const FidelityKit = preload("res://scripts/surface_zenith_fidelity_assets.gd")
func _run() -> void:
    var path: String = OS.get_environment("ALCHUL_ZENITH_GLB_DIR")
    if path.is_empty():
        path = ProjectSettings.globalize_path("user://surface_zenith_fidelity_glb")
    if DirAccess.make_dir_recursive_absolute(path) != OK:
        quit(1)
        return
    var kit = FidelityKit.new()
    if not kit.export_maps(path.path_join("textures")):
        quit(1)
        return
    var holder := Node3D.new()
    root.add_child(holder)
    var assets: Dictionary = kit.catalog(holder)
    var manifest: Dictionary = {}
    for id in assets:
        var asset: Node3D = assets[id]
        var meshes: Array = asset.find_children("*","MeshInstance3D",true,false)
        var triangles: int = 0
        var textured: int = 0
        for m in meshes:
            if m.material_override != null:
                m.mesh.surface_set_material(0,m.material_override)
                if m.material_override is StandardMaterial3D and m.material_override.albedo_texture != null:
                    textured += 1
            var arrays: Array = m.mesh.surface_get_arrays(0)
            var indices: Variant = arrays[Mesh.ARRAY_INDEX]
            if indices != null and indices.size()>0:
                triangles += int(indices.size()/3)
            else:
                triangles += int(arrays[Mesh.ARRAY_VERTEX].size()/3)
        if triangles == 0 or textured == 0:
            quit(1)
            return
        var doc := GLTFDocument.new()
        var state := GLTFState.new()
        var target: String = path.path_join(str(id)+".glb")
        if doc.append_from_scene(asset,state) != OK or doc.write_to_filesystem(state,target) != OK:
            quit(1)
            return
        var verify := GLTFDocument.new()
        var readback := GLTFState.new()
        if verify.append_from_file(target,readback) != OK:
            quit(1)
            return
        var copy: Node = verify.generate_scene(readback)
        var count: int = copy.find_children("*","MeshInstance3D",true,false).size()
        var imported_textures: int = 0
        for m in copy.find_children("*","MeshInstance3D",true,false):
            var mat: Material = m.mesh.surface_get_material(0)
            if mat is StandardMaterial3D and mat.albedo_texture != null and mat.normal_texture != null:
                imported_textures += 1
        copy.free()
        if count == 0 or imported_textures == 0:
            quit(1)
            return
        manifest[id] = {"source_mesh_nodes":meshes.size(),"triangles":triangles,"source_textured_nodes":textured,"roundtrip_mesh_nodes":count,"roundtrip_albedo_normal_nodes":imported_textures,"static_concept":true}
    var file := FileAccess.open(path.path_join("manifest.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify(manifest,"  "))
    file.close()
    print("PASS 02: ten texture-bearing GLBs, fourteen 512px maps, verified roundtrip")
    quit(0)
