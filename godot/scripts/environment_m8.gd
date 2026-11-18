extends Node3D

## Batch 08 — Release-facing riverbank quality and physical terrain candidate.
## This module is visual/game-engine engineering; NOT canon, NOT species calibrated.
## It modifies only existing native scene meshes and adds deterministic instanced foliage.
## No outside assets, HTTP calls or unrelated project dependencies.

var height_at: Callable
var water_surface: MeshInstance3D
var land_surface: MeshInstance3D
var collision_body: StaticBody3D
var shoreline: MeshInstance3D

func _ready() -> void:
	var owner_scene: Node = get_parent().get_parent()
	water_surface = owner_scene.get_node_or_null("SchematicSurfaceWater") as MeshInstance3D
	land_surface = owner_scene.get_node_or_null("WorkingFloodplain") as MeshInstance3D
	_build_terrain_collision()
	_upgrade_water_material()
	_build_riparian_edge()
	_build_understory()

func _terrain_y(x: float, z: float) -> float:
	return float(height_at.call(x, z)) if height_at.is_valid() else 0.0

func _river_z(x: float) -> float:
	return -13.0 + sin(x * 0.065) * 4.5

func _build_terrain_collision() -> void:
	# Use identical vertex locations to the already-visible riverplain mesh.
	# Static concave collision supports editor ray picking. This is NOT full
	# species-accurate character-body navigation or bridge collision.
	if land_surface == null or land_surface.mesh == null:
		push_error("M8: terrain mesh missing for collision")
		return
	var faces: PackedVector3Array = land_surface.mesh.get_faces()
	if faces.size() < 3:
		push_error("M8: terrain mesh has no faces")
		return
	var shape := ConcavePolygonShape3D.new()
	shape.data = faces
	collision_body = StaticBody3D.new()
	collision_body.name = "WorkingFloodplain_CollisionCandidate"
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collision_body.add_child(collider)
	add_child(collision_body)

func _upgrade_water_material() -> void:
	if water_surface == null:
		push_error("M8: water mesh unavailable")
		return
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;
varying vec3 pos_world;
void vertex() {
	pos_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}
void fragment() {
	float w1 = sin(pos_world.x * 0.74 + TIME * 0.57 + pos_world.z * 0.34);
	float w2 = sin(pos_world.z * 1.43 - pos_world.x * 0.42 + TIME * 0.86);
	float w3 = sin((pos_world.x + pos_world.z) * 2.4 + TIME * 1.3);
	float ripple = w1 * 0.48 + w2 * 0.37 + w3 * 0.15;
	float glint = pow(max(0.0, ripple * 0.5 + 0.5), 5.0) * 0.18;
	float riversilt = sin(pos_world.x * 0.19 + pos_world.z * 0.12) * 0.09;
	vec3 deep = vec3(0.085, 0.24, 0.23);
	vec3 pale = vec3(0.20, 0.40, 0.36);
	ALBEDO = mix(deep, pale, clamp(0.48 + ripple * 0.25 + riversilt, 0.0, 1.0))
		+ vec3(0.39, 0.36, 0.23) * glint;
	ROUGHNESS = 0.23 + 0.04 * w2;
	METALLIC = 0.0;
}
"""
	var mat := ShaderMaterial.new()
	mat.resource_name = "M8AnimatedRiver_Candidate"
	mat.shader = shader
	water_surface.material_override = mat

func _build_riparian_edge() -> void:
	# Terrain-following banks; separate material from transparent water.
	# The strips avoid the rigid artifact of a perfectly rectangular water slab.
	var mesh_builder := SurfaceTool.new()
	mesh_builder.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side_index in range(2):
		var side: float = -1.0 if side_index == 0 else 1.0
		for i in range(128):
			var xa: float = -57.0 + float(i) * 114.0 / 128.0
			var xb: float = -57.0 + float(i+1) * 114.0 / 128.0
			var za: float = _river_z(xa) + side * 3.8
			var zb: float = _river_z(xb) + side * 3.8
			var za_far: float = za + side * 1.35
			var zb_far: float = zb + side * 1.35
			var a := Vector3(xa, _terrain_y(xa,za) + 0.055, za)
			var b := Vector3(xb, _terrain_y(xb,zb) + 0.055, zb)
			var c := Vector3(xa, _terrain_y(xa,za_far) + 0.055, za_far)
			var d := Vector3(xb, _terrain_y(xb,zb_far) + 0.055, zb_far)
			# Double-sided in material; coverage is independent of strip handedness.
			mesh_builder.set_uv(Vector2(xa * 0.08, 0.0))
			mesh_builder.add_vertex(a)
			mesh_builder.set_uv(Vector2(xb * 0.08, 0.0))
			mesh_builder.add_vertex(b)
			mesh_builder.set_uv(Vector2(xa * 0.08, 1.0))
			mesh_builder.add_vertex(c)
			mesh_builder.set_uv(Vector2(xb * 0.08, 0.0))
			mesh_builder.add_vertex(b)
			mesh_builder.set_uv(Vector2(xb * 0.08, 1.0))
			mesh_builder.add_vertex(d)
			mesh_builder.set_uv(Vector2(xa * 0.08, 1.0))
			mesh_builder.add_vertex(c)
	mesh_builder.generate_normals()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.31,0.39,0.25)
	mat.roughness = 0.95
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shoreline = MeshInstance3D.new()
	shoreline.name = "RiparianGradientStrips"
	shoreline.mesh = mesh_builder.commit()
	shoreline.material_override = mat
	add_child(shoreline)

func _build_understory() -> void:
	# 220 instanced plants / two draw-call groups instead of 220 nodes.
	var rng := RandomNumberGenerator.new()
	rng.seed = 8081826
	var stem_mesh := CylinderMesh.new()
	stem_mesh.bottom_radius = 0.045
	stem_mesh.top_radius = 0.01
	stem_mesh.height = 1.0
	stem_mesh.radial_segments = 5
	var mm := MultiMesh.new()
	mm.mesh = stem_mesh
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = 220
	for i in range(mm.instance_count):
		var x: float = rng.randf_range(-48.0, 48.0)
		var z: float = _river_z(x) + (1.0 if i % 2 == 0 else -1.0) * rng.randf_range(5.0, 11.0)
		var y: float = _terrain_y(x,z)
		var h: float = rng.randf_range(0.38, 1.28)
		var rotation: float = rng.randf_range(0.0, TAU)
		var basis := Basis().rotated(Vector3.UP, rotation).scaled(Vector3(1.0,h,1.0))
		mm.set_instance_transform(i, Transform3D(basis, Vector3(x,y + 0.5 * h,z)))
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.29,0.43,0.25)
	mat.roughness = 0.93
	var foliage := MultiMeshInstance3D.new()
	foliage.name = "RiparianUnderstoryMultiMesh"
	foliage.multimesh = mm
	foliage.material_override = mat
	add_child(foliage)

func diagnostics() -> Dictionary:
	return {
		"collider_ready": collision_body != null and collision_body.get_child_count() == 1,
		"animated_water": water_surface != null and water_surface.material_override is ShaderMaterial,
		"riparian_mesh": shoreline != null,
		"instanced_understory": get_node_or_null("RiparianUnderstoryMultiMesh") != null,
		"baseline_terrain_preserved": land_surface != null
	}
