extends Node3D

## Batch 06 additive PBR-inspired material / vegetation detail, NOT approved canon.
## Textured sandbox GLB and original 28 PBR texture maps are archived to Drive.
## This standalone Godot-native shader study deliberately has no external files.

var height_at: Callable
var soil_material: ShaderMaterial
var rock_material: ShaderMaterial
var fern_material: ShaderMaterial
var bark_material: ShaderMaterial
const PATCH_CENTER := Vector2(20.0, -3.0)
const PATCH_HALF := 9.0
const PATCH_DIV := 48

func _ready() -> void:
	soil_material = _shader_mat(Vector3(0.37, 0.31, 0.20), Vector3(0.59, 0.52, 0.34), 0.93, false)
	rock_material = _shader_mat(Vector3(0.30, 0.36, 0.32), Vector3(0.59, 0.60, 0.52), 0.85, false)
	fern_material = _shader_mat(Vector3(0.10, 0.23, 0.08), Vector3(0.38, 0.55, 0.20), 0.94, true)
	bark_material = _shader_mat(Vector3(0.24, 0.16, 0.10), Vector3(0.47, 0.32, 0.17), 0.94, false)
	_build_ground_patch()
	_build_rocks()
	_build_foliage()
	_build_root_braces()

func _height(x: float, z: float) -> float:
	return float(height_at.call(x, z)) if height_at.is_valid() else 0.0

func _shader_mat(dark: Vector3, light: Vector3, rough: float, two_sided: bool) -> ShaderMaterial:
	var sh := Shader.new()
	var cull: String = "cull_disabled" if two_sided else "cull_back"
	sh.code = """
shader_type spatial;
render_mode %s, depth_draw_opaque;
uniform vec3 dark_color = vec3(0.24,0.27,0.20);
uniform vec3 light_color = vec3(0.65,0.59,0.42);
uniform float base_roughness : hint_range(0,1) = 0.9;
varying vec3 world_pos;
float hash31(vec3 p){
	p=fract(p*0.1031);
	p+=dot(p,p.yzx+33.33);
	return fract((p.x+p.y)*p.z);
}
float value_noise(vec3 p){
	vec3 i=floor(p);vec3 f=fract(p);
	f=f*f*(3.0-2.0*f);
	return mix(
		mix(mix(hash31(i),hash31(i+vec3(1,0,0)),f.x),
			mix(hash31(i+vec3(0,1,0)),hash31(i+vec3(1,1,0)),f.x),f.y),
		mix(mix(hash31(i+vec3(0,0,1)),hash31(i+vec3(1,0,1)),f.x),
			mix(hash31(i+vec3(0,1,1)),hash31(i+vec3(1,1,1)),f.x),f.y),f.z);
}
void vertex(){
	world_pos=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
}
void fragment(){
	float n=value_noise(world_pos*1.8)*0.58+value_noise(world_pos*7.7)*0.28
		+value_noise(world_pos*24.0)*0.14;
	float grain=clamp(n,0.0,1.0);
	ALBEDO=mix(dark_color,light_color,grain);
	ROUGHNESS=clamp(base_roughness+0.09*(0.5-grain),0.18,1.0);
	METALLIC=0.0;
}
""" % cull
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("dark_color", dark)
	mat.set_shader_parameter("light_color", light)
	mat.set_shader_parameter("base_roughness", rough)
	return mat

func _build_ground_patch() -> void:
	# Adds a thin terrain-hugging detail layer, not a collision terrain replacement.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x_index in range(PATCH_DIV):
		for z_index in range(PATCH_DIV):
			var x0: float = PATCH_CENTER.x + (float(x_index) / PATCH_DIV * 2.0 - 1.0) * PATCH_HALF
			var x1: float = PATCH_CENTER.x + (float(x_index + 1) / PATCH_DIV * 2.0 - 1.0) * PATCH_HALF
			var z0: float = PATCH_CENTER.y + (float(z_index) / PATCH_DIV * 2.0 - 1.0) * PATCH_HALF
			var z1: float = PATCH_CENTER.y + (float(z_index + 1) / PATCH_DIV * 2.0 - 1.0) * PATCH_HALF
			var a := Vector3(x0, _height(x0,z0) + 0.042, z0)
			var b := Vector3(x1, _height(x1,z0) + 0.042, z0)
			var c := Vector3(x0, _height(x0,z1) + 0.042, z1)
			var d := Vector3(x1, _height(x1,z1) + 0.042, z1)
			surface.set_uv(Vector2(x0 * 0.25,z0 * 0.25))
			surface.add_vertex(a)
			surface.set_uv(Vector2(x0 * 0.25,z1 * 0.25))
			surface.add_vertex(c)
			surface.set_uv(Vector2(x1 * 0.25,z0 * 0.25))
			surface.add_vertex(b)
			surface.set_uv(Vector2(x1 * 0.25,z0 * 0.25))
			surface.add_vertex(b)
			surface.set_uv(Vector2(x0 * 0.25,z1 * 0.25))
			surface.add_vertex(c)
			surface.set_uv(Vector2(x1 * 0.25,z1 * 0.25))
			surface.add_vertex(d)
	surface.generate_normals()
	var node := MeshInstance3D.new()
	node.name = "DetailedRiverbankSurface"
	node.mesh = surface.commit()
	node.material_override = soil_material
	add_child(node)

