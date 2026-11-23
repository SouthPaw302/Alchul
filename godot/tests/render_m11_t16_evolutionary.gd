extends SceneTree

func _initialize() -> void:
    call_deferred("_run")


func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var img: Image = root.get_texture().get_image()
    return img != null and not img.is_empty() and img.save_png(path) == OK


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T16_EVOLUTIONARY_CAPTURES")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t16_evolution")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        push_error("T16 EVOLUTION RENDER directory")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var packed: PackedScene = load("res://scenes/m11_t16_evolutionary_lab.tscn")
    if packed == null:
        push_error("T16 EVOLUTION RENDER scene")
        quit(1)
        return
    var lab: Node3D = packed.instantiate()
    root.add_child(lab)
    await process_frame
    lab.playing = false
    var pictures := ["01_three_evolutionary_models.png", "02_three_models_grip.png", "03_three_models_lod1.png"]
    lab.set_clip("rest")
    lab.set_evolutionary_focus("all")
    if not await _capture(folder.path_join(pictures[0])):
        push_error("T16 EVOLUTION RENDER rest")
        quit(1)
        return
    lab.set_clip("grip")
    lab.sample_pose(0.3)
    if not await _capture(folder.path_join(pictures[1])):
        push_error("T16 EVOLUTION RENDER grip")
        quit(1)
        return
    lab.set_lod(1)
    lab.set_clip("turn")
    lab.sample_pose(0.7)
    if not await _capture(folder.path_join(pictures[2])):
        push_error("T16 EVOLUTION RENDER LOD")
        quit(1)
        return
    var manifest := {"files":pictures, "study":lab.model_summary(),
        "engine":"Godot 4.7.2 Compatibility source scene",
        "science":"3 alternate functional evolutionary hypotheses not fossil-backed phenotypes",
        "real_species_prediction":false,"measured_allometry":false,
        "approved_anatomy":false,"approved_for_public_game":false}
    var out := FileAccess.open(folder.path_join("render_manifest.json"), FileAccess.WRITE)
    if out == null:
        push_error("T16 EVOLUTION RENDER manifest")
        quit(1)
        return
    out.store_string(JSON.stringify(manifest,"  "))
    out.close()
    print("ALCHUL T16 THREE EVOLUTIONARY 3D NATIVE GODOT CAPTURES PASS")
    lab.queue_free()
    quit(0)
