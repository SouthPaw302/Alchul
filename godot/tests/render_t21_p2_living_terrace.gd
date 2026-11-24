extends SceneTree

## Four genuine Godot images from one stateful, natively running T21.2 scene.
func _initialize() -> void:
    call_deferred("_run")


func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var result: Image = root.get_texture().get_image()
    return result != null and not result.is_empty() and result.save_png(path) == OK


func _run() -> void:
    var out: String = OS.get_environment("ALCHUL_T21P2_CAPTURES")
    if out.is_empty():
        out = ProjectSettings.globalize_path("user://t21_p2_visible_terrace")
    if DirAccess.make_dir_recursive_absolute(out) != OK:
        push_error("T21.2 unable to create screenshot directory")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var source: PackedScene = load("res://scenes/t21_p2_living_terrace.tscn")
    if source == null:
        push_error("T21.2 world unavailable for rendering")
        quit(1)
        return
    var world: Node3D = source.instantiate()
    root.add_child(world)
    await process_frame
    if not await _capture(out.path_join("01_morning_four_living_workplaces.png")):
        push_error("T21.2 opening view unavailable")
        quit(1)
        return
    for id in ["survey","brace"]:
        if not world.take_action(id):
            push_error("T21.2 bracket study failed: "+id)
            quit(1)
            return
    if not await _capture(out.path_join("02_read_stave_and_installed_brace.png")):
        push_error("T21.2 braced-bank view unavailable")
        quit(1)
        return
    for id in ["relief","screen"]:
        if not world.take_action(id):
            push_error("T21.2 water tradeoff failed: "+id)
            quit(1)
            return
    if not await _capture(out.path_join("03_flood_relief_and_screened_intake.png")):
        push_error("T21.2 filtered-culture view unavailable")
        quit(1)
        return
    for id in ["vent","warm","store","route"]:
        if not world.take_action(id):
            push_error("T21.2 household continuation failed: "+id)
            quit(1)
            return
    if not world.snapshot().get("all_systems_safe",false):
        push_error("T21.2 final view not actually safe")
        quit(1)
        return
    if not await _capture(out.path_join("04_nursery_route_and_open_vent.png")):
        push_error("T21.2 repaired community view unavailable")
        quit(1)
        return
    var meta: Dictionary = {
        "source":"Godot 4 native Compatibility renderer using original M2 and supplementary new procedural 3D",
        "captured":["01_morning_four_living_workplaces.png",
            "02_read_stave_and_installed_brace.png",
            "03_flood_relief_and_screened_intake.png",
            "04_nursery_route_and_open_vent.png"],
        "visible_processes":"4 linked workplaces + carrier/trade path + communication reeds",
        "time_model":"abstract eight-watch replay; ordinary material/process changes",
        "real_world_historical_claim":false,
        "calibrated_physics":false,
        "approved_species_bodies":false,
        "Chapter_I_modified":false
    }
    var file := FileAccess.open(out.path_join("render_manifest.json"), FileAccess.WRITE)
    if file == null:
        push_error("T21.2 render manifest missing")
        quit(1)
        return
    file.store_string(JSON.stringify(meta, "  "))
    file.close()
    print("ALCHUL T21.2 REAL NATIVE RENDER PASS — four stateful living process images")
    world.queue_free()
    quit(0)
