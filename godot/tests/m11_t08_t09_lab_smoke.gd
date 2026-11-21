extends SceneTree

## A native smoke of output markers and T07 integration, not paleobiology.
func _initialize() -> void:
    call_deferred("_run")

func _fail(detail: String) -> void:
    push_error("ALCHUL T08-T09 NATIVE FAIL: " + detail)
    quit(1)

func _run() -> void:
    var packed: Resource = load("res://scenes/m11_t08_t09_lab.tscn")
    if not (packed is PackedScene):
        _fail("no standalone analysis scene")
        return
    var lab: Node = (packed as PackedScene).instantiate()
    root.add_child(lab)
    await process_frame
    var summary: Dictionary = lab.validation_summary()
    if not str(summary.get("status", "")).contains("NOT_FOSSIL_DATA"):
        _fail("missing research-only marker")
        return
    if not str(summary.get("units", "")).contains("not_meters"):
        _fail("falsely implied real-world scale")
        return
    for hypothesis in ["H-A", "H-B"]:
        var skeleton: Node = lab.get_node_or_null("T07JointScaffold/T07_" + hypothesis + "/ResearchSkeleton3D")
        if not (skeleton is Skeleton3D) or (skeleton as Skeleton3D).get_bone_count() != 43:
            _fail("source skeletal reference absent " + hypothesis)
            return
        var rootnode: Node = lab.get_node_or_null("ProxyMarkers_" + hypothesis)
        if rootnode == null:
            _fail("proxy comparison markers absent " + hypothesis)
            return
        for child in ["CenterOfMass_Proxy", "SupportFootprint_Proxy",
            "FixtureTarget_I", "FixtureTarget_II", "FixtureTarget_III",
            "ComputedTip_I", "ComputedTip_II", "ComputedTip_III"]:
            if rootnode.get_node_or_null(child) == null:
                _fail("missing output marker " + child)
                return
    if not lab.show_case("right_foot_only"):
        _fail("cannot switch support scenario")
        return
    if not lab.show_fixture("far"):
        _fail("cannot switch fixture")
        return
    if lab.show_fixture("physically_validated") or lab.show_case("verified_gait"):
        _fail("unsupported claim accepted as scenario")
        return
    if lab.get_node_or_null("T08T09UncertaintyHud") == null:
        _fail("scientific uncertainty not labeled")
        return
    print("ALCHUL T08-T09 NATIVE PASS — real T07 rigs, COM markers, contact proxies and conservative scene switching")
    lab.queue_free()
    quit(0)
