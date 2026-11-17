extends Node3D

## Batch 02 / River-reading station — Godot-native schematic geometry.
## Exploratory and reproducible: no foreign imports, no magic, no live network.
## Separate from the standalone GLB candidate archived on Google Drive.

var height_at: Callable
var stone: StandardMaterial3D
var wet_stone: StandardMaterial3D
var timber: StandardMaterial3D
var dark_root: StandardMaterial3D
var mineral: StandardMaterial3D
var water: StandardMaterial3D
var sediment: StandardMaterial3D
var reed: StandardMaterial3D

const CENTER_X := 8.1
const CENTER_Z := -2.9

func _ready() -> void:
	stone = _mat(Color(0.47, 0.47, 0.37), 0.93)
	wet_stone = _mat(Color(0.32, 0.37, 0.33), 0.71)
	timber = _mat(Color(0.48, 0.34, 0.20), 0.85)
	dark_root = _mat(Color(0.26, 0.20, 0.13), 0.92)
	mineral = _mat(Color(0.64, 0.46, 0.25), 0.84)
	sediment = _mat(Color(0.50, 0.42, 0.29), 1.0)
	reed = _mat(Color(0.33, 0.46, 0.28), 0.85)
	water = _mat(Color(0.19, 0.43, 0.44, 0.85), 0.24, true)
	_build_foundation()
	_build_five_flow_lanes()
	_build_canopy()
	_build_sensor_stones()
	_build_water_return()
	_build_shore_growth()

