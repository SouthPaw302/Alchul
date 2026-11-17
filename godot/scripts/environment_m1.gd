extends Node3D

const M2_STATION: Script = preload("res://scripts/station_m2.gd")
const M3_NURSERY: Script = preload("res://scripts/nursery_m3.gd")
const M4_HARVEST: Script = preload("res://scripts/harvest_m4.gd")

## Alchul M1 additive river-settlement visual study.
## Primitive geometry is intentionally noncanonical. No external files/network.
## Does not replace the existing visitor, markers, lenses, or terrain.

var height_at: Callable
var branch_mat: StandardMaterial3D
var timber_mat: StandardMaterial3D
var stone_mat: StandardMaterial3D
var wet_stone_mat: StandardMaterial3D
var moss_mat: StandardMaterial3D
var reed_mat: StandardMaterial3D
var water_mat: StandardMaterial3D

func _ready() -> void:
	branch_mat = _mat(Color(0.30, 0.21, 0.14))
	timber_mat = _mat(Color(0.46, 0.34, 0.22))
	stone_mat = _mat(Color(0.43, 0.46, 0.36))
	wet_stone_mat = _mat(Color(0.49, 0.43, 0.30))
	moss_mat = _mat(Color(0.22, 0.39, 0.23))
	reed_mat = _mat(Color(0.39, 0.48, 0.25))
	water_mat = _mat(Color(0.18, 0.42, 0.42, 0.88), 0.22, true)
	_build_m2_station()
	_build_m3_nursery()
	_build_m4_harvest()
	_build_bank_reinforcement()
	_build_wetland_detail()

