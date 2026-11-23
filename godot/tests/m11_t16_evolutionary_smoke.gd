extends SceneTree

func _initialize() -> void:
    call_deferred("_run")


func _fail(msg: String) -> void:
    push_error("T16 EVOLUTIONARY 3D FAIL: " + msg)
    quit(1)


func _run() -> void:
    var packed: PackedScene = load("res://scenes/m11_t16_evolutionary_lab.tscn")
    if packed == null:
        _fail("evolved mesh scene missing")
        return
    var study: Node3D = packed.instantiate()
    root.add_child(study)
    await process_frame
    var report: Dictionary = study.model_summary()
    if report.get("status","") != "UNVALIDATED_EVOLUTIONARY_TRAJECTORY_HYPOTHESES_NOT_CANON":
        _fail("scientific provenance lost")
        return
    if report.get("candidate_count",-1) != 3 or report.get("creator_approved",true) or report.get("biological_approved",true):
        _fail("candidate count or approval invalid")
        return
    if report.get("present_day_morphology_known",true) or report.get("is_evolutionary_prediction",true):
        _fail("empirical predictive confidence invented")
        return
    var lengths: Array[float] = []
    var widths: Array[float] = []
    for key in ["E1","E2","E3"]:
        var group: Node3D = study.get_node_or_null("T07_" + key)
        if group == null:
            _fail("missing actual evolved candidate " + key)
            return
        var skeleton: Skeleton3D = group.get_node("ResearchSkeleton3D")
        if skeleton.get_bone_count() != 43:
            _fail("founder anatomy control topology corrupted")
            return
        for lod in range(2):
            var mesh: MeshInstance3D = group.get_node_or_null("SkinnedShell_LOD" + str(lod))
            if mesh == null or mesh.skin == null or mesh.mesh.get_surface_count() != 3:
                _fail("missing weighted UV research morphology " + key)
                return
            for surface in range(mesh.mesh.get_surface_count()):
                var a: Array = mesh.mesh.surface_get_arrays(surface)
                if (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).is_empty():
                    _fail("empty source skin surface")
                    return
                if (a[Mesh.ARRAY_BONES] as PackedInt32Array).size() != (a[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() * 4:
                    _fail("skin weights missing")
                    return
        var volume_count: int = 0
        for child in skeleton.get_children():
            if child is BoneAttachment3D:
                volume_count += 1
        if volume_count < 5:
            _fail("not enough modeled soft tissue scenarios")
            return
        var vals: Dictionary = report["models"][key]["proxy_geometry"]
        if vals.get("physical_metres",true) or vals.get("fossil_measurements",true):
            _fail("unearned body size metrics")
            return
        lengths.append(float(vals["axis_extent_normalized"]))
        widths.append(float(vals["pedal_lateral_width_proxy"]))
    if is_equal_approx(lengths[0],lengths[1]) or is_equal_approx(lengths[1],lengths[2]):
        _fail("morphological alternatives identical")
        return
    if is_equal_approx(widths[0],widths[2]):
        _fail("adaptive support variation absent")
        return
    if not study.set_evolutionary_focus("E2") or study.set_evolutionary_focus("H-C"):
        _fail("invalid evolution candidate accepted")
        return
    if not study.set_evolutionary_focus("all"):
        _fail("three-way comparison not reachable")
        return
    if not study.set_clip("grip") or not study.sample_pose(0.25):
        _fail("real skeletal motion cannot be applied")
        return
    var hip: Skeleton3D = study.get_node("T07_E2/ResearchSkeleton3D")
    var idx: int = hip.find_bone("femur_L")
    var prev: Quaternion = hip.get_bone_pose_rotation(idx)
    if not study.set_clip("walk") or not study.sample_pose(0.75):
        _fail("walking pose unavailable")
        return
    if prev.is_equal_approx(hip.get_bone_pose_rotation(idx)):
        _fail("joint does not change with new actual 3D character")
        return
    if study.get_node_or_null("EvolutionaryMorphologyBanner") == null:
        _fail("scientific disclaimer missing")
        return
    print("ALCHUL T16 EVOLVED MODELS NATIVE PASS — E1/E2/E3 distinct 43-control skinned and soft volume models, constrained morphology; zero canon")
    study.queue_free()
    quit(0)