func _build_rocks() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 606618
	var shape := SphereMesh.new()
	shape.radius = 1.0
	shape.height = 2.0
	shape.radial_segments = 9
	shape.rings = 6
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = shape
	mm.instance_count = 115
	for i in range(mm.instance_count):
		var x: float = PATCH_CENTER.x + rng.randf_range(-PATCH_HALF, PATCH_HALF)
		var z: float = PATCH_CENTER.y + rng.randf_range(-PATCH_HALF, PATCH_HALF)
		var size: float = rng.randf_range(0.17, 0.63)
		var basis := Basis().rotated(Vector3.UP, rng.randf_range(0.0,TAU))
		basis = basis.scaled(Vector3(size * 1.25, size * 0.37, size))
		mm.set_instance_transform(i,Transform3D(basis,Vector3(x,_height(x,z)+0.08,z)))
	var node := MultiMeshInstance3D.new()
	node.name = "RockMicroDetailMultiMesh"
	node.multimesh = mm
	node.material_override = rock_material
	add_child(node)

func _fern_mesh() -> Mesh:
	var surf := SurfaceTool.new()
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Five coarse pinnae-bearing fronds. This geometry deliberately avoids naming a taxon.
	for frond in range(6):
		var angle: float = TAU * float(frond) / 6.0
		var direction := Vector3(cos(angle), 0.0, sin(angle))
		var side := Vector3(-sin(angle), 0.0, cos(angle))
		for j in range(5):
			var t: float = (float(j) + 0.1) / 5.0
			var p: Vector3 = direction * (0.17 + t * 0.72) + Vector3(0.0, 0.58 - 0.22 * t, 0.0)
			var q: Vector3 = direction * (0.35 + t * 0.71) + Vector3(0.0, 0.65 - 0.45 * t, 0.0)
			var spread: float = 0.19 * sin(PI * t)
			for sign in [-1.0, 1.0]:
				var s: float = float(sign)
				surf.set_uv(Vector2(t,0.0))
				surf.add_vertex(p)
				surf.set_uv(Vector2(t,1.0))
				surf.add_vertex(q + side * spread * s)
				surf.set_uv(Vector2(t + 0.14,0.5))
				surf.add_vertex(q + direction * 0.12)
	surf.generate_normals()
	return surf.commit()

func _build_foliage() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 606619
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = _fern_mesh()
	mm.instance_count = 190
	for i in range(mm.instance_count):
		var x: float = PATCH_CENTER.x + rng.randf_range(-PATCH_HALF, PATCH_HALF)
		var z: float = PATCH_CENTER.y + rng.randf_range(-PATCH_HALF, PATCH_HALF)
		var scale_factor: float = rng.randf_range(0.43, 1.65)
		var basis := Basis().rotated(Vector3.UP,rng.randf_range(0.0,TAU))
		basis = basis.scaled(Vector3.ONE * scale_factor)
		mm.set_instance_transform(i,Transform3D(basis,Vector3(x,_height(x,z)+0.025,z)))
	var node := MultiMeshInstance3D.new()
	node.name = "PinnaeFoliageMultiMesh"
	node.multimesh = mm
	node.material_override = fern_material
	add_child(node)

func _build_root_braces() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 606620
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.055
	mesh.bottom_radius = 0.11
	mesh.height = 1.0
	mesh.radial_segments = 6
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = 38
	for i in range(mm.instance_count):
		var x: float = PATCH_CENTER.x + rng.randf_range(-PATCH_HALF, PATCH_HALF)
		var z: float = PATCH_CENTER.y + rng.randf_range(-PATCH_HALF, PATCH_HALF)
		var len: float = rng.randf_range(0.4, 1.5)
		var from := Vector3(x,_height(x,z)+0.02,z)
		var to := Vector3(x+rng.randf_range(-0.7,0.7),from.y+len,z+rng.randf_range(-0.7,0.7))
		var d: Vector3 = to-from
		var basis := Basis(Quaternion(Vector3.UP,d.normalized())).scaled(Vector3(1,d.length(),1))
		mm.set_instance_transform(i,Transform3D(basis,(from+to)*0.5))
	var node := MultiMeshInstance3D.new()
	node.name = "RootwoodDetailMultiMesh"
	node.multimesh = mm
	node.material_override = bark_material
	add_child(node)
