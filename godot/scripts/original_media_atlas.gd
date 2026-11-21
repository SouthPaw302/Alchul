extends Node3D
## First-party ALCHUL GLB atlas. Each scene is the actual authored source GLB,
## not a screenshot, stand-in, network stream, or new fictional reconstruction.
## M1/M6 were losslessly partitioned by triangles to make GitHub uploads viable.
const GROUPS: Array = [
	{"name":"Playable Chapter / M7–M8","parts":[]},
	{"name":"M1 / Original Surface River","parts":[
		"res://assets/m1/ALCHUL_M1_GEOMETRY_01.glb",
		"res://assets/m1/ALCHUL_M1_GEOMETRY_02.glb",
		"res://assets/m1/ALCHUL_M1_GEOMETRY_03.glb",
		"res://assets/m1/ALCHUL_M1_GEOMETRY_04.glb",
		"res://assets/m1/ALCHUL_M1_GEOMETRY_05.glb"]},
	{"name":"M2 / Original River Station","parts":["res://assets/m2/ALC_M2_RIVER_STATION_v001.glb"]},
	{"name":"M3 / Original Nursery","parts":["res://assets/m3/ALC_M3_NURSERY_CIRCULATION_v001.glb"]},
	{"name":"M4 / Original Harvest","parts":["res://assets/m4/ALC_M4_HARVEST_PRECINCT_v001.glb"]},
	{"name":"M5 / Original Settlement","parts":["res://assets/m5/ALC_M5_CONNECTIVE_SETTLEMENT_v001.glb"]},
	{"name":"M6 / Original Textured Riverbank","parts":[
		"res://assets/m6/ALCHUL_M6_GEOMETRY_01.glb",
		"res://assets/m6/ALCHUL_M6_GEOMETRY_02.glb",
		"res://assets/m6/ALCHUL_M6_GEOMETRY_03.glb",
		"res://assets/m6/ALCHUL_M6_GEOMETRY_04.glb"]}
]
const TEXTURE_FAMILIES: Array[String] = [
	"clay", "fern", "moss", "limestone", "rootwood", "silt", "water"
]
const SOURCE_GROUND_LAYER: int = 256
var world: Node3D
var observer: AlchulObserver
var active: Node3D
var selected: int = 0
var imported_meshes: int = 0
var source_colored_material: StandardMaterial3D
var m6_materials: Dictionary = {}

func setup(world_node: Node3D, player: AlchulObserver) -> void:
	world = world_node
	observer = player

func _ready() -> void:
	source_colored_material = StandardMaterial3D.new()
	source_colored_material.resource_name = "Preserve first-party GLB COLOR_0"
	source_colored_material.vertex_color_use_as_albedo = true
	source_colored_material.roughness = 0.86

func list_stages() -> Array:
	return GROUPS

func _m6_material(family: String) -> StandardMaterial3D:
	if m6_materials.has(family):
		return m6_materials[family]
	var texture_base: String = "res://assets/m6/textures/ALC_M6_" + family + "_"
	var mat := StandardMaterial3D.new()
	mat.resource_name = "Original M6 " + family + " Albedo/Normal/Roughness/Height"
	mat.roughness = 0.85
	for kind in ["albedo", "normal", "roughness", "height"]:
		var texture: Resource = load(texture_base + kind + "_768.png")
		if not (texture is Texture2D):
			push_error("Missing original M6 " + family + " " + kind + " PNG")
			continue
		match kind:
			"albedo":
				mat.albedo_texture = texture
			"normal":
				mat.normal_enabled = true
				mat.normal_texture = texture
			"roughness":
				mat.roughness_texture = texture
			"height":
				# Use the source height family only where real UVs are available.
				mat.heightmap_enabled = true
				mat.heightmap_texture = texture
				mat.heightmap_scale = 0.002
	m6_materials[family] = mat
	return mat

func _mesh_family(name_lower: String) -> String:
	for family in TEXTURE_FAMILIES:
		if name_lower.contains(family):
			return family
	return ""

func _color_meshes(root_node: Node, m6: bool) -> void:
	for child in root_node.get_children():
		if child is MeshInstance3D:
			var mesh_node := child as MeshInstance3D
			imported_meshes += 1
			if m6:
				var family: String = _mesh_family(str(child.name).to_lower())
				if family.is_empty() and mesh_node.mesh != null:
					family = _mesh_family(mesh_node.mesh.resource_name.to_lower())
				mesh_node.material_override = _m6_material(family) if not family.is_empty() else source_colored_material
			else:
				mesh_node.material_override = source_colored_material
			# Only natural support surfaces get physical collision. No fake
			# all-object colliders or impossible collision on water/foliage.
			var n: String = str(child.name).to_lower()
			if _is_ground(n, m6) and mesh_node.mesh != null:
				var ground := StaticBody3D.new()
				ground.name = "OriginalSourceGround"
				ground.collision_layer = SOURCE_GROUND_LAYER
				ground.collision_mask = 0
				var shape := CollisionShape3D.new()
				shape.shape = mesh_node.mesh.create_trimesh_shape()
				ground.add_child(shape)
				mesh_node.add_child(ground)
		_color_meshes(child, m6)

func _is_ground(name: String, m6: bool) -> bool:
	if m6:
		return name.contains("silt")
	for label in ["land", "loam", "soil", "earth", "bank"]:
		if name.contains(label):
			return true
	return false

func _set_original_visibility(visible_state: bool) -> void:
	for name in [
		"WorkingFloodplain", "SchematicSurfaceWater",
		"IllustrativeWetlandFlora", "M1RiverEnvironment_Candidate",
		"WorkingBodyStudy_NotCanonical"
	]:
		var node: Node3D = world.get_node_or_null(name) as Node3D
		if node != null:
			node.visible = visible_state

func select_stage(index: int) -> bool:
	if index < 0 or index >= GROUPS.size():
		return false
	if selected == index and ((index == 0 and active == null) or (active != null and is_instance_valid(active))):
		return true
	# Load before tearing down the previous valid scene.
	var incoming := Node3D.new()
	incoming.name = "OriginalArchiveStage_" + str(index)
	var files: Array = GROUPS[index]["parts"]
	for path in files:
		var resource: Resource = load(str(path))
		if not (resource is PackedScene):
			push_error("Source GLB not imported; retaining current stage: " + str(path))
			incoming.free()
			return false
		var instance: Node = (resource as PackedScene).instantiate()
		if not (instance is Node3D):
			push_error("Source GLB is not Node3D: " + str(path))
			incoming.free()
			return false
		incoming.add_child(instance)
	if active != null and is_instance_valid(active):
		remove_child(active)
		active.queue_free()
		active = null
	imported_meshes = 0
	if index != 0:
		add_child(incoming)
		active = incoming
		_color_meshes(active, index == 6)
	else:
		incoming.free()
	_set_original_visibility(index == 0)
	selected = index
	if observer != null:
		observer.terrain_height = Callable(self, "ground_height") if index != 0 else Callable(world, "terrain_height")
	print("ALCHUL ORIGINAL MEDIA ACTIVE: ", GROUPS[index]["name"], "  mesh nodes=", imported_meshes)
	return true

func ground_height(x: float, z: float) -> float:
	if world == null:
		return 0.0
	if active == null:
		return world.terrain_height(x, z)
	var ray := PhysicsRayQueryParameters3D.create(
		Vector3(x, 80.0, z), Vector3(x, -80.0, z),
		SOURCE_GROUND_LAYER
	)
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray)
	if not hit.is_empty():
		return float((hit["position"] as Vector3).y)
	# No modeled ground at this coordinate (e.g. an open river).
	return world.terrain_height(x, z)
