extends Node3D

## M10 isolated original-asset pilot; noncanonical. This is NOT the published game.
## Real source GLB: M2 River Station v001, SHA-256 pinned in data/m10_sources.json.
## Materials: seven sets of ORIGINAL M6 PNG albedo/normal/roughness (height held for future).
## The M2 GLB has COLOR_0 but no TEXCOORD_0, so it is intentionally kept vertex-colored.
## UV-ready BoxMesh samples are the controlled PBR test instead of pretending M2 has UVs.

const STATION_FILE: String = "res://assets/m2/ALC_M2_RIVER_STATION_v001.glb"
const M7_MATERIALS: Script = preload("res://scripts/materials_m7.gd")
const FAMILIES: Array[String] = ["silt", "limestone", "rootwood", "clay", "moss", "fern", "water"]

var station: Node3D
var material_pass: Node3D
var import_summary: Dictionary = {}

func _ready() -> void:
	_build_lighting()
	_build_source_station()
	_build_original_material_samples()
	_build_camera()
	_build_caption()

func _build_lighting() -> void:
	var env_node := WorldEnvironment.new()
	env_node.name = "M10LaboratoryEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.46, 0.61, 0.65)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.69, 0.72, 0.69)
	env.ambient_light_energy = 0.85
	env_node.environment = env
	add_child(env_node)
	var sun := DirectionalLight3D.new()
	sun.name = "M10DiagnosticSun"
	sun.rotation_degrees = Vector3(-52.0, 28.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

func _build_source_station() -> void:
	var source: Resource = load(STATION_FILE)
	if not (source is PackedScene):
		push_error("M10: Original M2 GLB did not import as a PackedScene")
		return
	station = (source as PackedScene).instantiate() as Node3D
	if station == null:
		push_error("M10: Original M2 GLB root is not Node3D")
		return
	station.name = "OriginalM2RiverStation_ImportedGLB"
	add_child(station)
	var mesh_count := 0
	var vertex_color_mat := StandardMaterial3D.new()
	vertex_color_mat.resource_name = "M10_Preserve_Source_GLB_COLOR_0"
	vertex_color_mat.vertex_color_use_as_albedo = true
	vertex_color_mat.roughness = 0.87
	for found in station.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := found as MeshInstance3D
		mesh_count += 1
		# Importer defaults are not evidence of faithful COLOR_0 presentation.
		# An explicit vertex-color material avoids inventing UV coordinates.
		mesh_node.material_override = vertex_color_mat
	import_summary["station_mesh_nodes"] = mesh_count
	import_summary["source_glb_loaded"] = true

func _build_original_material_samples() -> void:
	material_pass = M7_MATERIALS.new()
	material_pass.name = "OriginalM6PBRLoader"
	material_pass.set("apply_to_existing_scene", false)
	add_child(material_pass)
	var original_materials: Dictionary = material_pass.get("materials")
	var samples := Node3D.new()
	samples.name = "SevenUVReadyOriginalPBRSamples"
	add_child(samples)
	for index in range(FAMILIES.size()):
		var family: String = FAMILIES[index]
		var box := BoxMesh.new()
		box.size = Vector3(4.8, 0.35, 4.2)
		var sample := MeshInstance3D.new()
		sample.name = "OriginalM6_" + family + "_UV_Candidate"
		sample.mesh = box
		sample.material_override = original_materials.get(family)
		sample.position = Vector3(-22.8 + float(index) * 7.6, 1.1, 28.0)
		samples.add_child(sample)
		var title := Label3D.new()
		title.text = family.to_upper()
		title.font_size = 64
		title.pixel_size = 0.008
		title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		title.position = sample.position + Vector3(0, 1.25, 0)
		samples.add_child(title)
	import_summary["m6_material_state"] = material_pass.call("validation_summary")

func _build_camera() -> void:
	var cam := Camera3D.new()
	cam.name = "M10ReviewCamera"
	cam.fov = 59.0
	cam.far = 220.0
	cam.position = Vector3(38.0, 23.0, 43.0)
	add_child(cam)
	cam.look_at(Vector3(0.0, 2.0, 3.0), Vector3.UP)
	cam.make_current()

func _build_caption() -> void:
	var layer := CanvasLayer.new()
	layer.name = "M10UnapprovedStudyDisclaimer"
	add_child(layer)
	var tag := Label.new()
	tag.position = Vector2(18, 16)
	tag.text = "ALCHUL M10 — ORIGINAL GLB + ORIGINAL PBR / UNAPPROVED SCIENTIFIC STUDY"
	tag.add_theme_color_override("font_color", Color(0.97, 0.97, 0.86))
	tag.add_theme_font_size_override("font_size", 17)
	layer.add_child(tag)

func validation_summary() -> Dictionary:
	return import_summary.duplicate(true)
