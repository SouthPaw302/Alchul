extends SceneTree

## True Godot Compatibility screenshots, NOT illustrated Python reference art.
## Uses a noncanonical scene, no gameplay, no automated biological approval.
const NAMES: Array[String] = ["01_comparison","02_H-A","03_H-B"]

func _initialize() -> void:
    call_deferred("_run")

func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = root.get_texture().get_image()
    return image != null and not image.is_empty() and image.save_png(path) == OK

func _run() -> void:
    var out: String = OS.get_environment("ALCHUL_T07_CAPTURES")
    if out.is_empty():
        out = ProjectSettings.globalize_path("user://t07_captures")
    if DirAccess.make_dir_recursive_absolute(out) != OK:
        push_error("T07 CAPTURE FAIL: output folder unavailable")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var packed: Resource = load("res://scenes/m11_t07_joint_lab.tscn")
    if not (packed is PackedScene):
        push_error("T07 CAPTURE FAIL: no scene")
        quit(1)
        return
    var lab: Node = (packed as PackedScene).instantiate()
    root.add_child(lab)
    await process_frame
    var modes: Array[String] = ["both","H-A","H-B"]
    for i in range(modes.size()):
        if not lab.set_display_mode(modes[i]):
            push_error("T07 CAPTURE FAIL: missing view")
            quit(1)
            return
        var path: String = out.path_join(NAMES[i] + ".png")
        if not await _capture(path):
            push_error("T07 CAPTURE FAIL: could not save " + path)
            quit(1)
            return
    var manifest: Dictionary = {"kind":"actual_native_godot_compatibility_screenshots",
        "scene":"res://scenes/m11_t07_joint_lab.tscn",
        "status":"research_only_not_canon", "file_names":NAMES,
        "note":"No biomechanical, anatomical or artistic accuracy is established by a screenshot"}
    var file: FileAccess = FileAccess.open(out.path_join("render_manifest.json"),FileAccess.WRITE)
    if file == null:
        push_error("T07 CAPTURE FAIL: manifest write failed")
        quit(1)
        return
    file.store_string(JSON.stringify(manifest,"  "))
    file.close()
    print("ALCHUL T07 THREE ACTUAL NATIVE GODOT REFERENCE SCREENSHOTS PASS")
    lab.queue_free()
    quit(0)
