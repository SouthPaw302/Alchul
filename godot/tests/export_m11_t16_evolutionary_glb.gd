extends SceneTree

## Portable geometry only. Procedural Godot pose cycles are NOT baked to GLB.
func _initialize() -> void:
    call_deferred("_run")


func _fail(message: String) -> void:
    push_error("T16 EVOLVED GLB EXPORT FAIL: " + message)
    quit(1)


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T16_EVOLUTIONARY_EXPORTS")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t16_evolutionary_glb")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("cannot create folder")
        return
    var scene: PackedScene = load("res://scenes/m11_t16_evolutionary_lab.tscn")
    if scene == null:
        _fail("scene missing")
        return
    var lab: Node3D = scene.instantiate()
    root.add_child(lab)
    await process_frame
    lab.playing = false
    lab.sample_pose(0.0)
    var files: Array[String] = []
    for candidate in ["E1","E2","E3"]:
        var node: Node3D = lab.get_node_or_null("T07_" + candidate)
        if node == null:
            _fail("missing actual candidate " + candidate)
            return
        var exporter := GLTFDocument.new()
        var state := GLTFState.new()
        if exporter.append_from_scene(node, state) != OK or state.skins.is_empty():
            _fail("cannot serialize skinned bones " + candidate)
            return
        var name: String = "ALCHUL_T16_" + candidate + "_evolutionary_hypothesis.glb"
        var target: String = folder.path_join(name)
        if exporter.write_to_filesystem(state,target) != OK:
            _fail("could not write GLB "+candidate)
            return
        if not FileAccess.file_exists(target) or FileAccess.get_file_as_bytes(target).size() < 1024:
            _fail("empty GLB "+candidate)
            return
        var readback := GLTFState.new()
        if GLTFDocument.new().append_from_file(target,readback) != OK or readback.skins.is_empty():
            _fail("roundtrip lost GLTF skins "+candidate)
            return
        var restored: Node = GLTFDocument.new().generate_scene(readback)
        if restored == null:
            _fail("GLB cannot generate Godot source scene "+candidate)
            return
        var count: int = 0
        for obj in restored.find_children("*","Skeleton3D",true,false):
            count = maxi(count,(obj as Skeleton3D).get_bone_count())
        if count < 43:
            _fail("GLB lost 43 reference controls "+candidate)
            return
        restored.free()
        files.append(name)
    var manifest := {"files":files,"classification":"three speculative pre-KPg evolved trajectories",
        "source_rig":"T07 43 named controls + T16 parent-local morphometric changes",
        "method":"scientifically bounded scenario shapes, not statistical lineage posterior",
        "creator_approved":false,"biologically_verified":false,"measured_meters":false,
        "godot_animation_clips_baked":false,
        "scientific_era":"undated mature pre-KPg surface only"}
    var file := FileAccess.open(folder.path_join("model_manifest.json"),FileAccess.WRITE)
    if file == null:
        _fail("manifest failed")
        return
    file.store_string(JSON.stringify(manifest,"  "))
    file.close()
    print("ALCHUL T16 EVOLVED THREE SKINNED GLB EXPORTS ROUNDTRIP PASS")
    lab.queue_free()
    quit(0)
