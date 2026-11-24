extends SceneTree
func _initialize() -> void:
    call_deferred("_run")
func _capture(path: String) -> bool:
    await process_frame
    await process_frame
    await RenderingServer.frame_post_draw
    var img: Image = root.get_texture().get_image()
    return img != null and not img.is_empty() and img.save_png(path) == OK
func _run() -> void:
    var dir: String = OS.get_environment("ALCHUL_ZENITH_CAPTURES")
    if dir.is_empty():
        dir = ProjectSettings.globalize_path("user://surface_zenith_fidelity_views")
    if DirAccess.make_dir_recursive_absolute(dir) != OK:
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var city = load("res://scenes/surface_zenith_fidelity_city.tscn").instantiate()
    root.add_child(city)
    await process_frame
    if city.assets.size()!=10 or city.imported!=10 or city.placed<90 or city.river_material==null:
        quit(1)
        return
    var initial: float = city.wave_time
    await process_frame
    if city.wave_time<=initial:
        quit(1)
        return
    for i in range(city.views.size()):
        city.set_view(i)
        if not await _capture(dir.path_join(str(city.views[i][0])+".png")):
            quit(1)
            return
    var sk: Skeleton3D = city.study_rig.get_node("T07_E2/ResearchSkeleton3D")
    var shell: MeshInstance3D = city.study_rig.get_node("T07_E2/SkinnedShell_LOD0")
    if sk.get_bone_count()!=43 or shell.skin==null:
        quit(1)
        return
    city.toggle_rig()
    if not city.visible_t16 or not await _capture(dir.path_join("11_separate_t16_weighted_rig.png")):
        quit(1)
        return
    print("PASS 02: ten textured city views + one separate weighted-rig view, active water clock")
    quit(0)