func _mat(color: Color, roughness: float = 0.91, alpha: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	if alpha:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _height(x: float, z: float) -> float:
	if height_at.is_valid():
		return float(height_at.call(x, z))
	return 0.0

func _mesh(where: Vector3, shape: Mesh, mat: Material) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.position = where
	n.mesh = shape
	n.material_override = mat
	add_child(n)
	return n

func _beam(where: Vector3, size: Vector3, mat: Material) -> void:
	var b := BoxMesh.new()
	b.size = size
	_mesh(where, b, mat)

func _rod(a: Vector3, b: Vector3, radius: float, mat: Material) -> void:
	var delta := b - a
	if delta.length_squared() < 0.00001:
		return
	var c := CylinderMesh.new()
	c.height = delta.length()
	c.top_radius = radius * 0.9
	c.bottom_radius = radius
	c.radial_segments = 7
	var node := _mesh((a + b) / 2.0, c, mat)
	node.quaternion = Quaternion(Vector3.UP, delta.normalized())

func _disc(p: Vector3, radius: float, thickness: float, mat: Material) -> void:
	var c := CylinderMesh.new()
	c.height = thickness
	c.top_radius = radius
	c.bottom_radius = radius
	c.radial_segments = 18
	_mesh(p, c, mat)

func _bulb(p: Vector3, size: Vector3, mat: Material) -> void:
	var s := SphereMesh.new()
	s.radius = 1.0
	s.height = 2.0
	s.radial_segments = 10
	s.rings = 6
	var n := _mesh(p, s, mat)
	n.scale = size

func _arched_gallery(cx: float, cz: float, length: int, width: float, rise: float) -> void:
	# Structural ribs and longitudinal braces. Roof remains permeable, not a human building.
	var x0 := cx - float(length - 1) * 0.93
	var y0 := _height(cx, cz) + 0.25
	for i in range(length):
		var x := x0 + float(i) * 1.86
		var previous := Vector3.ZERO
		for j in range(11):
			var t := float(j) / 10.0
			var p := Vector3(x, y0 + rise * sin(t * PI), cz + width * (t - 0.5))
			if j > 0:
				_rod(previous, p, 0.12, branch_mat)
			previous = p
		if i > 0:
			for t in [0.18, 0.34, 0.50, 0.66, 0.82]:
				_rod(
					Vector3(x - 1.86, y0 + rise * sin(t * PI), cz + width * (t - 0.5)),
					Vector3(x, y0 + rise * sin(t * PI), cz + width * (t - 0.5)),
					0.075, timber_mat
				)

func _build_m2_station() -> void:
	var candidate: Node3D = M2_STATION.new()
	candidate.name = "M2RiverReadingStation_Candidate"
	candidate.set("height_at", height_at)
	add_child(candidate)

func _build_river_reading_station() -> void:
	# Near the existing bank marker at (8,0), leave marker and inspection free.
	var cx := 7.8
	var cz := -3.7
	var deck_y := _height(cx, cz) + 0.44
	for j in range(7):
		var z := cz - 2.7 + j * 0.85
		_beam(Vector3(cx + 1.7, deck_y, z), Vector3(6.8, 0.19, 0.70), timber_mat)
		for x in [cx - 1.3, cx + 4.9]:
			_rod(Vector3(x, deck_y - 0.1, z), Vector3(x + 0.4, _height(x + 0.4, z + 1.0), z + 1.0), 0.12, branch_mat)
	for i in range(3):
		var x := cx - 0.70 + i * 2.3
		var z := cz + 0.5
		_disc(Vector3(x, deck_y + 0.16, z), 0.89, 0.24, wet_stone_mat)
		_disc(Vector3(x, deck_y + 0.29, z), 0.66, 0.035, water_mat)
		# Stone shim markers and channels are movable-looking modular elements.
		for j in range(5):
			var angle := float(j) * TAU / 5.0
			_bulb(Vector3(x + cos(angle) * 0.78, deck_y + 0.35, z + sin(angle) * 0.78), Vector3(0.13, 0.22, 0.13), stone_mat)
	for i in range(3):
		_beam(Vector3(cx + 1.5, deck_y + 0.26, cz - 2.15 + float(i) * 0.43), Vector3(5.9, 0.07, 0.12), wet_stone_mat)
	_arched_gallery(10.0, -2.6, 4, 4.8, 2.5)

func _build_m3_nursery() -> void:
	var candidate: Node3D = M3_NURSERY.new()
	candidate.name = "M3ProtectedNursery_Candidate"
	candidate.set("height_at", height_at)
	add_child(candidate)

func _build_covered_nursery_route() -> void:
	# A broad, smooth route with protected access. No claims about egg anatomy or incubation.
	var x := -10.0
	var z := 8.3
	var y := _height(x, z) + 0.28
	for j in range(15):
		var xx := -21.0 + j * 1.25
		var zz := z + sin(float(j) * 0.18) * 1.1
		_beam(Vector3(xx, _height(xx, zz) + 0.12, zz), Vector3(1.20, 0.12, 3.0), stone_mat)
	_arched_gallery(-12.0, 8.5, 7, 4.9, 3.1)
	for k in range(3):
		var xx := -18.0 + k * 4.8
		var zz := 12.4
		var yy := _height(xx, zz) + 0.27
		_disc(Vector3(xx, yy, zz), 2.15, 0.43, wet_stone_mat)
		_disc(Vector3(xx, yy + 0.23, zz), 1.55, 0.045, moss_mat)
		for j in range(6):
			var angle := j * TAU / 6.0
			_rod(Vector3(xx + cos(angle) * 1.85, yy, zz + sin(angle) * 1.85),
				Vector3(xx + cos(angle) * 1.68, yy + 1.1, zz + sin(angle) * 1.68), 0.10, branch_mat)

func _build_m4_harvest() -> void:
	var candidate: Node3D = M4_HARVEST.new()
	candidate.name = "M4HarvestPrecinct_Candidate"
	candidate.set("height_at", height_at)
	add_child(candidate)

func _build_harvest_precinct() -> void:
	var cx := -5.0
	var cz := -1.0
	var y := _height(cx, cz) + 0.2
	for i in range(4):
		var x := cx - 3.4 + float(i) * 2.0
		_disc(Vector3(x, y + 0.23, cz - 3.0), 0.71, 0.55, wet_stone_mat)
		_disc(Vector3(x, y + 0.52, cz - 3.0), 0.54, 0.035, moss_mat)
		for j in range(4):
			var xx := x + cos(float(j) * TAU / 4.0) * 0.55
			var zz := cz - 3.0 + sin(float(j) * TAU / 4.0) * 0.55
			_rod(Vector3(xx, y + 0.55, zz), Vector3(xx, y + 0.91, zz), 0.045, reed_mat)
	_arched_gallery(-5.0, -2.4, 4, 4.7, 2.5)
	for i in range(4):
		_beam(Vector3(cx - 3.8 + i * 2.4, y + 0.12, cz + 2.1), Vector3(1.75, 0.15, 1.0), timber_mat)
		# Organic processing/rack support beams, not a human-style factory.
		_rod(Vector3(cx - 3.8 + i * 2.4, y + .20, cz + 1.7),
			Vector3(cx - 3.8 + i * 2.4, y + 1.18, cz + 1.7), .06, branch_mat)

func _build_bank_reinforcement() -> void:
	for i in range(16):
		var x := -24.0 + float(i) * 3.05
		var z := -7.5 + sin(x * 0.065) * 4.5
		var y := _height(x, z)
		_rod(Vector3(x, y, z), Vector3(x + 1.4, y + 0.8, z + 2.0), 0.15, branch_mat)
		_rod(Vector3(x + 1.4, y + 0.8, z + 2.0), Vector3(x + 2.3, _height(x + 2.3, z + 3.2), z + 3.2), 0.11, timber_mat)
		_bulb(Vector3(x - .3, y + .05, z), Vector3(.61, .22, .47), stone_mat)

func _build_wetland_detail() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 294201
	for i in range(105):
		var x := rng.randf_range(-27.0, 29.0)
		var z := rng.randf_range(-7.0, 19.0)
		if absf(x - 8.0) < 5.0 and absf(z + 2.0) < 6.0:
			continue
		if absf(x + 10.0) < 10.0 and z > 5.0 and z < 14.0:
			continue
		var y := _height(x, z)
		for j in range(3):
			var theta := float(j) * TAU / 3.0 + rng.randf_range(-.2, .2)
			var height := rng.randf_range(.55, 1.1)
			_rod(Vector3(x, y + .03, z),
				Vector3(x + cos(theta) * .40, y + height, z + sin(theta) * .40), .025, reed_mat)
			_bulb(Vector3(x + cos(theta) * .29, y + height * .72, z + sin(theta) * .29),
				Vector3(.16, .33, .13), moss_mat)
