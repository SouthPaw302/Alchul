extends SceneTree

## T21.2 native review: genuine linked 3D process systems; no species claim.
func _initialize() -> void:
    call_deferred("_run")


func _fail(reason: String) -> void:
    push_error("T21.2 VISIBLE PROCESS FAIL: " + reason)
    quit(1)


func _run() -> void:
    var scene: PackedScene = load("res://scenes/t21_p2_living_terrace.tscn")
    if scene == null:
        _fail("native T21.2 scene missing")
        return
    var world: Node3D = scene.instantiate()
    root.add_child(world)
    await process_frame
    var first: Dictionary = world.living_process_report()
    if first.get("status","") != "FICTIONAL_MATURE_SURFACE_PROCESS_VISUALIZATION_NOT_CALIBRATED":
        _fail("strict fictional visual boundary lost")
        return
    if not first.get("original_m2_loaded",false) or int(first.get("process_sites",0)) != 4:
        _fail("lost M2 asset provenance or four maintained sites")
        return
    if int(first.get("process_groups",0)) < 6 or int(first.get("river_particles",0)) < 8:
        _fail("visible living work processes not instantiated")
        return
    if int(first.get("vessel_count",0)) != 4 or int(first.get("nursery_thermal_stones",0)) != 6:
        _fail("culture vessels or nursery warm stones absent")
        return
    if first.get("anatomically_approved_characters",true) or first.get("true_hydraulic_solver",true):
        _fail("unapproved anatomy or calibrated physics claimed")
        return
    if first.get("influence_is_an_engineering_cause",true) or first.get("public_chapter_modified",true):
        _fail("Alchul actuation or Chapter I integration fabricated")
        return
    if first.get("relief_visible",true) or first.get("brace_installed",true):
        _fail("unbuilt relief or brace visible before community work")
        return
    if world.get_node_or_null("T21LivingCivilizationWorkingHUD") == null:
        _fail("inherited original UI not available")
        return
    var stream: MeshInstance3D = world.water_drops[0]
    var before: Vector3 = stream.position
    world._process(1.0)
    if stream.position.distance_to(before) < 0.001:
        _fail("water does not visibly flow with the day clock")
        return
    var carrier: Node3D = world.labor_frame
    var carrier_before: Vector3 = carrier.position
    world._process(1.0)
    if carrier.position.distance_to(carrier_before) < 0.001:
        _fail("maintained materials do not move")
        return
    var sequence: Array[String] = [
        "survey","brace","relief","screen","vent","warm","store","route"]
    for step in sequence:
        if not world.take_action(step):
            _fail("linked decision not available: " + step)
            return
        var report: Dictionary = world.living_process_report()
        if step == "brace" and not report.get("brace_installed",false):
            _fail("no real visible repair after brace")
            return
        if step == "relief" and not report.get("relief_visible",false):
            _fail("no real visible diversion after relief cut")
            return
        if step == "screen" and not report.get("filter_installed",false):
            _fail("no real screen after cleaning intake")
            return
        if step == "vent" and not report.get("vent_open",false):
            _fail("no real opened chamber vent")
            return
        if step == "route" and not report.get("checked_route_lit",false):
            _fail("protected nursery evacuation markers not lit")
            return
    var finale: Dictionary = world.snapshot()
    if not finale.get("all_systems_safe",false) or not finale.get("concluded",false):
        _fail("T21.2 changed the T21.1 successful eight-watch causal sequence")
        return
    world.reset_day()
    var reset: Dictionary = world.living_process_report()
    if reset.get("relief_visible",true) or reset.get("filter_installed",true) or reset.get("checked_route_lit",true):
        _fail("new day does not restore visible work-site conditions")
        return
    print("T21.2 NATIVE PASS — original M2, 4 site processes, moving water/tools, reactively repaired bank, screened intake, nursery and vent, no anatomy/physics claims")
    world.queue_free()
    quit(0)
