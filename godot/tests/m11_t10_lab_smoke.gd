extends SceneTree

## Tests the running Godot 4 debug scene, not real locomotor biomechanics.
func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("ALCHUL T10 NATIVE FAIL: " + message)
    quit(1)

func _run() -> void:
    var packed: Resource = load("res://scenes/m11_t10_corridor_lab.tscn")
    if not (packed is PackedScene):
        _fail("T10 debug scene not importable")
        return
    var study: Node = (packed as PackedScene).instantiate()
    root.add_child(study)
    await process_frame
    var first: Dictionary = study.call("summary")
    if not str(first.get("status", "")).contains("NOT_BIOLOGICAL_VALIDATION"):
        _fail("Scientific uncertainty lost")
        return
    if int(first.get("pose_count", 0)) != 101:
        _fail("L-turn poses absent or corrupted")
        return
    if not is_equal_approx(float(first.get("width", 0)), 2.8):
        _fail("Default corridor width differs from controlled study")
        return
    if bool(first.get("passed", {}).get("H-A", true)):
        _fail("H-A must collide with assumed narrow corridor")
        return
    if not bool(first.get("passed", {}).get("H-B", false)):
        _fail("H-B should pass assumed narrow corridor")
        return
    if first.get("force_closure_verified", true) or first.get("biological_gait_validated", true):
        _fail("Experimental geometry incorrectly certified as biology")
        return
    if not bool(study.call("select_width_index", 5)):
        _fail("Cannot select wider corridor")
        return
    var broad: Dictionary = study.call("summary")
    if not is_equal_approx(float(broad.get("width",0)), 4.6):
        _fail("Width selector inaccurate")
        return
    if not broad.get("passed",{}).get("H-A",false) or not broad.get("passed",{}).get("H-B",false):
        _fail("Both models should pass wider assumed corridor")
        return
    if bool(study.call("select_width_index", 400)) or bool(study.call("set_frame", 999)):
        _fail("Bad UI values must be rejected")
        return
    if not bool(study.call("set_frame", 100)):
        _fail("Last turn frame missing")
        return
    if not bool(study.call("set_highlight", "H-B")):
        _fail("Candidate selection not functioning")
        return
    if bool(study.call("set_highlight", "canonical")):
        _fail("Unapproved scientific state permitted")
        return
    print("ALCHUL T10 GODOT PASS — 101 real 2D viewport frames, controlled corridor width, science safeguards")
    study.queue_free()
    quit(0)
