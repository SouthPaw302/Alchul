extends SceneTree
const Kit = preload("res://scripts/surface_zenith_assets.gd")
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var path: String = OS.get_environment("ALCHUL_ZENITH_GLB_DIR")
    if path.is_empty():
        path = ProjectSettings.globalize_path("user://surface_zenith_glb")
    if DirAccess.make_dir_recursive_absolute(path) != OK:
        quit(1)
        return
    var kit = Kit.new()
    var holder := Node3D.new()
    root.add_child(holder)
    var assets: Dictionary = kit.catalog(holder)
    var manifest: Dictionary = {}
    for id in assets:
        var asset: Node3D = assets[id]
        var meshes: Array = asset.find_children("*","MeshInstance3D",true,false)
        if meshes.is_empty():
            quit(1)
            return
        for m in meshes:
            # Embed actual surface material into GLB, not an external shader.
            if m.material_override != null:
                m.mesh.surface_set_material(0,m.material_override)
        var doc := GLTFDocument.new()
        var state := GLTFState.new()
        var target: String = path.path_join(str(id)+".glb")
        if doc.append_from_scene(asset,state) != OK or doc.write_to_filesystem(state,target) != OK:
            push_error("GLB export failed "+str(id))
            quit(1)
            return
        var verify := GLTFDocument.new()
        var readback := GLTFState.new()
        if verify.append_from_file(target,readback) != OK:
            quit(1)
            return
        var copy: Node = verify.generate_scene(readback)
        var count: int = copy.find_children("*","MeshInstance3D",true,false).size()
        copy.free()
        if count == 0:
            quit(1)
            return
        manifest[id] = {"source_mesh_nodes":meshes.size(),"roundtrip_mesh_nodes":count,"file":str(id)+".glb","static_concept":true}
    var file := FileAccess.open(path.path_join("manifest.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify(manifest,"  "))
    file.close()
    print("Surface Zenith: ten actual GLB asset exports and round-trips complete.")
    quit(0)
