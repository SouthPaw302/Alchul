extends SceneTree

## T21: test linked fictional choices. These checks do not validate paleontology.
func _initialize() -> void:
    call_deferred("_run")


func _fail(message: String) -> void:
    push_error("T21 LIVING SETTLEMENT FAIL: " + message)
    quit(1)


func _run() -> void:
    var scene: PackedScene = load("res://scenes/t21_living_systems_scene.tscn")
    if scene == null:
        _fail("separate T21 scene not available")
        return
    var world: Node3D = scene.instantiate()
    root.add_child(world)
    await process_frame

    var baseline: Dictionary = world.snapshot()
    if baseline.get("status","") != "PROVISIONAL_FICTIONAL_SETTLEMENT_NOT_HISTORY_OR_APPROVED_ANATOMY":
        _fail("lost era/provenance scope")
        return
    if int(baseline.get("visual_place_markers",0)) != 4:
        _fail("four linked workplace overlays missing")
        return
    if not bool(baseline.get("original_first_party_source",false)) or not bool(baseline.get("t17_proxy_available",false)):
        _fail("original M2 or independent ordinary sensing research missing")
        return
    if bool(baseline.get("anatomy_approved",true)) or bool(baseline.get("alchul_gave_inventions",true)):
        _fail("unsupported anatomy or paranormal technological cause")
        return
    if bool(baseline.get("calibrated_hydraulics",true)) or bool(baseline.get("human_archaeological_evidence",true)):
        _fail("fictional game quantities treated as measurements or Earth evidence")
        return
    if world.take_action("alchul_move_rock") or world.take_action("historical_proof"):
        _fail("unapproved magic or false history was treated as an action")
        return

    var start: Dictionary = world.snapshot()["state"]
    if not world.take_action("screen"):
        _fail("screened intake inaccessible")
        return
    var screened: Dictionary = world.snapshot()["state"]
    if float(screened["clarity"]) <= float(start["clarity"]):
        _fail("screen does not improve clarity")
        return
    if float(screened["food"]) >= float(start["food"]):
        _fail("screen has no cost to cultures")
        return

    world.reset_day()
    if not world.take_action("vent"):
        _fail("vent inaccessible")
        return
    var aired: Dictionary = world.snapshot()["state"]
    if float(aired["gas"]) >= float(start["gas"]) or float(aired["nursery"]) >= float(start["nursery"]):
        _fail("vent lacks gas/thermal trade-off")
        return

    world.reset_day()
    var actions: Array[String] = ["survey","brace","relief","screen","vent","warm","store","route"]
    for id in actions:
        if not world.take_action(id):
            _fail("cannot complete eight-watch strategy: " + id)
            return
    var success: Dictionary = world.snapshot()
    if int(success.get("turn",-1)) != 8 or not success.get("concluded",false):
        _fail("watch limit did not conclude")
        return
    if not bool(success.get("all_systems_safe",false)) or not str(success.get("ending","")).begins_with("PROTECTED"):
        _fail("tested mixed strategy failed to preserve linked systems: " + str(success.get("ending","")))
        return
    if world.wait_watch() or world.take_action("screen"):
        _fail("world still takes actions after ending")
        return
    if not bool(success.get("state",{}).get("route_safe",false)):
        _fail("nursery route not independently checked")
        return
    if float(success.get("state",{}).get("food",100)) >= float(start["food"]):
        _fail("trade-offs erased the cost of saved settlement")
        return

    world.reset_day()
    if int(world.snapshot().get("turn",-1)) != 0:
        _fail("reset did not clear the watches")
        return
    for i in range(8):
        if not world.wait_watch():
            _fail("passive neglect unexpectedly terminated early")
            return
    var neglected: Dictionary = world.snapshot()
    if not bool(neglected.get("concluded",false)) or bool(neglected.get("all_systems_safe",true)):
        _fail("indifference produces the same outcome as cooperation")
        return
    if world.get_node_or_null("T21LivingCivilizationWorkingHUD") == null:
        _fail("story control HUD missing")
        return
    print("ALCHUL T21 NATIVE PASS — four working places, eight-watch causal trade-offs, two endings, original M2, T17 comparison, no magical engineering")
    world.queue_free()
    quit(0)
