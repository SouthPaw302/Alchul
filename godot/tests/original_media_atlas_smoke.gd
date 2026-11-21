extends SceneTree

## Release gate: real 3D geometry and original texture imports in the Godot
## game. Render screenshots separately; this tests the actual mesh payloads,
## including reconstructing all triangles across M1/M6 GitHub-safe splits.
const EXPECTED_TRIANGLES: Array[int] = [
	0, 232700, 93114, 63244, 92990, 77540, 141176
]

func _initialize() -> void:
	call_deferred("_run")

func _fail(error: String) -> void:
	push_error("ALCHUL ORIGINAL MEDIA FAIL: " + error)
	quit(1)

func _count_triangles(node: Node) -> int:
	var total: int = 0
	if node is MeshInstance3D:
		var mesh: Mesh = (node as MeshInstance3D).mesh
		if mesh != null:
			for surface in range(mesh.get_surface_count()):
				var indices: int = mesh.surface_get_array_index_len(surface)
				var vertices: int = mesh.surface_get_array_len(surface)
				total += (indices if indices > 0 else vertices) / 3
	for child in node.get_children():
		total += _count_triangles(child)
	return total

func _run() -> void:
	var packed: Resource = load("res://scenes/main.tscn")
	if not (packed is PackedScene):
		_fail("main scene absent")
		return
	var world: Node = (packed as PackedScene).instantiate()
	root.add_child(world)
	await process_frame
	var archive: Node = world.get_node_or_null("OriginalFirstPartyMediaAtlas")
	if archive == null:
		_fail("main game has no source atlas")
		return
	if archive.list_stages().size() != 7:
		_fail("not all source scene options declared")
		return
	for idx in range(1, 7):
		if not archive.select_stage(idx):
			_fail("unable to import original " + str(idx))
			return
		var stage: Node = archive.active
		if stage == null:
			_fail("missing scene root " + str(idx))
			return
		var triangles: int = _count_triangles(stage)
		if triangles != EXPECTED_TRIANGLES[idx]:
			_fail("triangle mismatch for " + str(idx) + ": expected " + str(EXPECTED_TRIANGLES[idx]) + ", actual " + str(triangles))
			return
		if archive.imported_meshes < 5:
			_fail("incomplete scene imported " + str(idx))
			return
		if idx == 6 and archive.m6_materials.size() != 7:
			_fail("original M6 PBR material families missing: " + str(archive.m6_materials.size()))
			return
		print("ALCHUL SOURCE GEOMETRY ", idx, "/6 PASS — ", triangles, " original triangles; ",
			archive.imported_meshes, " mesh nodes")
	if not archive.select_stage(0):
		_fail("cannot return to original procedural chapter")
		return
	if archive.active != null or not world.get_node("WorkingFloodplain").visible:
		_fail("source atlas did not restore actual playable world")
		return
	var game: Node = world.get_node_or_null("BraidedReachChapter")
	if game == null:
		_fail("source atlas broke the chapter game")
		return
	game._start_new()
	if not game.is_playing() or archive.selected != 1:
		_fail("new game should open with imported M1 river model")
		return
	game._pause()
	if game.state != "paused":
		_fail("chapter pause regression")
		return
	# Preserve the user's actual save file; no write or delete in this source test.
	print("ALCHUL ALL EXISTING ORIGINAL 3D SOURCE MODELS IN GAME PASS")
	world.queue_free()
	quit(0)
