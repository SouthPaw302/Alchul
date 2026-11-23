extends SceneTree

## Worldbuilding-level acceptance. Not a scientific biological-validation suite.
func _initialize() -> void:
    call_deferred("_run")


func _fail(message: String) -> void:
    push_error("T18–T20 STORY SCENE FAIL: " + message)
    quit(1)


func _run() -> void:
    var packed: PackedScene = load("res://scenes/t18_t20_living_world_scene.tscn")
    if packed == null:
        _fail("interactive scene missing")
        return
    var lab: Node3D = packed.instantiate()
    root.add_child(lab)
    await process_frame
    var metadata: Dictionary = lab.story_summary()
    if metadata.get("status") != "PROVISIONAL_FICTIONAL_CULTURE_NOT_ANATOMY_CANON":
        _fail("scene presented as true history or fixed biology")
        return
    if int(metadata.get("original_mesh_count",0)) < 1 or not metadata.get("t17_source_integrated",false):
        _fail("real original M2 or existing physical-cause engine not connected")
        return
    if int(metadata.get("lens_count",0)) != 3 or int(metadata.get("character_roles",0)) != 4:
        _fail("lost three worldview lenses or four narrative positions")
        return
    if int(metadata.get("proposed_gesture_count",0)) < 7 or int(metadata.get("trial_count",0)) != 3:
        _fail("nonhuman language or branching incident missing")
        return
    if metadata.get("alchul_entity_rendered",true) or metadata.get("body_anatomy_approved",true):
        _fail("Alchul ontology or unapproved body canon invented")
        return
    if lab.set_lens("alchul_point_of_view"):
        _fail("unallowed definitive Alchul POV lens")
        return
    if not lab.set_lens("unclosed") or lab.change_lens() != "trace":
        _fail("perspective switch does not cycle")
        return
    for i in range(3):
        if not lab.next_beat():
            _fail("story beat could not be advanced")
            return
    if lab.next_beat():
        _fail("story walked beyond authored opening")
        return
    if not lab.choose_trial("water"):
        _fail("river trial inaccessible")
        return
    var wet: Dictionary = lab.repeat_blind_test()
    if wet.is_empty() or wet.get("observer_readings",{}).get("river_listener","") != "bank pulse":
        _fail("river reading not causally responsive to water")
        return
    if wet.get("witness_claim_is_measured_Alchul",true):
        _fail("contact testimony improperly physicalized")
        return
    if not lab.choose_trial("support"):
        _fail("support test inaccessible")
        return
    var wood: Dictionary = lab.repeat_blind_test()
    if wood.get("observer_readings",{}).get("reed_turner","") != "support strain":
        _fail("repeated support reading not working")
        return
    if not lab.choose_trial("ambiguous"):
        _fail("ambiguous story ending inaccessible")
        return
    var noisy: Dictionary = lab.repeat_blind_test()
    if noisy.is_empty() or not noisy.get("disagreement",false):
        _fail("two observers cannot preserve different interpretations")
        return
    if noisy.get("safety_decision","") != "close_narrow_route_keep_broad_route_checked":
        _fail("cooperative safety amid disagreement missing")
        return
    var again: Dictionary = lab.repeat_blind_test()
    if again.get("physical_trace",{}) != noisy.get("physical_trace",{}):
        _fail("identical blind repeat has nonreproducible measured inputs")
        return
    if lab.story_summary().get("blind_records",0) != 2:
        _fail("separate repeated evidence entries not retained")
        return
    if lab.choose_trial("Alchul_is_a_person") or lab.choose_trial("historical_proof"):
        _fail("unauthorized interpretation was accepted as experimental truth")
        return
    lab.reset_scene()
    if lab.story_summary().get("blind_records",-1) != 0:
        _fail("new session did not clear the account bed")
        return
    if lab.get_node_or_null("T18T20FictionalSceneHUD") == null:
        _fail("story caption and controls missing")
        return
    print("ALCHUL T18–T20 NATIVE PASS — 3 perspectives, 7 multimodal gestures, 4 roles, 3 endings, independent disagreeing observers, reproducible T17 causes and no Alchul POV")
    lab.queue_free()
    quit(0)
