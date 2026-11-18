extends Node3D

const SEGMENT_BATCH: Script = preload("res://scripts/segment_batch_m8.gd")
var beam_batch: Node3D

## M4: Harvest bioprocessing precinct, procedural and reversible.
## The process is symbolic: no chemistry formulae, biological recipes, or calibrated
## flow assumptions. This is NOT an archaeological or canon assertion.

var height_at: Callable
var stone: StandardMaterial3D
var wet_stone: StandardMaterial3D
var clay: StandardMaterial3D
var timber: StandardMaterial3D
var roots: StandardMaterial3D
var culture: StandardMaterial3D
var reed: StandardMaterial3D
var water: StandardMaterial3D

const CENTER_X: float = -7.8
const CENTER_Z: float = -2.1

func _ready() -> void:
	beam_batch = SEGMENT_BATCH.new()
	beam_batch.name = "M8BatchedBeams"
	add_child(beam_batch)
	stone = _material(Color(0.50, 0.49, 0.37))
	wet_stone = _material(Color(0.33, 0.36, 0.31), 0.77)
	clay = _material(Color(0.57, 0.37, 0.25))
	timber = _material(Color(0.42, 0.29, 0.19))
	roots = _material(Color(0.27, 0.20, 0.12))
	culture = _material(Color(0.58, 0.44, 0.24), 0.87)
	reed = _material(Color(0.28, 0.42, 0.23))
	water = _material(Color(0.20, 0.39, 0.39, 0.76), 0.27, true)
	_build_terraces()
	_build_vat_cluster()
	_build_curing_gallery()
	_build_seep_channels()
	_build_clay_chambers()
	_build_wetland_buffer()

	beam_batch.call("flush")

