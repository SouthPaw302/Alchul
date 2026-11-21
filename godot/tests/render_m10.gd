extends SceneTree

## M10: ten actual Godot Compatibility screenshots of the isolated original asset pilot.
## Do not call these archaeological reconstructions, an approved canon image, or GPU FPS.
const SHOTS: Array[String] = [
	"01_m2_glb_original_overview",
	"02_m2_glb_station_approach",
	"03_m2_glb_canopy_geometry",
	"04_m2_glb_roof_bracing",
	"05_m2_glb_channel_faces",
	"06_m2_glb_station_side",
	"07_m6_original_pbr_seven_families",
	"08_m6_original_pbr_left_detail",
	"09_m6_original_pbr_right_detail",
	"10_m2_m6_original_wide"
]
const POSITIONS: Array[Vector3] = [
	Vector3(49, 31, 58), Vector3(16, 9, 27),
	Vector3(10, 13, 17), Vector3(-14, 12, 18),
	Vector3(3, 7, -16), Vector3(-22, 11, 3),
	Vector3(0, 12, 49), Vector3(-16, 5, 40),
	Vector3(18, 5, 41), Vector3(0, 51, 66)
]
const LOOK_AT: Array[Vector3] = [
	Vector3(0, 2, 3), Vector3(0, 1, 4),
	Vector3(0, 4, 5), Vector3(0, 4, 5),
	Vector3(0, 1, 5), Vector3(0, 1, 4),
	Vector3(0, 1, 28), Vector3(-15, 1, 28),
	Vector3(15, 1, 28), Vector3(0, 1, 7)
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var source: Resource = load("res://scenes/m10_import_pilot.tscn")
	if not (source is PackedScene):
		push_error("M10 CAPTURE FAIL: study scene missing")
		quit(1)
		return
	var scene: Node = (source as PackedScene).instantiate()
	root.size = Vector2i(960, 540)
	root.add_child(scene)
	await process_frame
	var camera: Camera3D = scene.get_node_or_null("M10ReviewCamera") as Camera3D
	if camera == null:
		push_error("M10 CAPTURE FAIL: review camera missing")
		quit(1)
		return
	var state: Dictionary = scene.call("validation_summary")
	var mats: Dictionary = state.get("m6_material_state", {})
	if int(state.get("station_mesh_nodes", 0)) < 19 or int(mats.get("original_asset_families", 0)) != 7:
		push_error("M10 CAPTURE FAIL: source GLB and original PBR maps not loaded")
		quit(1)
		return
	camera.make_current()
	var out: String = OS.get_environment("ALCHUL_M10_RENDER_DIR")
	if out.is_empty():
		out = ProjectSettings.globalize_path("user://m10_screens")
	if DirAccess.make_dir_recursive_absolute(out) != OK:
		push_error("M10 CAPTURE FAIL: cannot create screenshot directory")
		quit(1)
		return
	var timing: Array[int] = []
	for i in range(SHOTS.size()):
		var started: int = Time.get_ticks_msec()
		camera.global_position = POSITIONS[i]
		camera.look_at(LOOK_AT[i], Vector3.UP)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var screenshot: Image = root.get_texture().get_image()
		if screenshot == null or screenshot.is_empty():
			push_error("M10 CAPTURE FAIL: empty frame " + SHOTS[i])
			quit(1)
			return
		if screenshot.save_png(out.path_join(SHOTS[i] + ".png")) != OK:
			push_error("M10 CAPTURE FAIL: image save " + SHOTS[i])
			quit(1)
			return
		timing.append(Time.get_ticks_msec() - started)
		print("M10 ACTUAL GODOT CAPTURE ", i + 1, "/10: ", SHOTS[i])
	var m := FileAccess.open(out.path_join("capture_metrics.json"), FileAccess.WRITE)
	if m != null:
		m.store_string(JSON.stringify({
			"asset_import": state,
			"actual_native_engine_captures": SHOTS.size(),
			"capture_ms": timing,
			"resolution": [960, 540],
			"source_model_sha256": FileAccess.get_sha256("res://assets/m2/ALC_M2_RIVER_STATION_v001.glb"),
			"note": "Capture latency under software OpenGL is not player hardware FPS. Candidate only; human visual inspection required."
		}, "  "))
		m.close()
	print("ALCHUL M10 CAPTURE PASS: ten original-source native Godot frames")
	scene.queue_free()
	quit(0)
