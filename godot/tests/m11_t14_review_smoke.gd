extends SceneTree

## Actual Godot review must retain both weighted provisional rigs and reject
## unauthorized creator approval. T14 delivery is the *review*, not acceptance.
func _initialize() -> void:
    call_deferred("_run")


func _fail(why: String) -> void:
    push_error("ALCHUL T14 NATIVE FAIL: " + why)
    quit(1)


func _run() -> void:
    var res: PackedScene = load("res://scenes/m11_t14_creator_anatomy_review.tscn")
    if res == null:
        _fail("scene source absent")
        return
    var lab: Node = res.instantiate()
    root.add_child(lab)
    await process_frame
    var result: Dictionary = lab.review_summary()
    if result.get("status","") != "DECISION_PENDING_NOT_CANON":
        _fail("creator science gate pre-approved")
        return
    if int(result.get("hypotheses",0)) != 3 or int(result.get("scientific_gate_count",0)) != 6:
        _fail("no independent alternative or research limits")
        return
    if int(result.get("comparative_meshes",0)) != 2:
        _fail("real skinned A/B models unavailable")
        return
    if bool(result.get("modern_species_claim",true)) or bool(result.get("creator_approval_recorded",true)):
        _fail("surface/provisional models incorrectly made canonical/modern")
        return
    if bool(result.get("hybrid_built",true)) or bool(result.get("can_auto_approve",true)):
        _fail("nonexistent hybrid or implied autorization")
        return
    if lab.get_node_or_null("T14ReviewLayer") == null:
        _fail("review controls and evidence HUD absent")
        return
    for option in ["both","H-A","H-B"]:
        if not lab.set_review_focus(option):
            _fail("review option unavailable " + option)
            return
        var state: Dictionary = lab.review_summary()
        if state.get("selected","") != option:
            _fail("review option does not change actual mode")
            return
    if lab.set_review_focus("H-C") or lab.set_review_focus("modern"):
        _fail("unsupported unbuilt hypotheses selectable")
        return
    for decision in ["provisional_H-A","provisional_H-B","commission_revised_hybrid","defer_all"]:
        if lab.record_creator_approval(decision):
            _fail("research scene cannot grant actual creator approval")
            return
    if lab.get_node("T07_H-A/SkinnedShell_LOD0").mesh == null:
        _fail("original weighted source geometry missing")
        return
    if lab.get_node("T07_H-B/ResearchSkeleton3D").get_bone_count() != 43:
        _fail("comparative skeleton provenance lost")
        return
    print("ALCHUL T14 NATIVE PASS — 2 actual skinned hypotheses, 3 review options, 6 unclosed gates, 0 creator approvals")
    lab.queue_free()
    quit(0)
