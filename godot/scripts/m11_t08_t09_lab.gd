extends Node3D

## Provisional analytical overlay on T07 Skeleton3D. Foot polygons are rectangular
## assumed envelopes; dots are solved proximity targets, not force sensors.
## Separate from the playable Chapter I scene. All values dimensionless.
const SOURCE_SCENE: PackedScene = preload("res://scenes/m11_t07_joint_lab.tscn")
const RESULTS_PATH: String = "res://data/m11_t08_t09_results.json"
const CASES: Array[String] = [
    "two_feet_neutral", "two_feet_forward_reach",
    "right_foot_only", "two_feet_with_cargo_proxy"
]
var results: Dictionary = {}
var scaffold: Node3D
var current_case: String = "two_feet_neutral"
var fixture: String = "near"
var marker_roots: Dictionary = {}
var status_label: Label

func _ready() -> void:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(RESULTS_PATH))
    if not (parsed is Dictionary):
        push_error("T08-T09: missing reproducible experiment results")
        return
    results = parsed
    if str(results.get("status", "")).find("NOT_FOSSIL_DATA") < 0:
        push_error("T08-T09: research-only result status required")
        return
    scaffold = SOURCE_SCENE.instantiate()
    scaffold.name = "T07JointScaffold"
    add_child(scaffold)
    for hypothesis in ["H-A", "H-B"]:
        var body_root: Node3D = scaffold.get_node_or_null("T07_" + hypothesis) as Node3D
        if body_root == null:
            push_error("T08-T09: source skeleton " + hypothesis + " missing")
            return
        var group := Node3D.new()
        group.name = "ProxyMarkers_" + hypothesis
        group.position = body_root.position
        add_child(group)
        marker_roots[hypothesis] = group
    _build_overlay()
    show_case(current_case)
    show_fixture(fixture)

func _mat(color: Color, alpha: float = 1.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = Color(color.r, color.g, color.b, alpha)
    m.roughness = 0.9
    if alpha < 1.0:
        m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    return m

func _sphere(parent: Node3D, name: String, pos: Vector3, radius: float, mat: Material) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    mesh.radial_segments = 12
    mesh.rings = 8
    var instance := MeshInstance3D.new()
    instance.name = name
    instance.mesh = mesh
    instance.material_override = mat
    instance.position = pos
    parent.add_child(instance)

func _build_overlay() -> void:
    var layer := CanvasLayer.new()
    layer.name = "T08T09UncertaintyHud"
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(16, 136)
    panel.custom_minimum_size = Vector2(860, 0)
    layer.add_child(panel)
    var stack := VBoxContainer.new()
    panel.add_child(stack)
    var title := Label.new()
    title.text = "M11 / T08–T09  •  MODELLED SUPPORT + THREE-DIGIT REACH — NOT BIOLOGY"
    title.add_theme_font_size_override("font_size", 18)
    stack.add_child(title)
    status_label = Label.new()
    status_label.add_theme_font_size_override("font_size", 13)
    stack.add_child(status_label)
    var note := Label.new()
    note.text = "SPACE cycles stance / G switches near–far fixture. Dots are outputs from assumed normalized inputs."
    stack.add_child(note)

func _set_markers(group: Node3D, hypothesis: String) -> void:
    for node in group.get_children():
        group.remove_child(node)
        node.queue_free()
    var com_case: Dictionary = results["t08"][hypothesis]["cases"][current_case]
    var com: Array = com_case["com_xyz"]
    _sphere(group, "CenterOfMass_Proxy", Vector3(float(com[0]), float(com[1]), float(com[2])),
        0.115, _mat(Color(0.85, 0.34, 0.14)))
    var rect: Array = com_case["support_box_xmin_xmax_zmin_zmax"]
    var floor_box := BoxMesh.new()
    floor_box.size = Vector3(float(rect[1]) - float(rect[0]), 0.012,
        float(rect[3]) - float(rect[2]))
    var rectangle := MeshInstance3D.new()
    rectangle.name = "SupportFootprint_Proxy"
    rectangle.mesh = floor_box
    rectangle.material_override = _mat(Color(0.23, 0.63, 0.52), 0.42)
    rectangle.position = Vector3((float(rect[0])+float(rect[1]))/2, 0.035,
        (float(rect[2])+float(rect[3]))/2)
    group.add_child(rectangle)
    for digit in ["I","II","III"]:
        var record: Dictionary = results["t09"][hypothesis][fixture]["digits"][digit]
        var target: Array = record["target"]
        var tip: Array = record["predicted_tip"]
        _sphere(group, "FixtureTarget_" + digit,
            Vector3(float(target[0]), float(target[1]), float(target[2])), 0.066,
            _mat(Color(0.82, 0.26, 0.22)))
        _sphere(group, "ComputedTip_" + digit,
            Vector3(float(tip[0]), float(tip[1]), float(tip[2])), 0.044,
            _mat(Color(0.98, 0.82, 0.25)))

func _update() -> void:
    if scaffold == null or results.is_empty():
        return
    for hypothesis in ["H-A", "H-B"]:
        var group: Node3D = marker_roots[hypothesis]
        _set_markers(group, hypothesis)
    var rows: Array[String] = []
    for hypothesis in ["H-A", "H-B"]:
        var c: Dictionary = results["t08"][hypothesis]["cases"][current_case]
        var contacts: Dictionary = results["t09"][hypothesis][fixture]
        rows.append(hypothesis + "  margin " + str(c["signed_margin"]) +
            " (proxy only)   |   " + str(contacts["contact_count"]) + "/3 fingertip proximity")
    if status_label != null:
        status_label.text = "Case: " + current_case + "  /  Fixture: " + fixture + "\n" + "\n".join(rows)

func show_case(case_id: String) -> bool:
    if not CASES.has(case_id):
        return false
    current_case = case_id
    _update()
    return true

func show_fixture(fixture_id: String) -> bool:
    if not fixture_id in ["near", "far"]:
        return false
    fixture = fixture_id
    _update()
    return true

func validation_summary() -> Dictionary:
    return {"status": str(results.get("status", "")),
        "scenario": current_case, "fixture": fixture,
        "hypotheses": marker_roots.keys(),
        "units": str(results.get("units", ""))}

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return
    var key: InputEventKey = event as InputEventKey
    if not key.pressed or key.echo:
        return
    match key.keycode:
        KEY_SPACE:
            var idx: int = CASES.find(current_case)
            show_case(CASES[(idx + 1) % CASES.size()])
        KEY_G:
            show_fixture("far" if fixture == "near" else "near")
