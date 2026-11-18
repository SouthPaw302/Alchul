extends Node3D

## Batch 03: protected nursery approach (candidate, not canon).
## Nonhuman spatial logic is a hypothesis. No inhabitants, eggs or exact dimensions shown.
## No external assets, no runtime network dependencies.

var height_at: Callable
var earth: StandardMaterial3D
var clay: StandardMaterial3D
var stone: StandardMaterial3D
var root: StandardMaterial3D
var wood: StandardMaterial3D
var moss: StandardMaterial3D
var water: StandardMaterial3D

func _ready() -> void:
	earth = _material(Color(0.38, 0.38, 0.27))
	clay = _material(Color(0.62, 0.47, 0.34))
	stone = _material(Color(0.52, 0.53, 0.42))
	root = _material(Color(0.27, 0.20, 0.13))
	wood = _material(Color(0.45, 0.32, 0.21))
	moss = _material(Color(0.23, 0.38, 0.22))
	water = _material(Color(0.22, 0.42, 0.45, 0.75), 0.26, true)
	_build_access()
	_build_chamber(-16.1, 13.0, 2.9)
	_build_chamber(-8.2, 14.7, 3.5)
	_build_chamber(-3.4, 9.0, 2.7)
	_build_drainage()
	_build_growth()

func _material(c: Color, rough: float = 0.90, alpha: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	if alpha:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _height(x: float, z: float) -> float:
	if height_at.is_valid():
		return float(height_at.call(x, z))
	return 0.0

func _mesh(p: Vector3, m: Mesh, mat: Material) -> MeshInstance3D:
	var o := MeshInstance3D.new()
	o.mesh = m
	o.material_override = mat
	o.position = p
	add_child(o)
	return o

func _rod(a: Vector3, b: Vector3, radius: float, mat: Material) -> void:
	var d := b - a
	if d.length_squared() <= 0.000001:
		return
	var m := CylinderMesh.new()
	m.height = d.length()
	m.top_radius = radius * 0.85
	m.bottom_radius = radius
	m.radial_segments = 7
	var o := _mesh((a + b) * 0.5, m, mat)
	o.quaternion = Quaternion(Vector3.UP, d.normalized())

func _box(p: Vector3, size: Vector3, mat: Material) -> void:
	var m := BoxMesh.new()
	m.size = size
	_mesh(p, m, mat)

func _ellipsoid(p: Vector3, scale3: Vector3, mat: Material) -> void:
	var m := SphereMesh.new()
	m.radius = 1.0
	m.height = 2.0
	m.radial_segments = 10
	m.rings = 7
	var o := _mesh(p, m, mat)
	o.scale = scale3

func _ring(cx: float, cz: float, rx: float, rz: float, y: float, mat: Material) -> void:
	for j in range(24):
		var a := TAU * float(j) / 24.0
		var b := TAU * float(j + 1) / 24.0
		_rod(Vector3(cx + cos(a) * rx, y, cz + sin(a) * rz),
			Vector3(cx + cos(b) * rx, y, cz + sin(b) * rz), 0.18, mat)

func _build_access() -> void:
	# Curved route aligned near original inspectable nursery marker (-10,7).
	# It remains open to inspection; clearance and actual locomotor scale need review.
	for i in range(25):
		var t := float(i) / 24.0
		var x := -26.0 + t * 25.0
		var z := 5.1 + t * 5.4 + sin(t * PI) * 0.7
		var y := _height(x, z) + 0.11
		_box(Vector3(x, y, z), Vector3(1.15, 0.11, 3.6), stone)
		for side in [-1.0, 1.0]:
			_rod(Vector3(x - 0.53, y + 0.09, z + side * 1.92),
				Vector3(x + 0.53, y + 0.09, z + side * 1.92), 0.10, root)
		if i % 2 == 0:
			var prev := Vector3.ZERO
			for k in range(13):
				var a := PI * float(k) / 12.0
				var p := Vector3(x, y + 0.25 + sin(a) * 2.65, z - cos(a) * 2.15)
				if k > 0:
					_rod(prev, p, 0.085, wood)
				prev = p
			if i >= 2:
				_rod(Vector3(x - 2.08, y + 2.85, z),
					Vector3(x, y + 2.85, z), 0.065, root)

func _build_chamber(cx: float, cz: float, radius: float) -> void:
	var y := _height(cx, cz) + 0.24
	# Protected raised floor, moisture-buffer ring, slotted ventilation and roof ribs.
	_ring(cx, cz, radius + 0.55, radius + 0.18, y, stone)
	_ring(cx, cz, radius, radius * 0.91, y + 0.36, clay)
	_ellipsoid(Vector3(cx, y + 0.10, cz), Vector3(radius, 0.21, radius * 0.90), earth)
	for j in range(16):
		var a := TAU * float(j) / 16.0
		if j == 0 or j == 1 or j == 15:
			continue # open side for tail/head clearance hypothesis
		var ex := cx + cos(a) * radius
		var ez := cz + sin(a) * radius * 0.91
		_rod(Vector3(ex, y + 0.18, ez), Vector3(ex, y + 1.62, ez), 0.11, root)
	for j in range(7):
		var dir := TAU * float(j) / 7.0
		var prev := Vector3.ZERO
		for k in range(13):
			var t := PI * float(k) / 12.0
			var p := Vector3(cx + cos(dir) * radius * cos(t),
				y + 1.48 + sin(t) * 2.35,
				cz + sin(dir) * radius * 0.90 * cos(t))
			if k > 0:
				_rod(prev, p, 0.080, wood)
			prev = p
	for j in range(12):
		var a := TAU * float(j) / 12.0
		var px := cx + cos(a) * (radius + 0.48)
		var pz := cz + sin(a) * (radius + 0.40)
		_ellipsoid(Vector3(px, y + 0.04, pz), Vector3(0.32, 0.15, 0.30), stone)

func _build_drainage() -> void:
	for i in range(3):
		var x := -17.0 + float(i) * 6.2
		for k in range(13):
			var z := 13.8 + float(k) * 0.45
			var y := _height(x, z) + 0.10
			_box(Vector3(x, y, z), Vector3(0.55, 0.04, 0.39), water)
			if k % 3 == 0:
				_ellipsoid(Vector3(x + 0.32, y + 0.15, z), Vector3(0.25, 0.18, 0.30), stone)

func _build_growth() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261117
	for i in range(90):
		var x := rng.randf_range(-31.0, 4.0)
		var z := rng.randf_range(2.0, 26.0)
		if absf(z - 8.0) < 2.8:
			continue
		var y := _height(x, z)
		var h := rng.randf_range(0.35, 0.95)
		_rod(Vector3(x, y, z), Vector3(x, y + h, z), 0.025, root)
		for j in range(3):
			var a := TAU * float(j) / 3.0
			_rod(Vector3(x, y + h * 0.47, z),
				Vector3(x + cos(a) * h * 0.55, y + h * 0.80,
					z + sin(a) * h * 0.55), 0.045, moss)
