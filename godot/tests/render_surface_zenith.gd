extends SceneTree
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    var dir: String = OS.get_environment("ALCHUL_ZENITH_CAPTURES")
    if dir.is_empty():
        dir = ProjectSettings.globalize_path("user://surface_zenith_views")
    if DirAccess.make_dir_recursive_absolute(dir) != OK:
        quit(1)
        return
    root.size = Vector2i(1280,720)
    var city = load("res://scenes/surface_zenith_city.tscn").instantiate()
    root.add_child(city)
    await process_frame
    if city.assets.size() != 10 or city.imported != 10 or city.placed < 90:
        push_error("Actual asset-backed city did not initialize")
        quit(1)
        return
    for i in range(city.views.size()):
        city.set_view(i)
        await process_frame
        await process_frame
        await RenderingServer.frame_post_draw
        var image: Image = root.get_texture().get_image()
        if image == null or image.is_empty() or image.save_png(dir.path_join(str(city.views[i][0])+".png")) != OK:
            quit(1)
            return
    print("Ten native asset-backed Godot captures complete; assets placed: ",city.placed)
    quit(0)
