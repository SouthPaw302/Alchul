extends SceneTree

func _initialize() -> void:
    call_deferred("_run")


func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = root.get_texture().get_image()
    return image != null and not image.is_empty() and image.save_png(path) == OK


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T16_CAPTURES")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t16")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        push_error("T16 RENDER directory")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var scene: PackedScene = load("res://scenes/m11_t16_experimental_inhabitants.tscn")
    if scene == null:
        push_error("T16 RENDER no experimental scene")
        quit(1)
        return
    var lab: Node3D = scene.instantiate()
    root.add_child(lab)
    await process_frame
    lab.set_motion("grip")
    if not await _capture(folder.path_join("01_original_river_station_two_rigs.png")):
        push_error("T16 RENDER M2 failed")
        quit(1)
        return
    if not lab.select_source("M4"):
        push_error("T16 RENDER M4 source")
        quit(1)
        return
    lab.set_motion("communicate")
    lab.set_quality(1)
    if not await _capture(folder.path_join("02_original_harvest_two_rigs.png")):
        push_error("T16 RENDER M4 failed")
        quit(1)
        return
    var evidence := {"engine":"Godot 4.7.2 Compatibility",
        "scene":"research-only original GLBs plus provisional actual skinned H-A and H-B",
        "files":["01_original_river_station_two_rigs.png","02_original_harvest_two_rigs.png"],
        "creator_approved":false, "main_game_default_visible":false,
        "stage_positions":"art-only illustration, uncalibrated, collision-free positions not validated",
        "production_frame_budget_verified":false,
        "baked_gltf_motion":false}
    var f := FileAccess.open(folder.path_join("render_manifest.json"), FileAccess.WRITE)
    if f == null:
        push_error("T16 RENDER manifest")
        quit(1)
        return
    f.store_string(JSON.stringify(evidence, "  "))
    f.close()
    print("ALCHUL T16 ACTUAL NATIVE GODOT RESEARCH CHARACTER CAPTURES PASS")
    lab.queue_free()
    quit(0)
