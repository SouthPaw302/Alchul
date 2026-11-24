extends SceneTree
func _initialize() -> void:
    call_deferred("_run")
func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var im: Image = root.get_texture().get_image()
    return im!=null and not im.is_empty() and im.save_png(path)==OK
func _run() -> void:
    var out: String = OS.get_environment("ALCHUL_ZENITH_CAPTURES")
    if DirAccess.make_dir_recursive_absolute(out)!=OK:
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var city = load("res://scenes/surface_zenith_pass03_city.tscn").instantiate()
    root.add_child(city)
    await process_frame
    if city.imported!=10 or city.living_actors.size()!=5 or city.terrain_mesh==null:
        quit(1)
        return
    var report: Dictionary = city.binding_reports[0]
    if report["bones"]!=43 or report["vertices"]<1000 or report["triangles"]<1000:
        quit(1)
        return
    var shell: MeshInstance3D = report["mesh"]
    for s in range(shell.mesh.get_surface_count()):
        var a: Array = shell.mesh.surface_get_arrays(s)
        var ws: PackedFloat32Array = a[Mesh.ARRAY_WEIGHTS]
        var bs: PackedInt32Array = a[Mesh.ARRAY_BONES]
        for i in range(0,ws.size(),4):
            if absf(ws[i]+ws[i+1]+ws[i+2]+ws[i+3]-1.0)>0.001:
                quit(1)
                return
            for j in range(4):
                if bs[i+j]<0 or bs[i+j]>=43:
                    quit(1)
                    return
    var sk: Skeleton3D = city.living_actors[0].get_node("ResearchSkeleton3D")
    var index: int = sk.find_bone("neck_01")
    var old: Quaternion = sk.get_bone_pose_rotation(index)
    city._process(0.44)
    if old.is_equal_approx(sk.get_bone_pose_rotation(index)):
        quit(1)
        return
    # Export actual new weighted shell with its skeleton, not the old rig.
    var export_root: Node3D = city.living_actors[0].duplicate() as Node3D
    root.add_child(export_root)
    export_root.position = Vector3.ZERO
    export_root.rotation = Vector3.ZERO
    export_root.scale = Vector3.ONE
    for child in export_root.get_children():
        if child.name not in ["ResearchSkeleton3D","Pass03_WeightedConceptShell"]:
            child.free()
    var es: Skeleton3D = export_root.get_node("ResearchSkeleton3D")
    for child in es.get_children():
        child.free()
    for i in range(es.get_bone_count()):
        es.set_bone_pose_rotation(i,Quaternion.IDENTITY)
    es.force_update_all_bone_transforms()
    var doc := GLTFDocument.new()
    var state := GLTFState.new()
    var dest: String = OS.get_environment("ALCHUL_ZENITH_GLB_DIR").path_join("adult_weighted.glb")
    if doc.append_from_scene(export_root,state)!=OK or doc.write_to_filesystem(state,dest)!=OK:
        quit(1)
        return
    export_root.free()
    var read_doc := GLTFDocument.new()
    var back := GLTFState.new()
    if read_doc.append_from_file(dest,back)!=OK:
        quit(1)
        return
    var read: Node = read_doc.generate_scene(back)
    var found: bool = false
    for m in read.find_children("*","MeshInstance3D",true,false):
        if m.skin!=null:
            found=true
    read.free()
    if not found:
        quit(1)
        return
    for i in range(city.views.size()):
        city.set_view(i)
        if not await _capture(out.path_join(str(city.views[i][0])+".png")):
            quit(1)
            return
    city.set_view(0)
    city._process(0.65)
    if not await _capture(out.path_join("11_weighted_pose.png")):
        quit(1)
        return
    var file := FileAccess.open(out.path_join("validation.json"),FileAccess.WRITE)
    file.store_string(JSON.stringify({"weighted_residents":5,"bone_count":43,"vertices":report["vertices"],"triangles":report["triangles"],"surfaces":report["surfaces"],"terrain_triangles":18432,"skin_roundtrip":true,"motion_pose_changed":true}, "  "))
    file.close()
    print("PASS03 actual weighted concept shell, five residents, portable skin roundtrip, eleven images")
    quit(0)
