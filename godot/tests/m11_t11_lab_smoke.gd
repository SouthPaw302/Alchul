extends SceneTree

## Native Godot test for scientific-status safeguards, not reproductive viability.
func _initialize() -> void:
    call_deferred("_run")

func _fail(why: String) -> void:
    push_error("ALCHUL T11 NATIVE FAIL: " + why)
    quit(1)


func _run() -> void:
    var packed: Resource = load("res://scenes/m11_t11_reproductive_lab.tscn")
    if not (packed is PackedScene):
        _fail("Scene not loaded")
        return
    var study: Node = (packed as PackedScene).instantiate()
    root.add_child(study)
    await process_frame
    var initial: Dictionary = study.call("summary")
    if initial.get("status", "") != "noncanonical_dimensionless_screening_not_biological_viability":
        _fail("Scientific status changed")
        return
    if not is_equal_approx(float(initial.get("canon_fraction", 0)), 0.75):
        _fail("75 percent development canon missing")
        return
    if int(initial.get("scenario_count", 0)) != 7:
        _fail("Expected seven controlled scenarios")
        return
    if initial.get("scenario", "") != "reference" or not initial.get("screening_pass", false):
        _fail("Reference screening mismatch")
        return
    for forbidden in ["real_biological_viability_verified", "embryonic_transfer_organ_known",
        "elapsed_time_calculated", "clutch_size_established"]:
        if initial.get(forbidden, true):
            _fail("Unvalidated inference asserted: " + forbidden)
            return
    var failures: Dictionary = {
        "internal_hypoxia":"internal_oxygen_index",
        "restrictive_internal_transfer":"internal_oxygen_index",
        "stagnant_nursery":"external_oxygen_index",
        "excessive_maternal_load":"maternal_load_index",
        "desiccating_nursery":"nursery_moisture_index",
        "overheated_nursery":"nursery_heat_index"
    }
    for name in failures.keys():
        if not study.call("select_scenario", name):
            _fail("Missing scenario " + name)
            return
        var state: Dictionary = study.call("summary")
        if bool(state.get("screening_pass", true)):
            _fail("Negative control falsely passed " + name)
            return
        if bool(state.get("constraints", {}).get(failures[name], true)):
            _fail("Specific negative-control signal missing: " + name)
            return
    if study.call("select_scenario", "biologically_verified"):
        _fail("Unreviewed scientific selection allowed")
        return
    if not study.call("select_scenario", "reference"):
        _fail("Cannot restore reference")
        return
    print("ALCHUL T11 NATIVE PASS — 7 scenarios, fixed 75 percent development, no invented organ or viability proof")
    study.queue_free()
    quit(0)
