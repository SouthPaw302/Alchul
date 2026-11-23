extends SceneTree

## Scene regression of explicit scientific distinction, NOT ancestry approval.
func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("ALCHUL T12 NATIVE FAIL: " + message)
    quit(1)


func _run() -> void:
    var packed: Resource = load("res://scenes/m11_t12_era_people_lab.tscn")
    if not (packed is PackedScene):
        _fail("T12 scientific atlas scene not loadable")
        return
    var study: Node = (packed as PackedScene).instantiate()
    root.add_child(study)
    await process_frame
    var initial: Dictionary = study.call("summary")
    if initial.get("status", "") != "science_history_grounded_fiction_layer_explicit":
        _fail("Research label absent")
        return
    if initial.get("view", "") != "real_earth" or initial.get("selected_era", "") != "present_2026":
        _fail("Must default to real Earth and modern geology, not an invented modern animal")
        return
    if int(initial.get("era_count", 0)) != 9 or not initial.get("timeline_reaches_present", false):
        _fail("Chronology must extend through 2026")
        return
    if not initial.get("present_intraplate", false):
        _fail("Correct New Madrid intraplate tectonics missing")
        return
    for bad_field in ["modern_body_reconstructed", "nonavian_survival_established",
        "biology_approved", "fiction_is_real_world_observation"]:
        if initial.get(bad_field, true):
            _fail("Unsupported scientific promotion " + bad_field)
            return
    if study.call("select_era", 9) or study.call("select_era", -1):
        _fail("Non-existent era selectable")
        return
    if not study.call("select_era", 2):
        _fail("Cannot navigate to real 66Ma extinction boundary")
        return
    if study.call("summary").get("selected_era", "") != "kpg_boundary":
        _fail("K-Pg event not selectable")
        return
    if not study.call("set_view", "surface_candidates"):
        _fail("Research-only inhabitant comparison unavailable")
        return
    var person: Dictionary = study.call("summary")
    if int(person.get("role_count", 0)) != 6 or person.get("selected_role_era_scope", "") != "pre_kpg_peak_surface_undated":
        _fail("Six-person comparison must not be assigned a modern or exact geological date")
        return
    for name in ["water_reader", "independent_colleague", "egg_bearing_adult",
        "juvenile_learner", "nursery_worker", "harvest_specialist"]:
        if not study.call("select_role", name):
            _fail("Missing independent role " + name)
            return
    if study.call("select_role", "present_day_verified_species"):
        _fail("Unapproved modern species exposed")
        return
    if study.call("set_view", "factual_hidden_dinosaur") or study.call("select_era", -20):
        _fail("Improper fictional / unverified mode accepted")
        return
    print("ALCHUL T12 NATIVE PASS - 9 real eras to modern 2026, six provisional pre-KPg roles, hard evidence split")
    study.queue_free()
    quit(0)
