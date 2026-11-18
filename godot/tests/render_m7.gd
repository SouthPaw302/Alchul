extends SceneTree

## M7 visual regression capture for CI with xvfb + OpenGL Compatibility renderer.
## Output is actual Godot scene screenshots, unlike separate offline VTK studies.
## Never writes into the game project or alters the production branch.

const PATHS: Array[String] = [
	"01_m7_riverbank_overview",
	"02_m7_riverbank_walk",
	"03_m2_station_arrival",
	"04_m3_nursery_approach",
	"05_m4_harvest_precinct",
	"06_m5_connected_corridor",
	"07_m6_texture_inspection",
	"08_m7_rootwood_detail",
	"09_m7_water_approach",
	"10_m7_wide_panorama"
]
const POSITIONS: Array[Vector3] = [
	Vector3(36.0,16.0,23.0), Vector3(26.0,4.2,10.0),
	Vector3(18.0,7.0,16.0), Vector3(-27.0,8.5,21.0),
	Vector3(-16.0,7.0,5.0), Vector3(4.0,9.0,24.0),
	Vector3(20.0,3.0,4.0), Vector3(27.0,4.0,-9.0),
	Vector3(24.0,6.0,-15.0), Vector3(45.0,25.0,37.0)
]
const LOOK_AT: Array[Vector3] = [
	Vector3(18.0,0.2,-3.0), Vector3(20.0,0.5,-2.0),
	Vector3(8.0,0.4,-3.0), Vector3(-14.0,0.4,12.0),
	Vector3(-8.0,0.3,-2.0), Vector3(-7.0,0.5,7.0),
	Vector3(19.0,0.5,-3.0), Vector3(20.0,0.5,-5.0),
	Vector3(15.0,0.5,-11.0), Vector3(8.0,0.2,0.0)
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var raw: Resource = load("res://scenes/main.tscn")
	if not (raw is PackedScene):
		push_error("M7 VISUAL FAIL: cannot load main scene")
		quit(1)
		return
	var scene: Node = (raw as PackedScene).instantiate()
	root.size = Vector2i(960,540)
	root.add_child(scene)
	await process_frame

	var m7: Node = scene.get_node_or_null("M1RiverEnvironment_Candidate/M7GodotPBRMaterialPass_Candidate")
	if m7 == null:
		push_error("M7 VISUAL FAIL: candidate missing")
		quit(1)
		return
	var state: Dictionary = m7.call("validation_summary")
	if int(state.get("families", 0)) != 7:
		push_error("M7 VISUAL FAIL: incorrect material count")
		quit(1)
		return

	var cam := Camera3D.new()
	cam.name = "M7_ReviewCamera"
	cam.fov = 61.0
	cam.far = 250.0
	scene.add_child(cam)
	cam.make_current()
	var output_path: String = OS.get_environment("ALCHUL_M7_RENDER_DIR")
	if output_path.is_empty():
		output_path = ProjectSettings.globalize_path("user://m7_screens")
	var mk: Error = DirAccess.make_dir_recursive_absolute(output_path)
	if mk != OK:
		push_error("M7 VISUAL FAIL: unable to create output directory")
		quit(1)
		return

	var times: Array[int] = []
	for i in range(PATHS.size()):
		var start: int = Time.get_ticks_msec()
		cam.global_position = POSITIONS[i]
		cam.look_at(LOOK_AT[i], Vector3.UP)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var image: Image = root.get_texture().get_image()
		if image == null or image.is_empty():
			push_error("M7 VISUAL FAIL: image capture failed at " + PATHS[i])
			quit(1)
			return
		# Prevent a historic regression where the ground was invisible due to
		# triangle winding. This camera/pixel is part of the stable review rig.
		if i == 0:
			var ground: Color = image.get_pixel(480, 450)
			if ground.g > 0.56 or ground.b > 0.56:
				push_error("M7 VISUAL FAIL: floodplain pixel resembles sky; inspect terrain winding")
				quit(1)
				return
		var destination: String = output_path.path_join(PATHS[i] + ".png")
		if image.save_png(destination) != OK:
			push_error("M7 VISUAL FAIL: unable to save screenshot " + destination)
			quit(1)
			return
		times.append(Time.get_ticks_msec() - start)
		print("M7 GODOT FRAME ", i+1, "/10 -> ", destination)
	var summary := FileAccess.open(output_path.path_join("capture_metrics.json"), FileAccess.WRITE)
	if summary != null:
		summary.store_string(JSON.stringify({
			"renderer": "actual Godot 4 native scene under Xvfb/OpenGL Compatibility",
			"capture_ms": times,
			"frame_count": PATHS.size(),
			"resolution": [960,540],
			"material_state": state,
			"warning": "Capture latency is not GPU frame-rate benchmark; screenshots are candidates, not approved canon."
		}, "  "))
		summary.close()
	print("M7 GODOT CAPTURE PASS — 10 real engine screenshots")
	scene.queue_free()
	quit(0)
