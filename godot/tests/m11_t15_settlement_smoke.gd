extends SceneTree

## Test real imported M2-M5 triangle-mesh provenance, not traversability or biology.
func _initialize() -> void:
    call_deferred("_run")


func _fail(why: String) -> void:
    push_error("T15 NATIVE FAIL: " + why)
    quit(1)


func _run() -> void:
    var packed: PackedScene = load("res://scenes/m11_t15_settlement_geometry_lab.tscn")
    if packed == null:
        _fail("scene missing")
        return
    var lab: Node3D = packed.instantiate()
    root.add_child(lab)
    await process_frame
    if lab.select_stage("H-C") or lab.set_candidate("approved") or lab.set_synthetic_scale(99):
        _fail("invalid candidate/stage/ratio not rejected")
        return
    for stage in ["M2","M3","M4","M5"]:
        if not lab.select_stage(stage):
            _fail("original GLB did not load " + stage)
            return
        await physics_frame
        await physics_frame
        var geometry: Dictionary = lab.geometry_summary()
        if geometry.get("stage","") != stage:
            _fail("stage mismatch " + stage)
            return
        if int(geometry.get("mesh_count",0)) < 1 or int(geometry.get("source_triangles",0)) < 1:
            _fail("source mesh triangles absent " + stage)
            return
        if int(geometry.get("triangle_colliders",0)) < 1:
            _fail("real triangle collision shapes missing " + stage)
            return
        if str(geometry.get("source_sha256","")).length() != 64:
            _fail("source asset SHA missing " + stage)
            return
        if geometry.get("status","") != "UNSCALED_ORIGINAL_MESH_INTERSECTIONS_NOT_TRAVERSABILITY":
            _fail("status promoted " + stage)
            return
        if bool(geometry.get("source_units_meters",true)) or bool(geometry.get("model_to_asset_scale_validated",true)):
            _fail("fabricated source/body unit calibration " + stage)
            return
        if bool(geometry.get("creator_anatomy_approved",true)) or bool(geometry.get("present_day_body_known",true)):
            _fail("scientific or creator decision invented " + stage)
            return
        var colliders: Node3D = lab.get_node("ActualSourceTriangleColliders")
        for node in colliders.get_children():
            if not (node is StaticBody3D):
                _fail("not a source-mesh physics body")
                return
            var child: CollisionShape3D = node.get_child(0)
            if not (child.shape is ConcavePolygonShape3D):
                _fail("synthetic box collider substituted for source triangle geometry")
                return
        var result: Dictionary = lab.run_probe_suite()
        if bool(result.get("walkability_verified",true)) or bool(result.get("approved_anatomy",true)):
            _fail("unsupported traversal or anatomy conclusion")
            return
        var entries: Dictionary = result.get("results",{})
        if entries.keys().size() != 2:
            _fail("competing body hypotheses missing")
            return
        for key in ["H-A","H-B"]:
            var variants: Array = entries.get(key,[])
            if variants.size() != 3:
                _fail("three calibration-sensitivity cases missing")
                return
            for scale_case in variants:
                if str(scale_case.get("traversability","")) != "UNKNOWN":
                    _fail("uncalibrated collisions used to certify access")
                    return
                var samples: Array = scale_case.get("triangle_collider_hits_per_probe",[])
                if samples.size() != 5:
                    _fail("not all 5 source-scene locations queried")
                    return
                for count in samples:
                    if int(count) < 0:
                        _fail("impossible negative overlap count")
                        return
        if not lab.set_candidate("H-A") or not lab.set_candidate("H-B"):
            _fail("candidate visualization missing")
            return
        if not lab.set_candidate("both") or not lab.set_synthetic_scale(2):
            _fail("scale display not interactive")
            return
    print("ALCHUL T15 GODOT PASS — 4 original source GLBs, triangle colliders, H-A/H-B x3 ratio x5 synthetic source-mesh probes, zero canon fit claims")
    lab.queue_free()
    quit(0)
