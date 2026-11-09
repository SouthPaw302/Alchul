extends Node3D

## Standalone native world study: no plugins, network requests, other repositories, or AI backends.
## All scene geometry is original, provisional, and explicitly noncanonical.

const OBSERVER_SCENE: Script = preload("res://scripts/observer.gd")
const WORLDBOOK: String = "res://data/worldbook.json"
const LAND_EXTENT: float = 60.0
const LAND_STEPS: int = 52

var worldbook: Dictionary = {}
var observer: AlchulObserver
var lens_id: String = "outside"
var focused_site: Dictionary = {}
var nearest_site: Dictionary = {}
var info_label: Label
var nearby_label: Label
var lens_label: Label
var figure: Node3D
var figure_tail: Node3D

var earth_material: StandardMaterial3D
var clay_material: StandardMaterial3D
var bark_material: StandardMaterial3D
var frond_material: StandardMaterial3D
var plumage_material: StandardMaterial3D
var keratin_material: StandardMaterial3D
var shell_material: StandardMaterial3D
var marker_material: StandardMaterial3D

func _ready() -> void:
	_load_worldbook()
	_initialize_materials()
	_build_sky_and_light()
	_build_land()
	_build_water()
	_build_vegetation()
	_build_study_sites()
	_build_study_figure()
	_build_observer()
	_build_interface()
	_set_lens("outside")

func _load_worldbook() -> void:
	var bytes: String = FileAccess.get_file_as_string(WORLDBOOK)
	var parsed: Variant = JSON.parse_string(bytes)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Worldbook is absent or invalid JSON: " + WORLDBOOK)
		get_tree().quit(1)
		return
	worldbook = parsed
	if worldbook.get("schema", "") != "alchul.native-worldbook.v1":
		push_error("Unexpected worldbook schema")
		get_tree().quit(1)

