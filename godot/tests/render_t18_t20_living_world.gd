extends SceneTree

func _initialize() -> void:
    call_deferred("_run")


func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var shot: Image = root.get_texture().get_image()
    return shot != null and not shot.is_empty() and shot.save_png(path) == OK


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T18_T20_CAPTURES")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t18_t20_story")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        push_error("T18–T20 no render folder")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var scene: PackedScene = load("res://scenes/t18_t20_living_world_scene.tscn")
    if scene == null:
        push_error("T18–T20 no scene")
        quit(1)
        return
    var lab: Node3D = scene.instantiate()
    root.add_child(lab)
    await process_frame
    if not await _capture(folder.path_join("01_reed_bed_three_accounts.png")):
        push_error("T18–T20 first scene image failed")
        quit(1)
        return
    lab.set_lens("reading")
    lab.next_beat()
    lab.next_beat()
    if not await _capture(folder.path_join("02_two_interpretations.png")):
        push_error("T18–T20 second scene image failed")
        quit(1)
        return
    lab.choose_trial("support")
    lab.repeat_blind_test()
    if not await _capture(folder.path_join("03_support_answer.png")):
        push_error("T18–T20 third scene image failed")
        quit(1)
        return
    lab.choose_trial("ambiguous")
    lab.repeat_blind_test()
    lab.set_lens("unclosed")
    if not await _capture(folder.path_join("04_unclosed_account.png")):
        push_error("T18–T20 fourth scene image failed")
        quit(1)
        return
    var manifest: Dictionary = {
        "files":["01_reed_bed_three_accounts.png","02_two_interpretations.png",
            "03_support_answer.png","04_unclosed_account.png"],
        "engine":"Godot Compatibility; original M2 source model plus interpretive reed props",
        "fictional_worldbuilding":true,
        "historical_claim":false,
        "final_species_anatomy":false,
        "Alchul_form_or_pov":false,
        "actual_t17_physical_cause_logic":true,
        "public_chapter_modified":false
    }
    var text_file := FileAccess.open(folder.path_join("render_manifest.json"),FileAccess.WRITE)
    if text_file == null:
        push_error("T18–T20 render manifest unavailable")
        quit(1)
        return
    text_file.store_string(JSON.stringify(manifest,"  "))
    text_file.close()
    print("ALCHUL T18–T20 FOUR REAL GODOT FICTIONAL SETTLEMENT STORY VIEWS PASS")
    lab.queue_free()
    quit(0)
