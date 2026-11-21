extends SceneTree

## Independent Batch 10 import gate; run AFTER --editor --import --quit.
## Checks source bytes on disk and confirms Godot loaded real 3D meshes and textures.
const M2_SOURCE := "res://assets/m2/ALC_M2_RIVER_STATION_v001.glb"
const M2_SHA256 := "4e1a48850ea6d3e2b50e2a923ac07d11f637b9629090e7bcda5f3299ab5822c3"
const M6_MANIFEST := "res://data/m10_m6_archive_manifest.json"

func _initialize() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error("ALCHUL M10 IMPORT FAIL: " + message)
	quit(1)

func _run() -> void:
	if FileAccess.get_sha256(M2_SOURCE) != M2_SHA256:
		_fail("M2 GLB SHA-256 differs from directly verified Drive original")
		return
	var json: Variant = JSON.parse_string(FileAccess.get_file_as_string(M6_MANIFEST))
	if not (json is Dictionary):
		_fail("M6 original archive manifest missing or invalid")
		return
	var members: Array = json.get("files", [])
	var verified_textures := 0
	for row in members:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var source_path: String = str(row.get("path", ""))
		if not source_path.begins_with("TEXTURES/"):
			continue
		var filename: String = source_path.get_file()
		var local_path: String = "res://assets/m6/textures/" + filename
		if not FileAccess.file_exists(local_path):
			_fail("Missing original M6 texture: " + filename)
			return
		var digest: String = FileAccess.get_sha256(local_path)
		if digest != str(row.get("sha256", "")):
			_fail("M6 texture SHA-256 mismatch: " + filename)
			return
		var original_texture: Resource = load(local_path)
		if not (original_texture is Texture2D):
			_fail("M6 image did not import as native texture: " + filename)
			return
		if (original_texture as Texture2D).get_width() != 768 or (original_texture as Texture2D).get_height() != 768:
			_fail("M6 original texture wrong dimensions: " + filename)
			return
		verified_textures += 1
	if verified_textures != 28:
		_fail("Expected 28 verified original M6 PNGs, found " + str(verified_textures))
		return

	var resource: Resource = load("res://scenes/m10_import_pilot.tscn")
	if not (resource is PackedScene):
		_fail("M10 native scene cannot be loaded")
		return
	var study: Node = (resource as PackedScene).instantiate()
	root.add_child(study)
	await process_frame
	var original: Node = study.get_node_or_null("OriginalM2RiverStation_ImportedGLB")
	if original == null:
		_fail("Original GLB was not instantiated")
		return
	var samples: Node = study.get_node_or_null("SevenUVReadyOriginalPBRSamples")
	if samples == null:
		_fail("Original PBR material test stage missing")
		return
	var state: Dictionary = study.call("validation_summary")
	if not bool(state.get("source_glb_loaded", false)) or int(state.get("station_mesh_nodes", 0)) < 19:
		_fail("M2 GLB does not provide original 19-mesh source geometry")
		return
	var mats: Dictionary = state.get("m6_material_state", {})
	if int(mats.get("original_asset_families", 0)) != 7 or int(mats.get("generated_fallback_maps", -1)) != 0:
		_fail("Original M6 768px PBR materials not loaded for all seven families")
		return
	print("ALCHUL M10 NATIVE IMPORT PASS: original M2 GLB, 19 meshes, 28 exact M6 textures, 7 native PBR families")
	study.queue_free()
	quit(0)
