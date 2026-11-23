extends SceneTree

## Verify T16 is real skinned/rigged geometry but never silently live or canon.
func _initialize() -> void:
    call_deferred("_run")


func _fail(why: String) -> void:
    push_error("T16 NATIVE FAIL: " + why)
    quit(1)


func _run() -> void:
    var public_scene: PackedScene = load("res://scenes/main.tscn")
    if public_scene == null:
        _fail("live chapter missing")
        return
    var game: Node = public_scene.instantiate()
    root.add_child(game)
    await process_frame
    if game.get_node_or_null("ExperimentalInhabitants_NotReleased") != null:
        _fail("public game must have no T16 model, experimental hook or surplus assets")
        return
    if game.get_node_or_null("BraidedReachChapter") == null:
        _fail("playable game lost")
        return
    game.queue_free()
    await process_frame

    var study: PackedScene = load("res://scenes/m11_t16_experimental_inhabitants.tscn")
    if study == null:
        _fail("T16 review stage missing")
        return
    var lab: Node3D = study.instantiate()
    root.add_child(lab)
    await process_frame
    var summary: Dictionary = lab.integration_summary()
    if summary.get("actor_count", 0) != 3 or not summary.get("actual_43_bone_skinned", false):
        _fail("three evolutionary weighted inhabitants not staged")
        return
    if not summary.get("source_original_glb", false) or int(summary.get("source_meshes",0)) < 1:
        _fail("no original first party source settlement model")
        return
    if summary.get("creator_approved", true) or summary.get("canon_promoted", true) or summary.get("production_frame_budget_verified", true):
        _fail("research incorrectly promoted to production")
        return
    var rig: Node = lab.get_node_or_null("EvolutionaryWeightedRig_NotCanon")
    if rig == null:
        _fail("T13 source rig not instanced")
        return
    if (rig.get_node("MatchedT07Camera") as Camera3D).current:
        _fail("T13 reference camera takes over scene")
        return
    for key in ["E1","E2","E3"]:
        var body: Node3D = rig.get_node("T07_" + key)
        var skeleton: Skeleton3D = body.get_node("ResearchSkeleton3D")
        if skeleton.get_bone_count() != 43:
            _fail("missing weighted reference joints")
            return
        for lod in range(2):
            var mesh: MeshInstance3D = body.get_node("SkinnedShell_LOD" + str(lod))
            if mesh.mesh == null or mesh.skin == null or mesh.mesh.get_surface_count() != 3:
                _fail("actual 3 material weighted mesh source absent")
                return
    for source in ["M2","M3","M4","M5"]:
        if not lab.select_source(source):
            _fail("source GLB did not import " + source)
            return
        if int(lab.integration_summary().get("source_meshes",0)) < 1:
            _fail("source meshes missing for " + source)
            return
    for movement in ["walk","turn","grip","rest","communicate"]:
        if not lab.set_motion(movement):
            _fail("movement missing " + movement)
            return
    if lab.set_motion("unsupported_telekinesis"):
        _fail("unsupported power control accepted")
        return
    if not lab.set_quality(0) or not lab.set_quality(1) or lab.set_quality(3):
        _fail("LOD bounds not enforced")
        return
    lab.disable_experiment()
    if lab.integration_summary().get("actor_count", -1) != 0 or lab.set_motion("walk"):
        _fail("research shutdown did not remove actors")
        return
    print("ALCHUL T16 NATIVE PASS: default game gated; 3 distinct evolutionary skinned rigs on 4 original source GLBs, 5 cycles, 2 LOD, 0 species approvals")
    lab.queue_free()
    quit(0)
