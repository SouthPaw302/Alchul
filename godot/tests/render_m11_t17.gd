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
    var folder: String = OS.get_environment("ALCHUL_T17_CAPTURES")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t17")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        push_error("T17 capture directory")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var packed: PackedScene = load("res://scenes/m11_t17_physical_sensing_lab.tscn")
    if packed == null:
        push_error("T17 capture scene missing")
        quit(1)
        return
    var lab: Node3D = packed.instantiate()
    root.add_child(lab)
    await process_frame
    var shots: Array[String] = ["01_all_causes_on.png","02_water_source_off.png","03_false_alarm_test.png"]
    if not await _capture(folder.path_join(shots[0])):
        push_error("T17 first image")
        quit(1)
        return
    lab.set_source_active("river_pulse",false)
    if not await _capture(folder.path_join(shots[1])):
        push_error("T17 second image")
        quit(1)
        return
    lab.demo_false_positive = true
    lab.update_readings()
    if not await _capture(folder.path_join(shots[2])):
        push_error("T17 third image")
        quit(1)
        return
    var manifest := {"files":shots, "status":lab.scientific_summary(),
        "provenance":"Godot Compatibility renderer, original dimensionless illustrative physical-cause diagram",
        "real_sensor_organ":false,"contact_testimony_measured":false,
        "public_game_changed":false,"historical_archeological_fact":false}
    var f := FileAccess.open(folder.path_join("render_manifest.json"),FileAccess.WRITE)
    if f == null:
        push_error("T17 capture manifest unavailable")
        quit(1)
        return
    f.store_string(JSON.stringify(manifest,"  "))
    f.close()
    print("ALCHUL T17 THREE ACTUAL CAUSAL PHYSICAL SENSOR GODOT VIEWS PASS")
    lab.queue_free()
    quit(0)
