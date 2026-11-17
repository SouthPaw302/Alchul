extends Node3D

## Batch 05 — interconnected wetland circulation and ecological buffer.
## Additive native Godot interpretation. Separate from archived sandbox GLB.
## Experimental noncanonical design; no site edits, network or external resources.

var height_at: Callable
var silt: StandardMaterial3D
var stone: StandardMaterial3D
var root: StandardMaterial3D
var wood: StandardMaterial3D
var marsh: StandardMaterial3D
var water: StandardMaterial3D

func _ready() -> void:
	silt = _mat(Color(0.56, 0.49, 0.34))
	stone = _mat(Color(0.54, 0.58, 0.48))
	root = _mat(Color(0.31, 0.23, 0.15))
	wood = _mat(Color(0.48, 0.34, 0.20))
	marsh = _mat(Color(0.32, 0.49, 0.31))
	water = _mat(Color(0.20, 0.40, 0.43, 0.76), 0.27, true)
	_build_routes()
	_build_crossing()
	_build_buffer_vegetation()
	_build_marking_stones()

func _mat(col: Color, roughness: float = 0.92, alpha: bool = false) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = col
	mat.roughness = roughness
	if alpha:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return mat

func _height(x: float, z: float) -> float:
	return float(height_at.call(x, z)) if height_at.is_valid() else 0.0

func _river_z(x: float) -> float:
	return -13.0 + sin(x * 0.065) * 4.5

func _segment(a: Vector3, b: Vector3, radius: float, mat: Material) -> void:
	var direction: Vector3 = b - a
	if direction.length_squared() < 0.000001:
		return
	var m := CylinderMesh.new()
	m.height = direction.length()
	m.top_radius = radius * 0.82
	m.bottom_radius = radius
	m.radial_segments = 7
	var obj := MeshInstance3D.new()
	obj.mesh = m
	obj.material_override = mat
	obj.position = (a + b) * 0.5
	obj.quaternion = Quaternion(Vector3.UP, direction.normalized())
	add_child(obj)

func _surface_strip(points: Array[Vector3], width: float, mat: Material) -> void:
	# One triangle strip mesh per corridor, terrain-hugging rather than paved blocks.
	if points.size() < 2:
		return
	var surf := SurfaceTool.new()
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	var left: Array[Vector3] = []
	var right: Array[Vector3] = []
	for i in range(points.size()):
		var prev: Vector3 = points[max(0, i - 1)]
		var nxt: Vector3 = points[min(points.size() - 1, i + 1)]
		var d: Vector3 = nxt - prev
		var perpendicular := Vector3(d.z, 0.0, -d.x).normalized()
		left.append(points[i] + perpendicular * width * 0.5)
		right.append(points[i] - perpendicular * width * 0.5)
	for i in range(1, points.size()):
		surf.set_uv(Vector2(0.0, float(i - 1) / 4.0))
		surf.add_vertex(left[i - 1])
		surf.set_uv(Vector2(1.0, float(i - 1) / 4.0))
		surf.add_vertex(right[i - 1])
		surf.set_uv(Vector2(0.0, float(i) / 4.0))
		surf.add_vertex(left[i])
		surf.set_uv(Vector2(0.0, float(i) / 4.0))
		surf.add_vertex(left[i])
		surf.set_uv(Vector2(1.0, float(i - 1) / 4.0))
		surf.add_vertex(right[i - 1])
		surf.set_uv(Vector2(1.0, float(i) / 4.0))
		surf.add_vertex(right[i])
	surf.generate_normals()
	var node := MeshInstance3D.new()
	node.mesh = surf.commit()
	node.material_override = mat
	add_child(node)

func _route(points: Array[Vector2], width: float, mat: Material) -> void:
	var samples: Array[Vector3] = []
	for i in range(points.size() - 1):
		var a: Vector2 = points[i]
		var b: Vector2 = points[i + 1]
		for k in range(10):
			var t: float = float(k) / 10.0
			var p: Vector2 = a.lerp(b, t)
			samples.append(Vector3(p.x, _height(p.x, p.y) + 0.15, p.y))
	var last: Vector2 = points[points.size() - 1]
	samples.append(Vector3(last.x, _height(last.x, last.y) + 0.15, last.y))
	_surface_strip(samples, width, mat)
	# Root-vein markers are periodic; this remains a nonhuman-scale hypothesis.
	for i in range(4, samples.size(), 12):
		var p: Vector3 = samples[i]
		var before: Vector3 = samples[i - 1]
		var after: Vector3 = samples[min(samples.size() - 1, i + 1)]
		var d: Vector3 = after - before
		var edge := Vector3(d.z, 0.0, -d.x).normalized()
		_segment(p + edge * width * 0.46, p + edge * width * 0.62 + Vector3(0.0, 0.15, 0.0), 0.075, root)
		_segment(p - edge * width * 0.46, p - edge * width * 0.62 + Vector3(0.0, 0.15, 0.0), 0.075, root)

