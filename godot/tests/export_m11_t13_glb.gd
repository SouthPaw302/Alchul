extends SceneTree

## Round-trip export of provisional rig/skin/texture geometry to editable GLB.
## The five motion cycles are procedural in Godot and are NOT baked to GLB clips.
func _initialize() -> void:
    call_deferred("_run")


func _fail(reason: String) -> void:
    push_error("T13 GLB EXPORT FAIL: " + reason)
    quit(1)


func _contains_skin(node: Node) -> bool:
    if node is MeshInstance3D and (node as MeshInstance3D).skin != null:
        return true
    for child in node.get_children():
        if _contains_skin(child):
            return true
    return false


func _contains_skeleton(node: Node) -> bool:
    if node is Skeleton3D and (node as Skeleton3D).get_bone_count() >= 40:
        return true
    for child in node.get_children():
        if _contains_skeleton(child):
            return true
    return false


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T13_EXPORTS")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t13_exports")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        _fail("export directory")
        return
    var packed: PackedScene = load("res://scenes/m11_t13_skinned_character_lab.tscn")
    if packed == null:
        _fail("prototype scene unavailable")
        return
    var lab: Node3D = packed.instantiate()
    root.add_child(lab)
    await process_frame
    lab.playing = false
    lab.sample_pose(0.0)
    var files: Array[String] = []
    for key in ["H-A", "H-B"]:
        var node: Node = lab.get_node_or_null("T07_" + key)
        if node == null:
            _fail("candidate missing " + key)
            return
        var state := GLTFState.new()
        var document := GLTFDocument.new()
        if document.append_from_scene(node, state) != OK:
            _fail("cannot serialize skeleton " + key)
            return
        var name: String = "ALCHUL_T13_" + key + "_provisional_skin.glb"
        var fullpath: String = folder.path_join(name)
        if document.write_to_filesystem(state, fullpath) != OK:
            _fail("cannot write GLB " + key)
            return
        if not FileAccess.file_exists(fullpath) or FileAccess.get_file_as_bytes(fullpath).size() < 1024:
            _fail("GLB empty " + key)
            return
        var check_state := GLTFState.new()
        if GLTFDocument.new().append_from_file(fullpath, check_state) != OK:
            _fail("GLB could not be round-tripped " + key)
            return
        var import_node: Node = GLTFDocument.new().generate_scene(check_state)
        if import_node == null or not _contains_skeleton(import_node):
            _fail("GLB lost the 43-bone reference rig " + key)
            return
        if not _contains_skin(import_node):
            _fail("GLB lost weighted skin " + key)
            return
        import_node.free()
        files.append(name)
    var manifest: Dictionary = {
        "technical_gate":"GLB round-trip skeletal control / weighted skin, not biological validation",
        "scope":"pre-KPg surface hypotheses H-A and H-B only",
        "animation":"five procedural Godot cycles; NOT GLB-baked animation clips",
        "canonical":false, "model_units":"normalized, not physical meters",
        "files":files
    }
    var file := FileAccess.open(folder.path_join("export_manifest.json"), FileAccess.WRITE)
    if file == null:
        _fail("manifest write failure")
        return
    file.store_string(JSON.stringify(manifest, "  "))
    file.close()
    print("ALCHUL T13 TWO SKINNED GLB ROUND-TRIPS PASS")
    lab.queue_free()
    quit(0)
