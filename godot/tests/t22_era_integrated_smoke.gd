extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _fail(reason: String) -> void:
    push_error("T22 FAIL: " + reason)
    quit(1)

func _run() -> void:
    var registry = preload("res://scripts/t22_era_registry.gd").new()
    if not registry.load_registry() or registry.data["eras"].size() != 5 or not FileAccess.file_exists(registry.earth_path()):
        _fail("registry or independent Earth index missing")
        return
    if not registry.allows("mature_surface","surface_m2") or registry.scene_for("mature_surface").is_empty():
        _fail("surface provenance missing")
        return
    for id in ["first_below","long_descent","kpg_aftermath","modern_new_madrid","unknown"]:
        if registry.allows(id,"surface_m2") or registry.allows(id,"late_egg_development") or not registry.scene_for(id).is_empty():
            _fail("era leakage: " + id)
            return
    for row in registry.data["eras"]:
        for denied in registry.data["global_denials"]:
            if registry.allows(row["id"],denied):
                _fail("global denial failed")
                return
    var atlas = load("res://scenes/t22_era_atlas.tscn").instantiate()
    root.add_child(atlas)
    await process_frame
    if not atlas.open_button.disabled or atlas.selection.item_count != 9 or "FICTIONAL ALCHUL OVERLAY" in atlas.details.text:
        _fail("Earth-only default lost")
        return
    atlas._select(8)
    if atlas.selection.selected != 8 or "Present-day New Madrid" not in atlas.details.text:
        _fail("Earth timeline selection out of sync")
        return
    atlas.earth_only.set_pressed_no_signal(false)
    atlas._toggle(false)
    if atlas.open_button.disabled or atlas.selection.item_count != 5:
        _fail("surface study not accessible")
        return
    atlas._select(4)
    if not atlas.open_button.disabled or atlas.selection.selected != 4:
        _fail("modern scene falsely available or selection out of sync")
        return
    atlas.queue_free()
    var world = load(registry.scene_for("mature_surface")).instantiate()
    root.add_child(world)
    await process_frame
    if world.choose_review("share_record") or world.integration_report()["water_visible"]:
        _fail("premature review or seasonal visualization")
        return
    for duty in ["survey","brace","relief","screen","vent","warm","store","route"]:
        if not world.take_action(duty):
            _fail("original day regression")
            return
    if not world.start_calendar():
        _fail("season start")
        return
    var rising: float = world.integration_report()["water_width"]
    var schedule: Array = [["care","teach"],["provision","rest"],["care","teach"],
        ["maintain","provision"],["care","rest"],["provision","replenish"],
        ["care","maintain"],["teach","provision"]]
    for i in range(schedule.size()):
        for duty in schedule[i]:
            if not world.assign_duty(duty):
                _fail("season duty")
                return
        if i == 3 and world.integration_report()["water_width"] >= rising:
            _fail("seasonal water marker did not change")
            return
    var before: Dictionary = world.calendar.report()
    if not before["continuity"] or world.integration_report()["visible_learning"] != 3:
        _fail("season record or learning markers")
        return
    if not world.choose_review("share_record") or world.choose_review("repeat_study") or world.calendar.report() != before:
        _fail("review rewrites history or is mutable")
        return
    world.toggle_ambience()
    if not world.integration_report()["sound_enabled"] or world.ambience.stream.data.size() != 88200:
        _fail("sound source missing")
        return
    world.toggle_ambience()
    world.reset_day()
    if world.integration_report()["water_visible"] or not world.review_choice.is_empty() or world.calendar.day != 0:
        _fail("reset")
        return
    print("T22 PASS — independent Earth, five eras, fail-closed scene gates, seasonal visuals, review integrity, sound source, reset")
    world.queue_free()
    quit(0)
