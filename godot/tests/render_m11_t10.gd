extends SceneTree

## Captures actual Godot-engine diagnostics, not measured animal motion.
func _initialize() -> void:
    call_deferred("_run")

func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = root.get_texture().get_image()
    return image != null and not image.is_empty() and image.save_png(path) == OK

func _run() -> void:
    root.size = Vector2i(1280, 720)
    var output: String = OS.get_environment("ALCHUL_T10_CAPTURES")
    if output.is_empty():
        output = ProjectSettings.globalize_path("user://t10_captures")
    if DirAccess.make_dir_recursive_absolute(output) != OK:
        push_error("T10 CAPTURE FAIL: output directory")
        quit(1)
        return
    var packed: Resource = load("res://scenes/m11_t10_corridor_lab.tscn")
    if not (packed is PackedScene):
        push_error("T10 CAPTURE FAIL: bad scene")
        quit(1)
        return
    var study: Node = (packed as PackedScene).instantiate()
    root.add_child(study)
    await process_frame
    if not study.set_frame(65):
        push_error("T10 CAPTURE FAIL: missing pose")
        quit(1)
        return
    if not study.select_width_index(2):
        push_error("T10 CAPTURE FAIL: missing narrow width")
        quit(1)
        return
    if not await _capture(output.path_join("01_width_2p8.png")):
        push_error("T10 CAPTURE FAIL: narrow image")
        quit(1)
        return
    if not study.select_width_index(5):
        push_error("T10 CAPTURE FAIL: missing broad width")
        quit(1)
        return
    if not await _capture(output.path_join("02_width_4p6.png")):
        push_error("T10 CAPTURE FAIL: wide image")
        quit(1)
        return
    var manifest: Dictionary = {"kind":"actual_Godot_4_native_engine_screenshot",
        "science_status":"NOT validated biology", "source_scene":"res://scenes/m11_t10_corridor_lab.tscn",
        "files":["01_width_2p8.png", "02_width_4p6.png"],
        "caption":"Rendered debug map, not game scene or dynamically simulated animal"}
    var file: FileAccess = FileAccess.open(output.path_join("native_manifest.json"), FileAccess.WRITE)
    if file == null:
        push_error("T10 CAPTURE FAIL: cannot write manifest")
        quit(1)
        return
    file.store_string(JSON.stringify(manifest, "  "))
    file.close()
    print("ALCHUL T10 TWO ACTUAL GODOT DIAGNOSTIC CAPTURES PASS")
    study.queue_free()
    quit(0)
