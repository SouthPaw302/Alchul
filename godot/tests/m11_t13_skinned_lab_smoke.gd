extends SceneTree

## Native engine contract for actual skeletal skinning, procedural animation,
## material/LOD choices, and provenance. Not a biological validation.
func _initialize() -> void:
    call_deferred("_run")


func _die(message: String) -> void:
    push_error("T13 NATIVE FAIL: " + message)
    quit(1)


func _run() -> void:
    var source: Resource = load("res://scenes/m11_t13_skinned_character_lab.tscn")
    if not (source is PackedScene):
        _die("scene unavailable")
        return
    var lab: Node = (source as PackedScene).instantiate()
    root.add_child(lab)
    await process_frame
    var summary: Dictionary = lab.engineering_summary()
    if summary.get("status") != "provisional_surface_not_approved":
        _die("biology status upgraded without approval")
        return
    if bool(summary.get("biology_approved", true)) or bool(summary.get("modern_body_claim", true)):
        _die("unapproved anatomy claimed")
        return
    if summary.get("clips", []).size() != 5:
        _die("missing one of five motion cycles")
        return
    if summary.get("lod_count", 0) != 2 or summary.get("surface_variants", []).size() != 3:
        _die("missing LOD or texture variations")
        return
    for key in ["H-A", "H-B"]:
        var body: Node3D = lab.get_node_or_null("T07_" + key)
        if body == null:
            _die("missing candidate " + key)
            return
        var skeleton: Skeleton3D = body.get_node_or_null("ResearchSkeleton3D")
        if skeleton == null or skeleton.get_bone_count() != 43:
            _die("skinned model needs T07 43 reference controls")
            return
        for lod in range(2):
            var shell: MeshInstance3D = body.get_node_or_null("SkinnedShell_LOD" + str(lod))
            if shell == null or shell.mesh == null or shell.skin == null:
                _die("no actual skin or source geometry " + key)
                return
            if shell.mesh.get_surface_count() != 3:
                _die("three separable material families needed")
                return
            for surf in range(shell.mesh.get_surface_count()):
                var data: Array = shell.mesh.surface_get_arrays(surf)
                var vertices: PackedVector3Array = data[Mesh.ARRAY_VERTEX]
                var bone_ids: PackedInt32Array = data[Mesh.ARRAY_BONES]
                var weights: PackedFloat32Array = data[Mesh.ARRAY_WEIGHTS]
                if vertices.is_empty() or bone_ids.size() != vertices.size() * 4:
                    _die("vertex skin indices invalid")
                    return
                if weights.size() != vertices.size() * 4:
                    _die("vertex skin weights absent")
                    return
                for i in range(vertices.size()):
                    var sum: float = 0.0
                    for j in range(4):
                        var idx: int = bone_ids[i * 4 + j]
                        var w: float = weights[i * 4 + j]
                        if idx < 0 or idx >= skeleton.get_bone_count() or w < 0.0:
                            _die("invalid influence")
                            return
                        sum += w
                    if absf(sum - 1.0) > 0.00025: # GPU skin-weight packing quantizes even exact binary weights
                        _die("unnormalized skin weights %s/%d/%d = %.7f values=%s" % [key, surf, i, sum, str([weights[i*4], weights[i*4+1], weights[i*4+2], weights[i*4+3]])])
                        return
        var body_proxy: StaticBody3D = body.get_node_or_null("ProxyEnvelope_NotAnatomical")
        if body_proxy == null or body_proxy.get_child_count() < 2:
            _die("collision envelope missing")
            return
    for clip_name in ["walk", "turn", "grip", "rest", "communicate"]:
        if not lab.set_clip(clip_name) or not lab.sample_pose(0.25):
            _die("motion not reachable: " + clip_name)
            return
    if lab.set_clip("telekinesis") or lab.sample_pose(INF):
        _die("invalid clip or nonfinite phase allowed")
        return
    if not lab.set_clip("walk") or not lab.sample_pose(0.25):
        _die("walk missing")
        return
    var rig: Skeleton3D = lab.get_node("T07_H-A/ResearchSkeleton3D")
    var hip: int = rig.find_bone("femur_L")
    var first_pose: Quaternion = rig.get_bone_pose_rotation(hip)
    if not lab.sample_pose(0.75):
        _die("pose sample failed")
        return
    if first_pose.is_equal_approx(rig.get_bone_pose_rotation(hip)):
        _die("walk does not animate an actual skeletal joint")
        return
    if not lab.set_lod(1) or not lab.set_surface_variant("shade_moss"):
        _die("LOD/material switching rejected")
        return
    if lab.set_lod(999) or lab.set_surface_variant("approved_species"):
        _die("unrecognized quality or canon name accepted")
        return
    if lab.get_node_or_null("SkeletalStudyHud/T13State") == null:
        _die("visual scientific disclaimer absent")
        return
    print("ALCHUL T13 NATIVE PASS — two actual 43-bone skinned meshes, five cycles, 2 LOD, 3 material families, collision and canon gates")
    lab.queue_free()
    quit(0)
