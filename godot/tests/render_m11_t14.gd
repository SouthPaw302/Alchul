extends SceneTree

## 3 actual Godot raster captures from approval-gated T14 3D review scene.
func _initialize() -> void:
    call_deferred("_run")


func _snapshot(folder: String, name: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var image: Image = root.get_texture().get_image()
    return image != null and not image.is_empty() and image.save_png(folder.path_join(name)) == OK


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T14_CAPTURES")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t14_visual_review")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        push_error("ALCHUL T14 CAPTURE FAIL: folder")
        quit(1)
        return
    root.size = Vector2i(1280, 720)
    var res: PackedScene = load("res://scenes/m11_t14_creator_anatomy_review.tscn")
    if res == null:
        push_error("ALCHUL T14 CAPTURE FAIL: no source")
        quit(1)
        return
    var lab: Node = res.instantiate()
    root.add_child(lab)
    await process_frame
    lab.playing = false
    lab.set_review_focus("both")
    lab.set_clip("rest")
    lab.sample_pose(0.0)
    if not await _snapshot(folder, "01_side_by_side_review.png"):
        push_error("T14 comparison image failed")
        quit(1)
        return
    lab.set_review_focus("H-A")
    lab.set_clip("walk")
    lab.sample_pose(0.25)
    if not await _snapshot(folder, "02_long_tail_control.png"):
        push_error("T14 H-A image failed")
        quit(1)
        return
    lab.set_review_focus("H-B")
    lab.set_clip("grip")
    lab.sample_pose(0.75)
    if not await _snapshot(folder, "03_compact_tail_control.png"):
        push_error("T14 H-B image failed")
        quit(1)
        return
    var manifest: Dictionary = {
        "render":"actual Godot 4.7.2 Compatibility engine under Xvfb",
        "scope":"review only, undated pre-KPg hypotheses",
        "comparison":"T10 artificial normalized corridor; not real dimensions",
        "creator_approval":false,
        "files":["01_side_by_side_review.png",
            "02_long_tail_control.png","03_compact_tail_control.png"]
    }
    var file := FileAccess.open(folder.path_join("render_manifest.json"),FileAccess.WRITE)
    if file == null:
        push_error("T14 manifest failure")
        quit(1)
        return
    file.store_string(JSON.stringify(manifest,"  "))
    file.close()
    print("ALCHUL T14 THREE ACTUAL GODOT CREATOR REVIEW CAPTURES PASS")
    lab.queue_free()
    quit(0)
