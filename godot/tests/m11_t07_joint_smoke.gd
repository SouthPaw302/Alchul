extends SceneTree

## Validates native Skeleton3D parent graph and bounded pose requests; not
## anatomy/biomechanics validation. No Chapter I modification.
func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("ALCHUL T07 JOINT FAIL: " + message)
    quit(1)

func _run() -> void:
    var resource: Resource = load("res://scenes/m11_t07_joint_lab.tscn")
    if not (resource is PackedScene):
        _fail("standalone T07 scene cannot load")
        return
    var lab: Node = (resource as PackedScene).instantiate()
    root.add_child(lab)
    await process_frame
    var summary: Dictionary = lab.validation_summary()
    if summary.get("status","") != "engineering_hypothesis_not_canon":
        _fail("T07 research status missing")
        return
    if not str(summary.get("unit_system","")).contains("not_meters"):
        _fail("T07 cannot claim physical body length")
        return
    for hypothesis in ["H-A","H-B"]:
        var rig: Node = lab.get_node_or_null("T07_" + hypothesis + "/ResearchSkeleton3D")
        if not (rig is Skeleton3D):
            _fail("missing actual Skeleton3D " + hypothesis)
            return
        var skeleton := rig as Skeleton3D
        if skeleton.get_bone_count() != 43:
            _fail("expected 43 bones for " + hypothesis)
            return
        for side in ["L","R"]:
            for digit in ["I","II","III"]:
                if skeleton.find_bone("manual_" + digit + "_1_" + side) < 0:
                    _fail("three-digit anatomy missing " + hypothesis)
                    return
            for digit in ["II","III","IV"]:
                if skeleton.find_bone("pedal_" + digit + "_" + side) < 0:
                    _fail("specialist pedal digit missing " + hypothesis)
                    return
            var carpus: int = skeleton.find_bone("carpus_" + side)
            var forearm: int = skeleton.find_bone("antebrachium_" + side)
            if skeleton.get_bone_parent(carpus) != forearm:
                _fail("forearm joint hierarchy wrong")
                return
        if skeleton.find_bone("human_thumb") >= 0:
            _fail("primate digit illegally introduced")
            return
    var rejected: Dictionary = lab.request_joint_pose("H-A", "forearm_axial_pronation", "L", 90.0)
    if bool(rejected.get("accepted",true)):
        _fail("unconstrained forearm roll accepted")
        return
    rejected = lab.request_joint_pose("H-B", "human_thumb_opposition", "R", 60.0)
    if bool(rejected.get("accepted",true)):
        _fail("mammalian thumb control accepted")
        return
    rejected = lab.request_joint_pose("H-A", "elbow_flex", "Q", 20.0)
    if bool(rejected.get("accepted",true)):
        _fail("invalid side accepted")
        return
    rejected = lab.request_joint_pose("H-A", "elbow_flex", "L", INF)
    if bool(rejected.get("accepted",true)):
        _fail("nonfinite angle accepted")
        return
    var posed: Dictionary = lab.request_joint_pose("H-B", "wrist_fold", "L", 95.0)
    if not bool(posed.get("accepted",false)) or not bool(posed.get("clamped",false)):
        _fail("placeholder wrist cap not enforced")
        return
    if not is_equal_approx(float(posed.get("applied_deg",-999)), 34.0):
        _fail("wrong bounded wrist cap")
        return
    var side_control: Dictionary = lab.request_joint_pose("H-A", "elbow_flex", "R", -35.0)
    if not bool(side_control.get("accepted",false)) or bool(side_control.get("clamped",true)):
        _fail("valid flexion movement refused")
        return
    if not lab.reset_candidate("H-B"):
        _fail("unable to reset experimental joint pose")
        return
    if not lab.set_display_mode("H-A") or lab.get_node("T07_H-B").visible:
        _fail("H-A selection failed")
        return
    if not lab.set_display_mode("both") or not lab.get_node("T07_H-B").visible:
        _fail("side-by-side compare restore failed")
        return
    if lab.set_display_mode("production-approved"):
        _fail("unapproved design mode allowed")
        return
    if lab.get_node_or_null("SkeletalStudyHud") == null:
        _fail("uncertainty HUD missing")
        return
    print("ALCHUL T07 NATIVE PASS — dual 43-bone Skeleton3D refs, mirrored digits, bounded joint poses, prohibited controls rejected")
    lab.queue_free()
    quit(0)