func _material(col: Color, roughness: float = 0.91, transparent: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = roughness
	if transparent:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _height(x: float, z: float) -> float:
	if height_at.is_valid():
		return float(height_at.call(x, z))
	return 0.0

func _mesh(pos: Vector3, mesh: Mesh, material: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material
	node.position = pos
	add_child(node)
	return node

func _box(pos: Vector3, size: Vector3, material: Material) -> void:
	var m := BoxMesh.new()
	m.size = size
	_mesh(pos, m, material)

func _disc(pos: Vector3, radius: float, height: float, material: Material) -> void:
	var m := CylinderMesh.new()
	m.top_radius = radius
	m.bottom_radius = radius
	m.height = height
	m.radial_segments = 14
	_mesh(pos, m, material)

func _rod(a: Vector3, b: Vector3, radius: float, mat: Material) -> void:
	beam_batch.call("add_rod",a,b,radius,mat)

func _bulb(p: Vector3, scale_vec: Vector3, material: Material) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 10
	mesh.rings = 6
	var node := _mesh(p, mesh, material)
	node.scale = scale_vec

func _ring(cx: float, y: float, cz: float, radius: float, material: Material) -> void:
	for i in range(16):
		var a: float = TAU * float(i) / 16.0
		var b: float = TAU * float(i + 1) / 16.0
		_rod(Vector3(cx + cos(a) * radius, y, cz + sin(a) * radius),
			Vector3(cx + cos(b) * radius, y, cz + sin(b) * radius), 0.17, material)

func _build_terraces() -> void:
	# Terraced envelopes and off-center access keep the Harvest inspect marker clear.
	for i in range(5):
		var x: float = CENTER_X - 5.4 + float(i) * 2.3
		var z: float = CENTER_Z - 3.6 + sin(float(i) * 0.45) * 0.4
		var base_y: float = _height(x, z)
		_box(Vector3(x, base_y + 0.08, z), Vector3(2.05, 0.17, 2.2),
			wet_stone if i % 2 == 0 else stone)
		_box(Vector3(x, base_y + 0.20, z + 0.84), Vector3(2.15, 0.18, 0.23), stone)
	for i in range(8):
		var x: float = CENTER_X - 5.5 + float(i) * 1.35
		var z: float = CENTER_Z + 2.9
		_box(Vector3(x, _height(x,z) + 0.14, z), Vector3(1.19, 0.14, 1.35), stone)

func _build_vat_cluster() -> void:
	# Vats are a non-specific symbol of environmental containment, NOT a recipe.
	for i in range(5):
		var x: float = CENTER_X - 4.4 + float(i) * 2.1
		var z: float = CENTER_Z - 2.7 + sin(float(i) * 0.52) * 0.5
		var base_y: float = _height(x, z) + 0.2
		_disc(Vector3(x, base_y + 0.11, z), 0.84, 0.25, wet_stone)
		_ring(x, base_y + 0.47, z, 0.79, clay)
		_ring(x, base_y + 0.75, z, 0.79, clay)
		_ring(x, base_y + 1.03, z, 0.76, timber)
		_disc(Vector3(x, base_y + 0.77, z), 0.70, 0.06, culture)
		for k in range(5):
			var a: float = float(k) * TAU / 5.0
			_bulb(Vector3(x + cos(a) * 0.38, base_y + 0.82, z + sin(a) * 0.38),
				Vector3(0.11, 0.065, 0.13), wet_stone)
		# Lattice lid, not an iron-age vessel.
		for k in range(5):
			var zz: float = z - 0.65 + float(k) * 0.32
			_rod(Vector3(x - 0.68, base_y + 1.11, zz),
				Vector3(x + 0.68, base_y + 1.11, zz), 0.046, roots)
		for k in range(4):
			var xx: float = x - 0.52 + float(k) * 0.34
			_rod(Vector3(xx, base_y + 1.14, z - 0.64),
				Vector3(xx, base_y + 1.14, z + 0.64), 0.035, roots)

func _build_curing_gallery() -> void:
	# Permeable, shaded timber gallery with tiered fibrous beds.
	var cz: float = CENTER_Z + 2.1
	for j in range(6):
		var x: float = CENTER_X - 5.0 + j * 1.92
		var base_y: float = _height(x, cz)
		for sign in [-1.0, 1.0]:
			var side: float = float(sign)
			_rod(Vector3(x, base_y + 0.09, cz + side * 2.0),
				Vector3(x + side * 0.29, base_y + 2.8, cz + side * 1.7),
				0.115, timber)
		var apex := Vector3(x, base_y + 3.35, cz)
		_rod(Vector3(x - 0.19, base_y + 2.75, cz - 1.75), apex, 0.075, roots)
		_rod(apex, Vector3(x + 0.19, base_y + 2.75, cz + 1.75), 0.075, roots)
		if j > 0:
			_rod(Vector3(x-1.92, base_y + 3.34, cz),
				Vector3(x, base_y + 3.34, cz), 0.085, timber)
	for shelf in range(3):
		var shelf_y: float = 0.67 + float(shelf) * 0.58
		for j in range(11):
			var xx: float = CENTER_X - 5.2 + j * 0.93
			var yy: float = _height(xx, cz + 0.35) + shelf_y
			_box(Vector3(xx, yy, cz + 0.84), Vector3(0.81, 0.07, 0.94), timber)
			_bulb(Vector3(xx, yy + 0.12, cz + 0.84),
				Vector3(0.29, 0.08, 0.22), culture)

func _build_seep_channels() -> void:
	# Separate clean-water delivery and discharge geometry: neither is simulated.
	for lane in range(3):
		var x: float = CENTER_X - 3.0 + float(lane) * 2.3
		for k in range(13):
			var z: float = CENTER_Z - 6.1 - float(k) * 0.39
			var y: float = _height(x, z) + 0.11
			_box(Vector3(x, y, z), Vector3(0.84, 0.09, 0.35), wet_stone)
			_box(Vector3(x, y + 0.052, z), Vector3(0.63, 0.025, 0.29), water)
			if k % 3 == 0:
				_bulb(Vector3(x + 0.36, y + 0.15, z),
					Vector3(0.25, 0.18, 0.22), stone)

func _build_clay_chambers() -> void:
	for i in range(2):
		var cx: float = CENTER_X - 3.6 + float(i) * 5.3
		var cz: float = CENTER_Z + 5.7
		var y: float = _height(cx, cz)
		_disc(Vector3(cx, y + 0.09, cz), 1.38, 0.22, stone)
		_bulb(Vector3(cx, y + 0.80, cz), Vector3(1.42, 1.16, 1.24), clay)
		for k in range(8):
			var a: float = TAU * float(k) / 8.0
			var x: float = cx + cos(a) * 1.23
			var z: float = cz + sin(a) * 1.12
			_rod(Vector3(x, y + 0.09, z),
				Vector3(cx + cos(a) * 0.28, y + 1.77, cz + sin(a) * 0.27),
				0.084, roots)
		# Open architectural vent cap; no prescriptive temperature control.
		_ring(cx, y + 1.91, cz, 0.32, wet_stone)

func _build_wetland_buffer() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 402617
	for i in range(48):
		var x: float = rng.randf_range(-17.0, 1.0)
		var z: float = rng.randf_range(-9.7, 5.5)
		if x > -12.7 and x < -2.0 and z > -6.0 and z < 4.5:
			continue
		var y: float = _height(x, z)
		var height: float = rng.randf_range(0.40, 0.89)
		for k in range(3):
			var a: float = float(k) * TAU / 3.0
			_rod(Vector3(x, y, z), Vector3(x + cos(a) * 0.23,
				y + height, z + sin(a) * 0.23), 0.025, reed)
