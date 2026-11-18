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

	for candidate_path in [
		"M1RiverEnvironment_Candidate/M2RiverReadingStation_Candidate",
		"M1RiverEnvironment_Candidate/M3ProtectedNursery_Candidate",
		"M1RiverEnvironment_Candidate/M4HarvestPrecinct_Candidate",
		"M1RiverEnvironment_Candidate/M5SettlementConnectors_Candidate",
		"M1RiverEnvironment_Candidate/M6RiverbankMaterials_Candidate",
		"M1RiverEnvironment_Candidate/M7GodotPBRMaterialPass_Candidate"
	]:
		if scene.get_node_or_null(candidate_path) == null:
			push_error("ALCHUL SMOKE FAIL: missing study module " + candidate_path)
			quit(1)
			return

	var pbr_node: Node = scene.get_node_or_null("M1RiverEnvironment_Candidate/M7GodotPBRMaterialPass_Candidate")
	var pbr_state: Dictionary = pbr_node.call("validation_summary")
	if int(pbr_state.get("families",0)) != 7:
		push_error("ALCHUL M7 PBR FAIL: not all seven materials initialized")
		quit(1)
		return
	var detail_mesh: Node = scene.get_node_or_null("M1RiverEnvironment_Candidate/M6RiverbankMaterials_Candidate/DetailedRiverbankSurface")
	if not (detail_mesh is GeometryInstance3D):
		push_error("ALCHUL M7 PBR FAIL: surface mesh not instantiated")
		quit(1)
		return
	var applied_material: Material = (detail_mesh as GeometryInstance3D).material_override
	if not (applied_material is StandardMaterial3D):
		push_error("ALCHUL M7 PBR FAIL: native standard material missing")
		quit(1)
		return
	var standard_material := applied_material as StandardMaterial3D
	if standard_material.albedo_texture == null or standard_material.normal_texture == null or standard_material.roughness_texture == null:
		push_error("ALCHUL M7 PBR FAIL: PBR maps not bound")
		quit(1)
		return

	var camera: Node = scene.get_node_or_null("OutsideVisitor/VisitorCamera")
	if camera == null or not (camera is Camera3D):
		push_error("ALCHUL SMOKE FAIL: observer camera missing")
		quit(1)
		return

	var book: Dictionary = scene.get("worldbook")
	if book.get("schema", "") != "alchul.native-worldbook.v1":
		push_error("ALCHUL SMOKE FAIL: local worldbook schema")
		quit(1)
		return
	if book.get("sites", []).size() != 4:
		push_error("ALCHUL SMOKE FAIL: expected four local study places")
		quit(1)
		return

	scene.call("_set_lens", "resident")
	if scene.get("lens_id") != "resident":
		push_error("ALCHUL SMOKE FAIL: switching to resident view")
		quit(1)
		return
	scene.call("_set_lens", "contact")
	if scene.get("lens_id") != "contact":
		push_error("ALCHUL SMOKE FAIL: switching to contact view")
		quit(1)
		return

	print("ALCHUL GODOT NATIVE SMOKE PASS — 3D scene, local data, HUD, camera and lenses")
	scene.queue_free()
	quit(0)
