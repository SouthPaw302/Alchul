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
	# Visual regression images document the actual geometry, not the new title
	# overlay. The title/gameplay UI has a separate chapter full-loop test.
	var game: Node = scene.get_node_or_null("BraidedReachChapter")
	if game != null:
		game.visible = false

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
	var draw_calls: Array[int] = []
	var primitives: Array[int] = []
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
			var upper_sky: Color = image.get_pixel(480, 18)
			var ground_region: Color = image.get_pixel(480, 450)
			# Chapter I 1.1 intentionally uses green PBR foliage and brighter
			# textures. The old fixed 'green > 0.56' test falsely rejected
			# visible groundcover. Keep the real anti-invisible-terrain gate:
			# the lower scene must differ from the sky sampled from the same
			# actual native-engine frame.
			var red_delta: float = upper_sky.r - ground_region.r
			var green_delta: float = upper_sky.g - ground_region.g
			var blue_delta: float = upper_sky.b - ground_region.b
			if red_delta * red_delta + green_delta * green_delta + blue_delta * blue_delta < 0.0081:
				push_error("M7 VISUAL FAIL: lower-scene color indistinguishable from sky; inspect terrain winding")
				quit(1)
				return
		var destination: String = output_path.path_join(PATHS[i] + ".png")
		if image.save_png(destination) != OK:
			push_error("M7 VISUAL FAIL: unable to save screenshot " + destination)
			quit(1)
			return
		times.append(Time.get_ticks_msec() - start)
		# These counters are from the real Godot RenderingServer frame, not
		# estimates based on authored node count.
		draw_calls.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
		primitives.append(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME))
		print("M7 GODOT FRAME ", i+1, "/10 -> ", destination)
	var summary := FileAccess.open(output_path.path_join("capture_metrics.json"), FileAccess.WRITE)
	if summary != null:
		summary.store_string(JSON.stringify({
			"renderer": "actual Godot 4 native scene under Xvfb/OpenGL Compatibility",
			"capture_ms": times,
			"draw_calls_per_view": draw_calls,
			"primitives_per_view": primitives,
			"frame_count": PATHS.size(),
			"resolution": [960,540],
			"material_state": state,
			"warning": "Capture latency is not GPU frame-rate benchmark; screenshots are candidates, not approved canon."
		}, "  "))
		summary.close()
	print("M7 GODOT CAPTURE PASS — 10 real engine screenshots")
	scene.queue_free()
	quit(0)
