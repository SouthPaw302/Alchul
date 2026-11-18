extends Node3D

## Batch 07 / Real Godot PBR material pass for the Batch 06 bank geometry.
## No network and no dependency on unpublished binary assets.
## If archived M6 PNGs are staged in res://assets/m6/textures/ the
## full 768px albedo, normal and roughness files are preferred.
## Otherwise deterministic low-resolution placeholder PBR textures are built.
## This is a CANDIDATE for visual testing, not a canonical reconstruction.

const TEXTURE_FOLDER: String = "res://assets/m6/textures/"
const MATERIAL_NAMES: Array[String] = ["silt", "limestone", "rootwood", "clay", "moss", "fern", "water"]

var materials: Dictionary = {}
var using_original_assets: Dictionary = {}
var generated_texture_count: int = 0

func _ready() -> void:
	_create_materials()
	_apply_to_existing_m6()

func _create_materials() -> void:
	var palette: Dictionary = {
		"silt": [Color(0.21,0.17,0.12), Color(0.58,0.50,0.34), 0.92],
		"limestone": [Color(0.27,0.32,0.29), Color(0.64,0.65,0.56), 0.83],
		"rootwood": [Color(0.18,0.12,0.08), Color(0.53,0.36,0.20), 0.94],
		"clay": [Color(0.30,0.20,0.14), Color(0.64,0.40,0.28), 0.89],
		"moss": [Color(0.11,0.23,0.10), Color(0.37,0.52,0.26), 0.98],
		"fern": [Color(0.07,0.20,0.08), Color(0.40,0.57,0.21), 0.93],
		"water": [Color(0.07,0.22,0.24), Color(0.28,0.52,0.49), 0.21]
	}
	for family: String in MATERIAL_NAMES:
		var values: Array = palette[family]
		var mat := StandardMaterial3D.new()
		mat.resource_name = "M7_" + family + "_PBR_Candidate"
		mat.roughness = float(values[2])
		mat.metallic = 0.0
		mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		var path_prefix: String = TEXTURE_FOLDER + "ALC_M6_" + family + "_"
		var a: Texture2D = _load_local_png(path_prefix + "albedo_768.png")
		var n: Texture2D = _load_local_png(path_prefix + "normal_768.png")
		var r: Texture2D = _load_local_png(path_prefix + "roughness_768.png")
		var all_present: bool = a != null and n != null and r != null
		using_original_assets[family] = all_present
		if not all_present:
			var fallback: Dictionary = _make_fallback_maps(family, values[0], values[1], float(values[2]))
			a = fallback["albedo"]
			n = fallback["normal"]
			r = fallback["roughness"]
			generated_texture_count += 3
		mat.albedo_texture = a
		mat.normal_enabled = true
		mat.normal_texture = n
		mat.normal_scale = 0.33
		mat.roughness_texture = r
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		mat.uv1_scale = Vector3(1.0, 1.0, 1.0)
		if family == "fern":
			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		if family == "water":
			# Depth-sorting is deliberately deferred; avoid transparent sheets
			# hiding the station and visitor during this fidelity pass.
			mat.roughness = 0.24
		materials[family] = mat

func _load_local_png(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var asset: Resource = load(path)
		if asset is Texture2D:
			return asset as Texture2D
	return null

func _make_fallback_maps(family: String, dark: Color, light: Color, base_rough: float) -> Dictionary:
	# Placeholder textures are actual three-channel PBR inputs, NOT the 768px
	# originals saved to Drive. Their low detail is intentional for CI speed.
	var seed_value: int = MATERIAL_NAMES.find(family) * 7331 + 1707
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.frequency = 0.065
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 4
	const SIDE: int = 96
	var albedo := Image.create(SIDE, SIDE, false, Image.FORMAT_RGBA8)
	var normal_map := Image.create(SIDE, SIDE, false, Image.FORMAT_RGBA8)
	var roughness_map := Image.create(SIDE, SIDE, false, Image.FORMAT_RGBA8)
	for y in range(SIDE):
		for x in range(SIDE):
			var v: float = (noise.get_noise_2d(float(x), float(y)) + 1.0) * 0.5
			var finer: float = (noise.get_noise_2d(float(x) * 2.2 + 100.0, float(y) * 2.2) + 1.0) * 0.5
			var t: float = clampf(v * 0.77 + finer * 0.23, 0.0, 1.0)
			albedo.set_pixel(x, y, dark.lerp(light, t))
			var dx: float = noise.get_noise_2d(float(x) + 1.0, float(y)) - noise.get_noise_2d(float(x) - 1.0, float(y))
			var dy: float = noise.get_noise_2d(float(x), float(y) + 1.0) - noise.get_noise_2d(float(x), float(y) - 1.0)
			var n: Vector3 = Vector3(-dx * 0.40, -dy * 0.40, 1.0).normalized()
			normal_map.set_pixel(x, y, Color(n.x * 0.5 + 0.5, n.y * 0.5 + 0.5, n.z * 0.5 + 0.5))
			var r: float = clampf(base_rough + (0.5 - t) * 0.16, 0.05, 1.0)
			roughness_map.set_pixel(x, y, Color(r, r, r))
	return {
		"albedo": ImageTexture.create_from_image(albedo),
		"normal": ImageTexture.create_from_image(normal_map),
		"roughness": ImageTexture.create_from_image(roughness_map)
	}

func _apply_to_existing_m6() -> void:
	# The candidate intentionally patches only the localized M6 bank meshes.
	# Other M2–M5 modules continue using their own unchanged materials.
	var root_m6: Node = get_parent().get_node_or_null("M6RiverbankMaterials_Candidate")
	if root_m6 == null:
		push_warning("M7: M6 riverbank geometry not found")
		return
	var assignments: Dictionary = {
		"DetailedRiverbankSurface": "silt",
		"RockMicroDetailMultiMesh": "limestone",
		"PinnaeFoliageMultiMesh": "fern",
		"RootwoodDetailMultiMesh": "rootwood"
	}
	for node_path: String in assignments.keys():
		var target: Node = root_m6.get_node_or_null(node_path)
		if target is GeometryInstance3D:
			(target as GeometryInstance3D).material_override = materials[assignments[node_path]]
		else:
			push_warning("M7: missing mesh " + node_path)

func validation_summary() -> Dictionary:
	var original_count: int = 0
	for family: String in using_original_assets.keys():
		if bool(using_original_assets[family]):
			original_count += 1
	return {
		"families": materials.size(),
		"original_asset_families": original_count,
		"generated_fallback_maps": generated_texture_count
	}
