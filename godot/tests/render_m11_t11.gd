extends SceneTree

## Actual Godot screenshots of research-only index curves, not embryo anatomy.
func _initialize() -> void:
    call_deferred("_run")

func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var img: Image = root.get_texture().get_image()
    return img != null and not img.is_empty() and img.save_png(path) == OK


func _run() -> void:
    var out: String = OS.get_environment("ALCHUL_T11_CAPTURES")
    if out.is_empty():
        out = ProjectSettings.globalize_path("user://t11_captures")
    if DirAccess.make_dir_recursive_absolute(out) != OK:
        push_error("T11 CAPTURE FAIL: output path")
        quit(1)
        return
    root.size = Vector2i(1280, 720)
    var scene: Resource = load("res://scenes/m11_t11_reproductive_lab.tscn")
    if not (scene is PackedScene):
        push_error("T11 CAPTURE FAIL: no real-engine research scene")
        quit(1)
        return
    var study: Node = (scene as PackedScene).instantiate()
    root.add_child(study)
    await process_frame
    if not await _capture(out.path_join("01_reference_screen.png")):
        push_error("T11 CAPTURE FAIL: reference")
        quit(1)
        return
    if not study.call("select_scenario", "internal_hypoxia"):
        push_error("T11 CAPTURE FAIL: missing controlled negative")
        quit(1)
        return
    if not await _capture(out.path_join("02_internal_hypoxia_screen.png")):
        push_error("T11 CAPTURE FAIL: negative case")
        quit(1)
        return
    var manifest: Dictionary = {
        "kind":"real_native_Godot_engine_screenshot",
        "scene":"res://scenes/m11_t11_reproductive_lab.tscn",
        "status":"dimensionless_NonCanon_not_viability",
        "development_boundary":0.75,
        "files":["01_reference_screen.png","02_internal_hypoxia_screen.png"]
    }
    var file: FileAccess = FileAccess.open(out.path_join("render_manifest.json"), FileAccess.WRITE)
    if file == null:
        push_error("T11 CAPTURE FAIL: manifest")
        quit(1)
        return
    file.store_string(JSON.stringify(manifest, "  "))
    file.close()
    print("ALCHUL T11 TWO ACTUAL GODOT REPRODUCTIVE INDEX CAPTURES PASS")
    study.queue_free()
    quit(0)
