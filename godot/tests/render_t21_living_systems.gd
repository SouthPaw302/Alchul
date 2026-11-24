extends SceneTree

## Three actual Godot frames from the separate living settlement prototype.
func _initialize() -> void:
    call_deferred("_run")


func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var frame: Image = root.get_texture().get_image()
    return frame != null and not frame.is_empty() and frame.save_png(path) == OK


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T21_CAPTURES")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t21_lived_settlement")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        push_error("T21 cannot create render directory")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var source: PackedScene = load("res://scenes/t21_living_systems_scene.tscn")
    if source == null:
        push_error("T21 prototype not found")
        quit(1)
        return
    var world: Node3D = source.instantiate()
    root.add_child(world)
    await process_frame
    if not await _capture(folder.path_join("01_four_working_sites.png")):
        push_error("T21 opening render failed")
        quit(1)
        return
    for action in ["survey","brace","relief","screen"]:
        if not world.take_action(action):
            push_error("T21 midgame action not available: " + action)
            quit(1)
            return
    if not await _capture(folder.path_join("02_a_costly_diversion.png")):
        push_error("T21 midgame render failed")
        quit(1)
        return
    for action in ["vent","warm","store","route"]:
        if not world.take_action(action):
            push_error("T21 endgame action not available: " + action)
            quit(1)
            return
    if not world.snapshot().get("all_systems_safe",false):
        push_error("T21 render is not an actual protected outcome")
        quit(1)
        return
    if not await _capture(folder.path_join("03_the_nursery_holds.png")):
        push_error("T21 ending render failed")
        quit(1)
        return
    var metadata: Dictionary = {
        "images":["01_four_working_sites.png","02_a_costly_diversion.png","03_the_nursery_holds.png"],
        "engine":"real Godot 4 Compatibility renderer; original imported M2",
        "dimensionless_story_study":true,
        "actual_hydraulic_calibration":false,
        "verified_species_anatomy":false,
        "actual_silurian_evidence":false,
        "T17_proxy_comparison_not_hydraulic_calibration":true,
        "public_chapter_modified":false
    }
    var out := FileAccess.open(folder.path_join("render_manifest.json"),FileAccess.WRITE)
    if out == null:
        push_error("T21 manifest could not open")
        quit(1)
        return
    out.store_string(JSON.stringify(metadata,"  "))
    out.close()
    print("ALCHUL T21 THREE NATIVE STORY VIEWS PASS")
    world.queue_free()
    quit(0)