func _build_routes() -> void:
	# Site locations: M2 near (8,-3), M3 near (-16,13), M4 near (-8,-2).
	_route([Vector2(-30, 20), Vector2(-21, 15), Vector2(-16, 13),
		Vector2(-12, 9), Vector2(-5, 6), Vector2(2, 2), Vector2(8, -3)], 2.05, silt)
	_route([Vector2(-16, 13), Vector2(-16, 7), Vector2(-12, 2),
		Vector2(-8, -2)], 1.95, stone)
	_route([Vector2(-8, -2), Vector2(-3, -5), Vector2(4, -6),
		Vector2(8, -3)], 2.12, silt)
	_route([Vector2(-22, 21), Vector2(-7, 23), Vector2(8, 22),
		Vector2(17, 15), Vector2(16, 7), Vector2(8, -3)], 1.85, silt)
	_route([Vector2(-25, 7), Vector2(-24, 2), Vector2(-23, -5)], 1.56, silt)

func _build_crossing() -> void:
	# Two elevated rough-hewn root causeway pads, no locomotor clearance assumed.
	for cx in [-24.0, 11.0]:
		var samples: Array[Vector3] = []
		for i in range(41):
			var t: float = float(i) / 40.0
			var z: float = -22.0 + t * 22.0
			var x: float = cx + sin(t * PI) * 1.0
			var y: float = maxf(_height(x, z) + 0.36, -0.28 + sin(t * PI) * 0.85)
			samples.append(Vector3(x, y, z))
		_surface_strip(samples, 2.4, wood)
		for i in range(0, 40, 5):
			var p: Vector3 = samples[i]
			_segment(p + Vector3(1.12, -0.04, 0.0), p + Vector3(1.9, -0.62, 0.9), 0.13, root)
			_segment(p + Vector3(-1.12, -0.04, 0.0), p + Vector3(-1.9, -0.62, 0.9), 0.13, root)

func _build_buffer_vegetation() -> void:
	# MultiMesh avoids one draw call per reed and one tree per MeshInstance3D.
	var rng := RandomNumberGenerator.new()
	rng.seed = 50561117
	var count := 180
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	var m := CylinderMesh.new()
	m.top_radius = 0.008
	m.bottom_radius = 0.045
	m.height = 1.0
	m.radial_segments = 5
	mm.mesh = m
	mm.instance_count = count
	for i in range(count):
		var x: float = rng.randf_range(-34.0, 34.0)
		var z: float = _river_z(x) + (1.0 if i % 2 == 0 else -1.0) * rng.randf_range(3.0, 9.5)
		var y: float = _height(x, z)
		var h: float = rng.randf_range(0.40, 1.45)
		mm.set_instance_transform(i, Transform3D(Basis().scaled(Vector3(1, h, 1)),
			Vector3(x, y + h * 0.5, z)))
	var inst := MultiMeshInstance3D.new()
	inst.name = "WetlandReedMultiMesh"
	inst.multimesh = mm
	inst.material_override = marsh
	add_child(inst)

func _build_marking_stones() -> void:
	# Three small regrouping circles visually unify transitions; not literal signposts.
	for origin in [Vector2(-18, 8), Vector2(1, -2), Vector2(11, 1)]:
		for i in range(10):
			var angle: float = TAU * float(i) / 10.0
			var x: float = origin.x + cos(angle) * 2.15
			var z: float = origin.y + sin(angle) * 2.15
			var shape := SphereMesh.new()
			shape.radius = 0.29
			shape.height = 0.7
			shape.radial_segments = 7
			shape.rings = 4
			var obj := MeshInstance3D.new()
			obj.mesh = shape
			obj.position = Vector3(x, _height(x, z) + 0.15, z)
			obj.material_override = stone
			add_child(obj)
