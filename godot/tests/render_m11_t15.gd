extends SceneTree

## Captures four ACTUAL Godot original M2-M5 source meshes, not concept art.
func _initialize() -> void:
    call_deferred("_run")


func _save(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var img: Image = root.get_texture().get_image()
    return img != null and not img.is_empty() and img.save_png(path) == OK


func _run() -> void:
    var folder: String = OS.get_environment("ALCHUL_T15_CAPTURES")
    if folder.is_empty():
        folder = ProjectSettings.globalize_path("user://t15_captures")
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        push_error("T15 RENDER FAIL: no folder")
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var packed: PackedScene = load("res://scenes/m11_t15_settlement_geometry_lab.tscn")
    if packed == null:
        push_error("T15 RENDER FAIL: no scene")
        quit(1)
        return
    var lab: Node3D = packed.instantiate()
    root.add_child(lab)
    await process_frame
    var outputs: Array[String] = []
    var inventory: Array = []
    for stage in ["M2","M3","M4","M5"]:
        if not lab.select_stage(stage):
            push_error("T15 RENDER FAIL: source " + stage)
            quit(1)
            return
        lab.set_synthetic_scale(1)
        lab.set_candidate("both")
        await physics_frame
        await physics_frame
        var inspection: Dictionary = lab.run_probe_suite()
        var file: String = "%s_original_GLB_geometry.png" % stage
        if not await _save(folder.path_join(file)):
            push_error("T15 RENDER FAIL: " + file)
            quit(1)
            return
        outputs.append(file)
        var audit: Dictionary = lab.geometry_summary()
        inventory.append({"stage":stage, "source_sha256":audit["source_sha256"],
            "mesh_nodes":audit["mesh_count"], "source_triangles":audit["source_triangles"],
            "source_uv_surfaces":audit["uv_surfaces"],
            "triangle_colliders":audit["triangle_colliders"],
            "synthetic_probes":inspection["results"],
            "conclusion":"NO WALKABLE CORRIDOR OR BODY SCALE ESTABLISHED"})
    var manifest: Dictionary = {"generator":"Godot 4 Compatibility 3D / actual imported first-party GLB",
        "site_count":4, "files":outputs, "stage_source_geometry":inventory,
        "science_status":"no true physical units, anatomy or settlement route certified",
        "creator_approval":false, "gameplay_changed":false}
    var f := FileAccess.open(folder.path_join("render_manifest.json"), FileAccess.WRITE)
    if f == null:
        push_error("T15 RENDER FAIL: cannot save manifest")
        quit(1)
        return
    f.store_string(JSON.stringify(manifest, "  "))
    f.close()
    print("ALCHUL T15 FOUR ORIGINAL-GLB NATIVE GODOT CAPTURES PASS")
    lab.queue_free()
    quit(0)
