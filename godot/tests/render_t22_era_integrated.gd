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
    var out: String = OS.get_environment("ALCHUL_T22_CAPTURES")
    if out.is_empty():
        out = ProjectSettings.globalize_path("user://t22_captures")
    if DirAccess.make_dir_recursive_absolute(out) != OK:
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var world = load("res://scenes/t21_p9_integrated_settlement.tscn").instantiate()
    root.add_child(world)
    await process_frame
    for duty in ["survey","brace","relief","screen","vent","warm","store","route"]:
        if not world.take_action(duty):
            quit(1)
            return
    if not world.start_calendar() or not await _capture(out.path_join("01_rising_water.png")):
        quit(1)
        return
    var schedule: Array = [["care","teach"],["provision","rest"],["care","teach"],
        ["maintain","provision"],["care","rest"],["provision","replenish"],
        ["care","maintain"],["teach","provision"]]
    for i in range(schedule.size()):
        for duty in schedule[i]:
            if not world.assign_duty(duty):
                quit(1)
                return
        if i == 3 and not await _capture(out.path_join("02_lean_water.png")):
            quit(1)
            return
    if not world.choose_review("share_record") or not await _capture(out.path_join("03_council_record.png")):
        quit(1)
        return
    world.queue_free()
    await process_frame
    var atlas = load("res://scenes/t22_era_atlas.tscn").instantiate()
    root.add_child(atlas)
    await process_frame
    atlas._select(4)
    if not await _capture(out.path_join("04_modern_earth_only.png")):
        quit(1)
        return
    atlas.earth_only.button_pressed = false
    atlas._refresh()
    if not await _capture(out.path_join("05_modern_fiction_locked.png")):
        quit(1)
        return
    print("T22 native captures complete")
    quit(0)