func _mat(col: Color, roughness: float = 0.9, alpha: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = roughness
	if alpha:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _initialize_materials() -> void:
	earth_material = _mat(Color(0.37, 0.40, 0.30))
	clay_material = _mat(Color(0.58, 0.47, 0.33))
	bark_material = _mat(Color(0.36, 0.29, 0.22))
	frond_material = _mat(Color(0.19, 0.34, 0.25))
	plumage_material = _mat(Color(0.53, 0.43, 0.30))
	keratin_material = _mat(Color(0.17, 0.21, 0.19))
	shell_material = _mat(Color(0.72, 0.69, 0.59))
	marker_material = _mat(Color(0.78, 0.59, 0.32))
	earth_material.vertex_color_use_as_albedo = true

func _build_sky_and_light() -> void:
	var world_env := WorldEnvironment.new()
	world_env.name = "LocalEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.48, 0.67, 0.69)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.67, 0.73, 0.65)
	env.ambient_light_energy = 0.75
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.name = "IllustrativeDaylight"
	sun.rotation_degrees = Vector3(-57.0, 28.0, 0.0)
	sun.light_energy = 1.15
	sun.shadow_enabled = true
	add_child(sun)

func river_center(x: float) -> float:
	return -13.0 + sin(x * 0.065) * 4.5

func terrain_height(x: float, z: float) -> float:
	var delta: float = z - river_center(x)
	var channel: float = 2.20 * exp(-(delta * delta) / 83.0)
	return sin(x * 0.11) * 0.21 + cos(z * 0.10) * 0.17 - channel

func _terrain_color(x: float, z: float) -> Color:
	var d: float = absf(z - river_center(x))
	if d < 5.7:
		return Color(0.45, 0.43, 0.33)
	if d < 10.0:
		return Color(0.49, 0.46, 0.31)
	return Color(0.28, 0.38, 0.28)

func _put_colored_vertex(surf: SurfaceTool, x: float, z: float) -> void:
	surf.set_color(_terrain_color(x, z))
	surf.add_vertex(Vector3(x, terrain_height(x, z), z))

func _build_land() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for zi in range(LAND_STEPS):
		var z0: float = -LAND_EXTENT + (float(zi) / LAND_STEPS) * LAND_EXTENT * 2.0
		var z1: float = -LAND_EXTENT + (float(zi + 1) / LAND_STEPS) * LAND_EXTENT * 2.0
		for xi in range(LAND_STEPS):
			var x0: float = -LAND_EXTENT + (float(xi) / LAND_STEPS) * LAND_EXTENT * 2.0
			var x1: float = -LAND_EXTENT + (float(xi + 1) / LAND_STEPS) * LAND_EXTENT * 2.0
			# CCW orientation keeps terrain normals upward.
			_put_colored_vertex(surface, x0, z0)
			_put_colored_vertex(surface, x0, z1)
			_put_colored_vertex(surface, x1, z0)
			_put_colored_vertex(surface, x1, z0)
			_put_colored_vertex(surface, x0, z1)
			_put_colored_vertex(surface, x1, z1)
	surface.generate_normals()
	var mesh := surface.commit()
	var land := MeshInstance3D.new()
	land.name = "WorkingFloodplain"
	land.mesh = mesh
	land.material_override = earth_material
	add_child(land)

func _build_water() -> void:
	var surf := SurfaceTool.new()
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(88):
		var xa: float = -LAND_EXTENT + float(i) * LAND_EXTENT * 2.0 / 88.0
		var xb: float = -LAND_EXTENT + float(i + 1) * LAND_EXTENT * 2.0 / 88.0
		var ca: float = river_center(xa)
		var cb: float = river_center(xb)
		var w: float = 3.65
		var y: float = -1.10
		for pt in [
			Vector3(xa, y, ca-w), Vector3(xa, y, ca+w), Vector3(xb, y, cb-w),
			Vector3(xb, y, cb-w), Vector3(xa, y, ca+w), Vector3(xb, y, cb+w)
		]:
			surf.add_vertex(pt)
	surf.generate_normals()
	var water := MeshInstance3D.new()
	water.name = "SchematicSurfaceWater"
	water.mesh = surf.commit()
	water.material_override = _mat(Color(0.17, 0.42, 0.45, 0.75), 0.25, true)
	add_child(water)

func _mesh(parent: Node3D, raw_mesh: Mesh, material: Material, p: Vector3) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = raw_mesh
	n.material_override = material
	n.position = p
	parent.add_child(n)
	return n

func _box(parent: Node3D, p: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	return _mesh(parent, box, material, p)

func _cylinder(parent: Node3D, p: Vector3, height: float, bottom: float, top: float, material: Material) -> MeshInstance3D:
	var cyl := CylinderMesh.new()
	cyl.height = height
	cyl.bottom_radius = bottom
	cyl.top_radius = top
	cyl.radial_segments = 9
	return _mesh(parent, cyl, material, p)

func _ellipsoid(parent: Node3D, p: Vector3, scale3: Vector3, material: Material) -> MeshInstance3D:
	var sph := SphereMesh.new()
	sph.radius = 1.0
	sph.height = 2.0
	sph.radial_segments = 12
	sph.rings = 8
	var node := _mesh(parent, sph, material, p)
	node.scale = scale3
	return node

func _segment(parent: Node3D, a: Vector3, b: Vector3, r: float, material: Material) -> MeshInstance3D:
	var axis := b - a
	var link := _cylinder(parent, (a + b) * 0.5, axis.length(), r, r * 0.75, material)
	if axis.length_squared() > 0.00001:
		link.quaternion = Quaternion(Vector3.UP, axis.normalized())
	return link

func _build_vegetation() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 73821
	var trees := Node3D.new()
	trees.name = "IllustrativeWetlandFlora"
	add_child(trees)
	for i in range(100):
		var x: float = rng.randf_range(-56.0, 56.0)
		var z: float = rng.randf_range(-55.0, 55.0)
		if absf(z - river_center(x)) < 6.5:
			continue
		if x * x + (z - 7.0) * (z - 7.0) < 360.0:
			continue
		var y := terrain_height(x, z)
		var h: float = rng.randf_range(4.2, 9.2)
		var trunk := _cylinder(trees, Vector3(x, y + h * 0.5, z), h, 0.22, 0.13, bark_material)
		trunk.rotation.y = rng.randf_range(-0.3, 0.3)
		for tier in range(3):
			var crown_h: float = h * 0.36
			_cylinder(trees,
				Vector3(x, y + h * 0.48 + float(tier) * h * 0.17, z),
				crown_h, 1.3 - float(tier) * 0.2, 0.10, frond_material)
	for j in range(45):
		var xx: float = rng.randf_range(-51.0, 51.0)
		var zz: float = rng.randf_range(-53.0, 53.0)
		if xx * xx + (zz - 7.0) * (zz - 7.0) < 250.0:
			continue
		var yy := terrain_height(xx, zz)
		var stone := _ellipsoid(trees, Vector3(xx, yy + 0.20, zz),
			Vector3(rng.randf_range(0.35, 1.25), 0.23, rng.randf_range(0.30, 0.80)), clay_material)
		stone.rotation.y = rng.randf_range(0.0, TAU)

func _build_study_sites() -> void:
	var sites: Array = worldbook.get("sites", [])
	for item in sites:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var coords: Array = item.get("position", [])
		if coords.size() != 2:
			continue
		var x: float = float(coords[0])
		var z: float = float(coords[1])
		var origin := Vector3(x, terrain_height(x, z), z)
		var marker := Node3D.new()
		marker.name = "Context_" + str(item.get("id", "unknown"))
		marker.position = origin
		add_child(marker)
		# These arranged stones are visitor markers, not a literal representation of Alchul.
		_cylinder(marker, Vector3(0, 0.13, 0), 0.26, 0.85, 0.90, clay_material)
		for k in range(3):
			var angle: float = float(k) * TAU / 3.0
			_box(marker, Vector3(cos(angle) * 0.61, 0.31, sin(angle) * 0.61),
				Vector3(0.23, 0.24, 0.45), marker_material)
		match str(item.get("id", "")):
			"bank":
				for k in range(3):
					_segment(marker, Vector3(-0.8 + k * 0.5, 0.20, -1.10),
						Vector3(-0.8 + k * 0.5, 1.55, -1.20), 0.065, bark_material)
				_box(marker, Vector3(0.0, 0.20, -1.0), Vector3(2.2, 0.21, 1.4), bark_material)
			"nursery":
				_cylinder(marker, Vector3(0.0, 0.5, -1.35), 0.75, 1.35, 1.20, shell_material)
				_box(marker, Vector3(0.0, 0.90, -1.35), Vector3(2.0, 0.18, 1.8), clay_material)
			"harvest":
				for k in range(4):
					var offset: float = -0.95 + k * 0.63
					_cylinder(marker, Vector3(offset, 0.40, -1.25), 0.56, 0.38, 0.47, bark_material)
			"witness":
				for k in range(7):
					var theta: float = float(k) * TAU / 7.0
					_ellipsoid(marker, Vector3(cos(theta) * 1.48, 0.28, sin(theta) * 1.48),
						Vector3(0.25, 0.30, 0.34), shell_material)

func _build_study_figure() -> void:
	figure = Node3D.new()
	figure.name = "WorkingBodyStudy_NotCanonical"
	figure.position = Vector3(0.7, terrain_height(0.7, 5.5), 5.5)
	add_child(figure)
	# A compact anatomical illustration: NOT a finalized grown-up species form.
	_ellipsoid(figure, Vector3(0, 1.42, 0), Vector3(0.36, 0.34, 0.73), plumage_material)
	_ellipsoid(figure, Vector3(0, 1.69, -0.58), Vector3(0.22, 0.23, 0.25), plumage_material)
	_ellipsoid(figure, Vector3(0, 1.68, -0.85), Vector3(0.15, 0.10, 0.33), keratin_material)
	for side in [-1.0, 1.0]:
		_ellipsoid(figure, Vector3(side * 0.18, 1.76, -0.68), Vector3(0.043, 0.045, 0.050), shell_material)
		_segment(figure, Vector3(side * 0.22, 1.30, 0.24),
			Vector3(side * 0.23, 0.83, 0.28), 0.14, plumage_material)
		_segment(figure, Vector3(side * 0.23, 0.83, 0.28),
			Vector3(side * 0.23, 0.15, 0.22), 0.080, keratin_material)
		for toe in [-1, 0, 1]:
			_segment(figure, Vector3(side * 0.23 + toe * 0.08, 0.12, 0.22),
				Vector3(side * 0.23 + toe * 0.085, 0.10, -0.06), 0.035, keratin_material)
		_segment(figure, Vector3(side * 0.33, 1.50, -0.25),
			Vector3(side * 0.52, 1.20, -0.51), 0.094, plumage_material)
		for digit in [-1, 0, 1]:
			_segment(figure, Vector3(side * 0.52, 1.20, -0.51),
				Vector3(side * 0.52 + digit * 0.055, 1.14, -0.69), 0.022, keratin_material)
	figure_tail = Node3D.new()
	figure_tail.name = "ProposedTail"
	figure.add_child(figure_tail)
	_segment(figure_tail, Vector3(0, 1.45, 0.55), Vector3(0, 1.38, 1.40), 0.19, plumage_material)
	_segment(figure_tail, Vector3(0, 1.38, 1.40), Vector3(0, 1.49, 2.16), 0.09, plumage_material)

func _build_observer() -> void:
	observer = OBSERVER_SCENE.new()
	observer.name = "OutsideVisitor"
	observer.terrain_height = Callable(self, "terrain_height")
	add_child(observer)

func _text(parent: VBoxContainer, words: String, font_size: int = 14) -> Label:
	var label := Label.new()
	label.text = words
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(360.0, 0)
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label

func _build_interface() -> void:
	var ui := CanvasLayer.new()
	ui.name = "InterpretationHUD"
	add_child(ui)
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 16)
	panel.custom_minimum_size = Vector2(390, 0)
	ui.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	_text(column, "ALCHUL / NATIVE STUDY", 20)
	_text(column, "One world · provisional surface-era reconstruction", 12)
	var buttons := HBoxContainer.new()
	column.add_child(buttons)
	for item in [
		{"id":"outside", "label":"1 · Outside"},
		{"id":"resident", "label":"2 · Resident"},
		{"id":"contact", "label":"3 · Reports"}
	]:
		var b := Button.new()
		b.text = item.label
		b.pressed.connect(_set_lens.bind(str(item.id)))
		buttons.add_child(b)
	lens_label = _text(column, "Outside observer", 17)
	info_label = _text(column, "Read the local storybook to begin.", 14)
	nearby_label = _text(column, "Approach a marker and press E to inspect.", 13)
	_text(column, "WASD move · right-drag look · Shift fast · E inspect", 12)
	_text(column, "No live network, external repositories or literal Alchul body.", 11)

func _set_lens(next_id: String) -> void:
	if not ["outside", "resident", "contact"].has(next_id):
		return
	lens_id = next_id
	var lens: Dictionary = worldbook.get("lenses", {}).get(lens_id, {})
	lens_label.text = str(lens.get("title", lens_id))
	_update_info()

func _update_info() -> void:
	var lens: Dictionary = worldbook.get("lenses", {}).get(lens_id, {})
	var info: String = str(lens.get("explanation", ""))
	if not focused_site.is_empty():
		info = str(focused_site.get("label", "Study place")) + ":\n" + str(
			focused_site.get("lenses", {}).get(lens_id, "No interpretation available."))
	info_label.text = info

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: _set_lens("outside")
			KEY_2: _set_lens("resident")
			KEY_3: _set_lens("contact")
			KEY_E:
				if not nearest_site.is_empty():
					focused_site = nearest_site
					_update_info()

func _process(delta: float) -> void:
	if figure_tail != null:
		figure_tail.rotation.y = sin(Time.get_ticks_msec() * 0.0007) * 0.040
	if observer == null:
		return
	var shortest: float = 6.0
	var candidate: Dictionary = {}
	for item in worldbook.get("sites", []):
		var coords: Array = item.get("position", [])
		if coords.size() != 2:
			continue
		var dist := Vector2(observer.position.x - float(coords[0]),
			observer.position.z - float(coords[1])).length()
		if dist < shortest:
			shortest = dist
			candidate = item
	nearest_site = candidate
	if not nearest_site.is_empty():
		nearby_label.text = "Nearby: " + str(nearest_site.get("label", "")) + " · press E"
	else:
		nearby_label.text = "Move toward a low stone marker, then press E to inspect."
