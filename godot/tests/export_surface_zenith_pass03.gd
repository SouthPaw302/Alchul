extends "res://tests/export_surface_zenith_fidelity.gd"
const Pass03Kit = preload("res://scripts/surface_zenith_pass03_assets.gd")
func _run() -> void:
    var out: String = OS.get_environment("ALCHUL_ZENITH_GLB_DIR")
    if out.is_empty():
        out = ProjectSettings.globalize_path("user://surface_zenith_pass03")
    if DirAccess.make_dir_recursive_absolute(out)!=OK:
        quit(1)
        return
    var kit = Pass03Kit.new()
    # Only the hero maps are upgraded; reuse the pass02 environment assets as authored geometry.
    if not kit.export_maps(out.path_join("textures")):
        quit(1)
        return
    var holder := Node3D.new()
    root.add_child(holder)
    var adult: Node3D = kit.actor(holder)
    for m in adult.find_children("*","MeshInstance3D",true,false):
        if m.material_override!=null:
            m.mesh.surface_set_material(0,m.material_override)
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    if doc.append_from_scene(adult,state)!=OK or doc.write_to_filesystem(state,out.path_join("adult.glb"))!=OK:
        quit(1)
        return
    var verify := GLTFDocument.new()
    var back := GLTFState.new()
    if verify.append_from_file(out.path_join("adult.glb"),back)!=OK:
        quit(1)
        return
    var copy: Node = verify.generate_scene(back)
    var count: int = 0
    for m in copy.find_children("*","MeshInstance3D",true,false):
        var mat: Material = m.mesh.surface_get_material(0)
        if mat is StandardMaterial3D and mat.albedo_texture!=null and mat.albedo_texture.get_width()==2048 and mat.normal_texture!=null and mat.roughness_texture!=null:
            count+=1
    copy.free()
    if count==0:
        quit(1)
        return
    print("Pass03 hero GLB roundtrip 2K albedo normal roughness nodes: ",count)
    quit(0)
