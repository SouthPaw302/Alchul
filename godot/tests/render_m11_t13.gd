extends SceneTree

## Native Godot screenshots; poses are noncanonical art tests, NOT verified species.
func _initialize() -> void:
    call_deferred("_run")


func _capture(folder: String, file: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = root.get_texture().get_image()
    return image != null and not image.is_empty() and image.save_png(folder.path_join(file)) == OK


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T13_CAPTURES")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t13_captures")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        push_error("T13 capture folder missing")
        quit(1)
        return
    root.size = Vector2i(1280, 720)
    var resource: PackedScene = load("res://scenes/m11_t13_skinned_character_lab.tscn")
    if resource == null:
        push_error("T13 scene missing")
        quit(1)
        return
    var lab: Node = resource.instantiate()
    root.add_child(lab)
    await process_frame
    lab.playing = false
    lab.set_clip("walk")
    lab.sample_pose(0.25)
    if not await _capture(folder, "01_skinned_pair_walk.png"):
        push_error("T13 walk image failed")
        quit(1)
        return
    lab.set_clip("grip")
    lab.sample_pose(0.75)
    lab.set_surface_variant("contrast_study")
    if not await _capture(folder, "02_grip_contrast.png"):
        push_error("T13 grip image failed")
        quit(1)
        return
    lab.set_clip("communicate")
    lab.sample_pose(0.25)
    lab.set_lod(1)
    lab.set_surface_variant("shade_moss")
    if not await _capture(folder, "03_communicate_lod1.png"):
        push_error("T13 low detail image failed")
        quit(1)
        return
    var evidence: Dictionary = {
        "generator":"official Godot 4.7.2 Compatibility renderer on virtual display",
        "scope":"skinned provisional undated pre-KPg H-A/H-B, NOT final species or present descendant",
        "source":"res://scripts/m11_t13_skinned_character_lab.gd + T07 graph",
        "files":["01_skinned_pair_walk.png", "02_grip_contrast.png", "03_communicate_lod1.png"],
        "creator_approval":false,
        "scientific_measurements":false,
        "published_game_character":false
    }
    var f := FileAccess.open(folder.path_join("render_manifest.json"), FileAccess.WRITE)
    if f == null:
        push_error("T13 manifest unavailable")
        quit(1)
        return
    f.store_string(JSON.stringify(evidence, "  "))
    f.close()
    print("ALCHUL T13 THREE ACTUAL GODOT SKINNED-CANDIDATE CAPTURES PASS")
    lab.queue_free()
    quit(0)
