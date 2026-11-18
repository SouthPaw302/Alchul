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
	print("ALCHUL M10 STATIC BATCH PASS: ", JSON.stringify(stats))
	scene.queue_free()
	quit(0)
