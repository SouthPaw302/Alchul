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
    var out: String = OS.get_environment("ALCHUL_T21P3_CAPTURES")
    if out.is_empty():
        out = ProjectSettings.globalize_path("user://t21_p3_captures")
    if DirAccess.make_dir_recursive_absolute(out) != OK:
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var world = load("res://scenes/t21_p3_seasonal_terrace.tscn").instantiate()
    root.add_child(world)
    await process_frame
    for duty in ["survey","brace","relief","screen","vent","warm","store","route"]:
        if not world.take_action(duty):
            quit(1)
            return
    if not world.start_calendar():
        quit(1)
        return
    if not await _capture(out.path_join("01_rising_water.png")):
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
        if i == 3:
            if not await _capture(out.path_join("02_lean_water.png")):
                quit(1)
                return
    if not world.calendar.report()["continuity"] or not await _capture(out.path_join("03_season_record_complete.png")):
        quit(1)
        return
    print("T21.3 native seasonal screenshots captured")
    world.queue_free()
    quit(0)
