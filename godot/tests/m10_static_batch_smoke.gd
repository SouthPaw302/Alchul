extends SceneTree

## M10: prove static batching keeps the generated station in-place, retains its
## triangle counts and reduces mesh node pressure without replacing source assets.
## Run with ALCHUL_M10_STATIC_BATCH=1 after engine --editor --import.
func _initialize() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("ALCHUL M10 STATIC BATCH FAIL: " + message)
	quit(1)

func _run() -> void:
	if OS.get_environment("ALCHUL_M10_STATIC_BATCH") == "0":
		_fail("optimization explicitly disabled")
		return
	var res: Resource = load("res://scenes/main.tscn")
	if not (res is PackedScene):
		_fail("main world absent")
		return
	var scene: Node = (res as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var m1: Node = scene.get_node_or_null("M1RiverEnvironment_Candidate")
	var m2: Node = scene.get_node_or_null("M1RiverEnvironment_Candidate/M2RiverReadingStation_Candidate")
	if m1 == null or m2 == null:
		_fail("procedural station unexpectedly missing")
		return
	var stats: Dictionary = m1.get("m10_static_batch_stats")
	var before: int = int(stats.get("original_nodes", 0))
	var after: int = int(stats.get("merged_nodes", 0))
	if not bool(stats.get("applied", false)):
		_fail("baking was not applied " + JSON.stringify(stats))
		return
	if before < 100 or after < 1 or after >= before:
		_fail("mesh count reduction invalid " + JSON.stringify(stats))
		return
	if int(stats.get("triangles_before", 0)) != int(stats.get("triangles_after", -1)):
		_fail("triangle conservation failed")
		return
	var actual_merged: int = 0
	for node in m2.get_children():
		if node is MeshInstance3D and str(node.name).begins_with("M10_BakedStatic_"):
			actual_merged += 1
	if actual_merged != after:
		_fail("merged runtime node count differs from reported " + str(after))
		return
	var extended: Dictionary = m1.get("m10_extended_batch_stats")
	var combined_before: int = before
	var combined_after: int = after
	for name in ["nursery", "harvest", "connective", "wetland_detail"]:
		if not extended.has(name):
			_fail("extended module never attempted: " + name)
			return
		var state: Dictionary = extended[name]
		if not bool(state.get("applied", false)):
			_fail("extended module did not batch: " + name + " " + JSON.stringify(state))
			return
		var count_before: int = int(state.get("original_nodes", 0))
		var count_after: int = int(state.get("merged_nodes", 0))
		if count_before < 10 or count_after < 1 or count_after >= count_before:
			_fail("invalid node reduction in " + name + ": " + JSON.stringify(state))
			return
		if int(state.get("triangles_before", -1)) != int(state.get("triangles_after", -2)):
			_fail("triangle mismatch in " + name)
			return
		combined_before += count_before
		combined_after += count_after
	var backdrop: Dictionary = scene.get("m10_world_visual_stats")
	if not bool(backdrop.get("applied", false)):
		_fail("background floodplain tree chunking not applied " + JSON.stringify(backdrop))
		return
	var vegetation_before: int = int(backdrop.get("original_nodes", 0))
	var vegetation_after: int = int(backdrop.get("merged_nodes", 0))
	if vegetation_before < 50 or vegetation_after < 1 or vegetation_after >= vegetation_before:
		_fail("incorrect chunked tree geometry reduction " + JSON.stringify(backdrop))
		return
	if int(backdrop.get("triangles_before", -1)) != int(backdrop.get("triangles_after", -2)):
		_fail("chunked tree triangles not conserved")
		return
	combined_before += vegetation_before
	combined_after += vegetation_after
	print("ALCHUL M10 TREE CHUNKED BATCH PASS: ", JSON.stringify(backdrop))
	print("ALCHUL M10 TOTAL STATIC NODE REDUCTION: ", combined_before, " -> ", combined_after)
	print("ALCHUL M10 EXTENDED BATCH PASS: ", JSON.stringify(extended))
	print("ALCHUL M10 STATIC BATCH PASS: ", JSON.stringify(stats))
	scene.queue_free()
	quit(0)