func _mat(color: Color, rough: float, alpha: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	if alpha:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _height(x: float, z: float) -> float:
	return float(height_at.call(x, z)) if height_at.is_valid() else 0.0

func _mesh(p: Vector3, raw: Mesh, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = raw
	n.material_override = mat
	n.position = p
	add_child(n)
	return n

func _box(p: Vector3, s: Vector3, mat: Material) -> void:
	var b := BoxMesh.new()
	b.size = s
	_mesh(p, b, mat)

func _segment(a: Vector3, b: Vector3, radius: float, mat: Material) -> void:
	var d := b - a
	if d.length_squared() < 0.000001:
		return
	var cyl := CylinderMesh.new()
	cyl.height = d.length()
	cyl.bottom_radius = radius
	cyl.top_radius = radius * 0.82
	cyl.radial_segments = 7
	var n := _mesh((a + b) * 0.5, cyl, mat)
	n.quaternion = Quaternion(Vector3.UP, d.normalized())

func _sphere(p: Vector3, scale_vec: Vector3, mat: Material) -> void:
	var s := SphereMesh.new()
	s.radius = 1.0
	s.height = 2.0
	s.radial_segments = 10
	s.rings = 6
	var n := _mesh(p, s, mat)
	n.scale = scale_vec

func _build_foundation() -> void:
	var base_y := _height(CENTER_X, CENTER_Z)
	for ring_id in range(3):
		var radius_x := 8.3 - float(ring_id) * 1.1
		var radius_z := 6.8 - float(ring_id) * 0.9
		for j in range(32):
			var a := float(j) * TAU / 32.0
			var b := float(j + 1) * TAU / 32.0
			var x1 := CENTER_X + cos(a) * radius_x
			var z1 := CENTER_Z + sin(a) * radius_z
			var x2 := CENTER_X + cos(b) * radius_x
			var z2 := CENTER_Z + sin(b) * radius_z
			_segment(Vector3(x1, base_y + ring_id * 0.19, z1),
				Vector3(x2, base_y + ring_id * 0.19, z2),
				0.24 if ring_id == 0 else 0.16, stone if ring_id == 0 else wet_stone)
	# Unlike a human paved road, the station is an uneven sequence of water-working ledges.
	for i in range(7):
		var z := CENTER_Z - 3.4 + i * 0.94
		_box(Vector3(CENTER_X, base_y + 0.26, z), Vector3(10.8, 0.21, 0.70),
			sediment if i % 2 == 0 else stone)
	for j in range(18):
		var a := float(j) * TAU / 18.0
		var x := CENTER_X + cos(a) * 7.9
		var z := CENTER_Z + sin(a) * 6.4
		_sphere(Vector3(x, base_y + 0.12, z), Vector3(0.48, 0.33, 0.38), stone)

func _build_five_flow_lanes() -> void:
	var y := _height(CENTER_X, CENTER_Z) + 0.41
	for i in range(5):
		var x := CENTER_X - 3.9 + i * 1.96
		# Five stone-lipped lanes and visible water surfaces with different sediment tests.
		for k in range(16):
			var z := CENTER_Z - 4.1 + float(k) * 0.51
			var yy := y - float(k) * 0.009
			_box(Vector3(x, yy, z), Vector3(1.52, 0.09, 0.47), water)
			for sign in [-1.0, 1.0]:
				_box(Vector3(x + sign * 0.78, yy + 0.08, z), Vector3(0.13, 0.28, 0.49), wet_stone)
			if k in [5, 11]:
				_segment(Vector3(x - 0.74, yy + 0.31, z), Vector3(x + 0.74, yy + 0.31, z), 0.082, timber)
				# Non-magical movable stone flow-resistance shims.
				for m in range(3):
					_sphere(Vector3(x - 0.49 + m * 0.49, yy + 0.25, z),
						Vector3(0.17, 0.21, 0.14), mineral)
		for j in range(6):
			var z := CENTER_Z + 1.3 + j * 0.68
			for c in range(4):
				var p := Vector3(x - 0.51 + c * 0.32, y + 0.15, z)
				_sphere(p, Vector3(0.10, 0.06, 0.08), sediment if i % 2 == 0 else mineral)

func _build_canopy() -> void:
	var base_y := _height(CENTER_X, CENTER_Z) + 0.35
	# Woven curved ribs and braced root loads: covered but still open to rain and airflow.
	for j in range(8):
		var z := CENTER_Z - 3.5 + j * 1.05
		var previous := Vector3.ZERO
		for k in range(15):
			var a := float(k) / 14.0 * PI
			var x := CENTER_X - cos(a) * 6.0
			var p := Vector3(x, base_y + 3.1 * sin(a), z)
			if k > 0:
				_segment(previous, p, 0.115, timber)
			previous = p
			if j > 0 and k in [2, 4, 6, 8, 10, 12]:
				_segment(Vector3(x, base_y + 3.1 * sin(a), z - 1.05), p, 0.055, dark_root)
		for sign in [-1.0, 1.0]:
			var x := CENTER_X + sign * 6.0
			_segment(Vector3(x + sign * 0.42, base_y - 0.35, z),
				Vector3(x - sign * 0.85, base_y + 1.95, z), 0.16, dark_root)
			_sphere(Vector3(x, base_y - 0.19, z), Vector3(0.61, 0.41, 0.47), wet_stone)
	# Four integrated longitudinal conductor beams along the roof.
	for k in [3, 5, 9, 11]:
		var a := float(k) / 14.0 * PI
		var x := CENTER_X - cos(a) * 6.0
		var y := base_y + 3.1 * sin(a)
		_segment(Vector3(x, y, CENTER_Z - 3.7), Vector3(x, y, CENTER_Z + 4.25), 0.085, timber)

func _build_sensor_stones() -> void:
	var y := _height(CENTER_X, CENTER_Z)
	for i in range(5):
		var x := CENTER_X - 4.3 + i * 2.05
		for j in range(3):
			var z := CENTER_Z + 4.45 + float(j) * 0.63
			_sphere(Vector3(x, y + 0.42, z), Vector3(0.53, 0.16, 0.28), wet_stone)
			_segment(Vector3(x, y + 0.50, z), Vector3(x, y + 1.33 + j * 0.08, z),
				0.05, dark_root)
			_sphere(Vector3(x, y + 1.39 + j * 0.08, z), Vector3(0.12, 0.13, 0.12), mineral)

func _build_water_return() -> void:
	var y := _height(CENTER_X, CENTER_Z)
	for j in range(6):
		var z := CENTER_Z - 5.8 - float(j) * 0.49
		_box(Vector3(CENTER_X, y + 0.13 - float(j) * 0.08, z),
			Vector3(6.0 - float(j) * 0.43, 0.15, 0.39), stone)
		_box(Vector3(CENTER_X, y + 0.23 - float(j) * 0.08, z),
			Vector3(5.7 - float(j) * 0.43, 0.028, 0.26), water)

func _build_shore_growth() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 720236
	for i in range(75):
		var a := rng.randf() * TAU
		var x := CENTER_X + cos(a) * rng.randf_range(7.4, 11.0)
		var z := CENTER_Z + sin(a) * rng.randf_range(6.1, 9.2)
		var y := _height(x, z)
		var h := rng.randf_range(0.35, 0.90)
		for k in range(3):
			var th := float(k) * TAU / 3.0 + a
			_segment(Vector3(x, y, z), Vector3(x + cos(th) * h * 0.38,
				y + h, z + sin(th) * h * 0.38), 0.028, reed)
