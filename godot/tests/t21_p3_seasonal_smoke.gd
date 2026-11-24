extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("T21.3 FAIL: " + message)
    quit(1)

func _run() -> void:
    var scene: PackedScene = load("res://scenes/t21_p3_seasonal_terrace.tscn")
    if scene == null:
        _fail("scene missing")
        return
    var world = scene.instantiate()
    root.add_child(world)
    await process_frame
    if world.start_calendar():
        _fail("calendar bypassed protected day")
        return
    for duty in ["survey","brace","relief","screen","vent","warm","store","route"]:
        if not world.take_action(duty):
            _fail("original action failed: " + duty)
            return
    var opening: Dictionary = world.snapshot()
    if not world.start_calendar() or world.start_calendar():
        _fail("calendar entry failed or allowed duplicate start")
        return
    var schedule: Array = [["care","teach"],["provision","rest"],["care","teach"],
        ["maintain","provision"],["care","rest"],["provision","replenish"],
        ["care","maintain"],["teach","provision"]]
    for pair in schedule:
        if not world.assign_duty(pair[0]) or world.assign_duty(pair[0]) or not world.assign_duty(pair[1]):
            _fail("duty selection / duplicate guard")
            return
    var report: Dictionary = world.calendar.report()
    if not report["continuity"] or report["ledger"].size() != 8 or report["opening_record"] != opening:
        _fail("continuity, eight days, or original record lost")
        return
    if report["ledger"][2]["phase"] != "Warm growth" or report["ledger"][6]["phase"] != "Cool return":
        _fail("season phases not advanced")
        return
    if world.assign_duty("rest") or world.snapshot() != opening:
        _fail("finished calendar mutable or original physical snapshot changed")
        return
    world.reset_day()
    if world.calendar.day != 0 or world.turn != 0:
        _fail("restart failed")
        return
    var bad = preload("res://scripts/t21_p3_seasonal_calendar.gd").new()
    bad.begin(opening)
    for i in range(8):
        bad.choose("teach")
        bad.choose("replenish")
    if bad.report()["continuity"] or bad.deficits == 0:
        _fail("neglect has no consequence")
        return
    print("T21.3 PASS — protected entry, 8 days, four phases, finite duties, continuity and neglect paths, preserved day, reset")
    world.queue_free()
    quit(0)
