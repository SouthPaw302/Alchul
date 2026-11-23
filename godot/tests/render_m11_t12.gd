extends SceneTree

## Actual Godot engine scenes, not user-facing scientific reconstruction of bodies.
func _initialize() -> void:
    call_deferred("_run")


func _save(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var img: Image = root.get_texture().get_image()
    return img != null and not img.is_empty() and img.save_png(path) == OK


func _run() -> void:
    var out: String = OS.get_environment("ALCHUL_T12_CAPTURES")
    if out.is_empty():
        out = ProjectSettings.globalize_path("user://t12_captures")
    if DirAccess.make_dir_recursive_absolute(out) != OK:
        push_error("T12 CAPTURE FAIL: target folder")
        quit(1)
        return
    root.size = Vector2i(1280, 720)
    var scene: Resource = load("res://scenes/m11_t12_era_people_lab.tscn")
    if not (scene is PackedScene):
        push_error("T12 CAPTURE FAIL: scene missing")
        quit(1)
        return
    var study: Node = (scene as PackedScene).instantiate()
    root.add_child(study)
    await process_frame
    if not await _save(out.path_join("01_real_world_present_2026.png")):
        push_error("T12 CAPTURE FAIL: real-world view")
        quit(1)
        return
    if not study.call("select_era", 2):
        push_error("T12 CAPTURE FAIL: extinction boundary absent")
        quit(1)
        return
    if not await _save(out.path_join("02_kpg_extinction_boundary.png")):
        push_error("T12 CAPTURE FAIL: K-Pg")
        quit(1)
        return
    if not study.call("set_view", "surface_candidates"):
        push_error("T12 CAPTURE FAIL: inhabitant study unavailable")
        quit(1)
        return
    if not await _save(out.path_join("03_six_provisional_surface_roles.png")):
        push_error("T12 CAPTURE FAIL: provisional roles")
        quit(1)
        return
    var manifest: Dictionary = {
        "kind":"actual_native_Godot_Compatibility_screenshots",
        "stage":"M11_T12",
        "evidence_scope":"real_history_separate_from_fiction",
        "science_status":"NO extinct non-avian dinosaur survival scientifically established",
        "people_scope":"undated pre-KPg surface; no present body plan",
        "files":["01_real_world_present_2026.png",
            "02_kpg_extinction_boundary.png", "03_six_provisional_surface_roles.png"]
    }
    var file: FileAccess = FileAccess.open(out.path_join("render_manifest.json"), FileAccess.WRITE)
    if file == null:
        push_error("T12 CAPTURE FAIL: no manifest")
        quit(1)
        return
    file.store_string(JSON.stringify(manifest, "  "))
    file.close()
    print("ALCHUL T12 THREE ACTUAL GODOT SCIENCE-FIRST ATLAS CAPTURES PASS")
    study.queue_free()
    quit(0)
