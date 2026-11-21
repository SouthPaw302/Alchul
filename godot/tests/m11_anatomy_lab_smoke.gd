extends SceneTree

## Native validation, NOT biological or render-fidelity approval.
## Run after Godot import: --headless --path godot --script res://tests/m11_anatomy_lab_smoke.gd

func _initialize() -> void:
    call_deferred("_run")


func _fail(message: String) -> void:
    push_error("ALCHUL M11 LAB FAIL: " + message)
    quit(1)


func _run() -> void:
    var packed: Resource = load("res://scenes/m11_anatomy_lab.tscn")
    if not (packed is PackedScene):
        _fail("standalone anatomy lab scene not importable")
        return
    var study: Node = (packed as PackedScene).instantiate()
    root.add_child(study)
    await process_frame

    var stats: Dictionary = study.call("validation_summary")
    if str(stats.get("status", "")) != "research_only_not_canon":
        _fail("candidate biology not marked provisional")
        return
    if int(stats.get("candidate_count", 0)) != 2:
        _fail("two competing study bodies not built")
        return
    if not str(stats.get("unit_system", "")).contains("not_meters"):
        _fail("drawing geometry is falsely implying real scale")
        return

    for hypothesis_id in ["H-A", "H-B"]:
        var candidate: Node = study.get_node_or_null("Candidate_" + hypothesis_id)
        if candidate == null:
            _fail("missing " + hypothesis_id)
            return
        if str(candidate.get_meta("hypothesis", "")) != hypothesis_id:
            _fail("hypothesis identity metadata missing")
            return
        if str(candidate.get_meta("measurement_status", "")) != "dimensionless_not_validated":
            _fail("unreviewed geometry presented as measured")
            return
        for side in ["Left", "Right"]:
            for digit in range(1, 4):
                if candidate.get_node_or_null("ManualDigit_%s_%d" % [side, digit]) == null:
                    _fail("missing separate non-primate manual digit: " + hypothesis_id)
                    return
                if candidate.get_node_or_null("PedalDigit_%s_%d" % [side, digit]) == null:
                    _fail("missing separate digitigrade toe: " + hypothesis_id)
                    return
        if candidate.get_node_or_null("IllustrativeHipDatumMarker") == null:
            _fail("matched-view pelvis reference absent")
            return

    if study.get_node_or_null("MatchedSideCamera") == null:
        _fail("same comparison camera required")
        return
    if study.get_node_or_null("ScientificUncertaintyHUD") == null:
        _fail("noncanonical uncertainty disclaimer not displayed")
        return
    if not bool(study.call("set_view_mode", "H-A")):
        _fail("unable to isolate hypothesis H-A")
        return
    if not study.get_node("Candidate_H-A").visible or study.get_node("Candidate_H-B").visible:
        _fail("H-A isolation broken")
        return
    if not bool(study.call("set_view_mode", "H-B")):
        _fail("unable to isolate hypothesis H-B")
        return
    if study.get_node("Candidate_H-A").visible or not study.get_node("Candidate_H-B").visible:
        _fail("H-B isolation broken")
        return
    if not bool(study.call("set_view_mode", "both")):
        _fail("unable to restore side-by-side view")
        return
    if bool(study.call("set_view_mode", "validated")):
        _fail("unapproved scientific status accepted as view")
        return
    print("ALCHUL M11 LAB PASS — distinct nonmetric H-A/H-B; digits, datum, view modes and safeguards")
    study.queue_free()
    quit(0)
