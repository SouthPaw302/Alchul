extends SceneTree

## Actual native Godot screenshots only: this is not the Python matplotlib render.
const MODES: Array[String] = ["01_neutral_near", "02_one_foot_far"]

func _initialize() -> void:
    call_deferred("_run")

func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var captured: Image = root.get_texture().get_image()
    return captured != null and not captured.is_empty() and captured.save_png(path) == OK

func _run() -> void:
    var out: String = OS.get_environment("ALCHUL_T08_T09_CAPTURES")
    if out.is_empty():
        out = ProjectSettings.globalize_path("user://t08_t09_captures")
    if DirAccess.make_dir_recursive_absolute(out) != OK:
        push_error("T08-T09 SCREENSHOT FAIL: folder")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var packed: Resource = load("res://scenes/m11_t08_t09_lab.tscn")
    if not (packed is PackedScene):
        push_error("T08-T09 SCREENSHOT FAIL: scene missing")
        quit(1)
        return
    var lab: Node = (packed as PackedScene).instantiate()
    root.add_child(lab)
    await process_frame
    if not await _capture(out.path_join(MODES[0] + ".png")):
        push_error("T08-T09 SCREENSHOT FAIL: neutral")
        quit(1)
        return
    lab.show_case("right_foot_only")
    lab.show_fixture("far")
    if not await _capture(out.path_join(MODES[1] + ".png")):
        push_error("T08-T09 SCREENSHOT FAIL: one-foot")
        quit(1)
        return
    var meta: Dictionary = {"kind":"genuine_native_godot_screenshots",
        "scene":"res://scenes/m11_t08_t09_lab.tscn",
        "status":"noncanonical engineering assumptions, not biological proof",
        "images":MODES}
    var file: FileAccess = FileAccess.open(out.path_join("capture_manifest.json"),FileAccess.WRITE)
    if file == null:
        push_error("T08-T09 SCREENSHOT FAIL: manifest")
        quit(1)
        return
    file.store_string(JSON.stringify(meta, "  "))
    file.close()
    print("ALCHUL T08-T09 TWO REAL GODOT STUDY CAPTURES PASS")
    lab.queue_free()
    quit(0)
