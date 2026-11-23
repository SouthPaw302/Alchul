extends SceneTree

## Independent native Godot glTF2 readback of deterministic Python GLBs.
func _initialize() -> void:
    call_deferred("_run")


func _fail(reason: String) -> void:
    push_error("T16 PORTABLE GLB IMPORT FAIL: " + reason)
    quit(1)


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T16_EVOLUTIONARY_EXPORTS")
    if folder.is_empty():
        _fail("GLB test folder missing")
        return
    for id in ["E1","E2","E3"]:
        var path: String = folder.path_join("ALCHUL_T16_" + id + "_evolutionary_hypothesis.glb")
        if not FileAccess.file_exists(path):
            _fail("missing " + id)
            return
        var state := GLTFState.new()
        var doc := GLTFDocument.new()
        if doc.append_from_file(path,state) != OK:
            _fail("not a valid glTF2 asset " + id)
            return
        if state.skins.size() != 1:
            _fail("skin not portable " + id)
            return
        var scene: Node = GLTFDocument.new().generate_scene(state)
        if scene == null:
            _fail("Godot could not reconstruct " + id)
            return
        var maximum: int = 0
        for child in scene.find_children("*","Skeleton3D",true,false):
            maximum = maxi(maximum,(child as Skeleton3D).get_bone_count())
        if maximum < 43:
            _fail("lost all 43 reference control joints " + id)
            return
        scene.free()
    print("ALCHUL T16 THREE EXTERNAL GENERATOR GLB SKIN BINDINGS GODOT ROUNDTRIP PASS")
    quit(0)
