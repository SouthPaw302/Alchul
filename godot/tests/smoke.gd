extends SceneTree

## Run: godot --headless --path godot --script res://tests/smoke.gd
## Native engine check. This is not a biology, visual-fidelity or browser-export review.

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var resource: Resource = load("res://scenes/main.tscn")
	if not (resource is PackedScene):
		push_error("ALCHUL SMOKE FAIL: main scene missing")
		quit(1)
		return

	var scene: Node = resource.instantiate()
	root.add_child(scene)
	await process_frame

	for node_name in [
		"WorkingFloodplain", "SchematicSurfaceWater", "IllustrativeWetlandFlora",
		"WorkingBodyStudy_NotCanonical", "OutsideVisitor", "InterpretationHUD"
	]:
		if scene.get_node_or_null(node_name) == null:
			push_error("ALCHUL SMOKE FAIL: node missing " + node_name)
			quit(1)
			return

	var camera: Node = scene.get_node_or_null("OutsideVisitor/VisitorCamera")
	if camera == null or not (camera is Camera3D):
		push_error("ALCHUL SMOKE FAIL: observer camera missing")
		quit(1)
		return

	var root_script: Node = scene
	if root_script.worldbook.get("schema", "") != "alchul.native-worldbook.v1":
		push_error("ALCHUL SMOKE FAIL: local worldbook schema")
		quit(1)
		return
	if root_script.worldbook.get("sites", []).size() != 4:
		push_error("ALCHUL SMOKE FAIL: expected four local study places")
		quit(1)
		return

	root_script._set_lens("resident")
	if root_script.lens_id != "resident":
		push_error("ALCHUL SMOKE FAIL: switching to resident view")
		quit(1)
		return
	root_script._set_lens("contact")
	if root_script.lens_id != "contact":
		push_error("ALCHUL SMOKE FAIL: switching to contact view")
		quit(1)
		return

	print("ALCHUL GODOT NATIVE SMOKE PASS — 3D scene, local data, HUD, camera and lenses")
	scene.queue_free()
	quit(0)
