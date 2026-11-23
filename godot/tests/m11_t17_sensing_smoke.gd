extends SceneTree

func _initialize() -> void:
    call_deferred("_run")


func _fail(msg: String) -> void:
    push_error("T17 NATIVE FAIL: " + msg)
    quit(1)


func _run() -> void:
    var packed: PackedScene = load("res://scenes/m11_t17_physical_sensing_lab.tscn")
    if packed == null:
        _fail("scene unavailable")
        return
    var lab: Node3D = packed.instantiate()
    root.add_child(lab)
    await process_frame
    var summary: Dictionary = lab.scientific_summary()
    if int(summary.get("sources",0)) != 6 or int(summary.get("readers",0)) != 4 or summary.get("channels",[]).size() != 6:
        _fail("missing six physical causes/four readers")
        return
    if bool(summary.get("alchul_measured_signal",true)) or bool(summary.get("actual_physical_units",true)):
        _fail("fictional physical model misrepresented as measured physical sensor")
        return
    if bool(summary.get("evolved_species_organ_verified",true)) or bool(summary.get("contact_testimony_is_physical_data",true)):
        _fail("unapproved organ or supernatural testimony smuggled into physics")
        return
    var first: Dictionary = lab.sensor_reading("bank_reader","water",0.0)
    var repeat: Dictionary = lab.sensor_reading("bank_reader","water",0.0)
    if first.is_empty() or first != repeat:
        _fail("determinism or source not implemented")
        return
    if not lab.set_source_active("river_pulse",false):
        _fail("source cannot be disabled")
        return
    var second: Dictionary = lab.sensor_reading("bank_reader","water",0.0)
    if float(second.get("reading_normalized",999)) >= float(first["reading_normalized"]):
        _fail("real upstream water source does not affect sensor")
        return
    if lab.set_source_active("alchul_unknown_force",true):
        _fail("nonphysical unregistered signal accepted")
        return
    var suppressed: Dictionary = lab.sensor_reading("witness_reader","water",0.0,false)
    var injected: Dictionary = lab.sensor_reading("witness_reader","water",0.0,true)
    if not bool(injected.get("false_positive",false)) or float(injected.get("source_energy",999)) >= .05:
        _fail("false positive cannot be demonstrated without a real water source")
        return
    if not bool(injected.get("detect",false)) or bool(injected.get("is_Alchul_contact_evidence",true)):
        _fail("false positive incorrectly explained as contact proof")
        return
    if float(injected.get("reading_normalized",0)) <= float(suppressed.get("reading_normalized",0)):
        _fail("injected contamination missing")
        return
    if not lab.sensor_reading("invalid_person","gas",0).is_empty():
        _fail("invalid sensor accepted")
        return
    if not lab.sensor_reading("bank_reader","nonlocal_other_side",0).is_empty():
        _fail("nonphysical channel accepted")
        return
    if not lab.sensor_reading("bank_reader","heat",INF).is_empty():
        _fail("nonfinite time accepted")
        return
    lab.demo_false_positive = true
    var report: Dictionary = lab.update_readings()
    if report.keys().size() != 4 or lab.get_node_or_null("ScientificPhysicalSensorHUD") == null:
        _fail("native physical display and status not usable")
        return
    print("ALCHUL T17 GODOT PASS — 6 physical causes, 4 independent readers, source→signal→flag, deterministic noise and false alarm; 0 Alchul organ claims")
    lab.queue_free()
    quit(0)
