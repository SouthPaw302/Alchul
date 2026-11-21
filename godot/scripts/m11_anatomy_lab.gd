extends Node3D

## M11 research-only comparative sculpture. Separate from the playable Chapter I.
## Coordinates are arbitrary illustration units; mass, joint axes and contact
## forces are not derived from fossil measurements or validated simulations.
const REGISTRY_PATH: String = "res://data/m11_anatomy_candidates.json"

var registry: Dictionary = {}
var candidate_nodes: Dictionary = {}
var selected_mode: String = "both"
var legend: Label


func _ready() -> void:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("M11 LAB: missing or invalid local anatomy candidate registry")
        return
    registry = parsed
    if str(registry.get("status", "")) != "research_only_not_canon":
        push_error("M11 LAB: candidate registry must remain noncanonical")
        return
    _build_stage()
    var candidates: Array = registry.get("hypotheses", [])
    if candidates.size() != 2:
        push_error("M11 LAB: two competing hypotheses required")
        return
    for i in range(candidates.size()):
        if typeof(candidates[i]) != TYPE_DICTIONARY:
            push_error("M11 LAB: invalid hypothesis entry")
            return
        var row: Dictionary = candidates[i]
        var body: Node3D = _create_body(row, i)
        add_child(body)
        candidate_nodes[str(row.get("id", ""))] = body
    set_view_mode("both")


func _mat(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.89
    return material


func _ellipsoid(parent: Node3D, part_name: String, center: Vector3,
        dimensions: Vector3, material: Material) -> MeshInstance3D:
    var mesh := SphereMesh.new()
    mesh.radius = 1.0
    mesh.height = 2.0
    mesh.radial_segments = 12
    mesh.rings = 8
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = mesh
    part.material_override = material
    part.position = center
    part.scale = dimensions
    parent.add_child(part)
    return part


func _link(parent: Node3D, part_name: String, start: Vector3,
        finish: Vector3, radius: float, material: Material) -> MeshInstance3D:
    var difference: Vector3 = finish - start
    var mesh := CylinderMesh.new()
    mesh.height = maxf(difference.length(), 0.01)
    mesh.bottom_radius = radius
    mesh.top_radius = radius * 0.82
    mesh.radial_segments = 9
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = mesh
    part.material_override = material
    part.position = (start + finish) * 0.5
    if difference.length_squared() > 0.0001:
        part.quaternion = Quaternion(Vector3.UP, difference.normalized())
    parent.add_child(part)
    return part


func _study_label(parent: Node3D, label_text: String, point: Vector3) -> void:
    var label := Label3D.new()
    label.text = label_text
    label.font_size = 48
    label.pixel_size = 0.007
    label.modulate = Color(0.15, 0.19, 0.19)
    label.position = point
    parent.add_child(label)


func _build_stage() -> void:
    var world_environment := WorldEnvironment.new()
    world_environment.name = "M11ComparisonLighting"
    var ambient := Environment.new()
    ambient.background_mode = Environment.BG_COLOR
    ambient.background_color = Color(0.78, 0.82, 0.79)
    ambient.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    ambient.ambient_light_color = Color(0.86, 0.86, 0.79)
    ambient.ambient_light_energy = 0.85
    world_environment.environment = ambient
    add_child(world_environment)

    var sun := DirectionalLight3D.new()
    sun.name = "StudyLighting"
    sun.rotation_degrees = Vector3(-44, -32, 0)
    sun.light_energy = 1.1
    add_child(sun)

    var camera := Camera3D.new()
    camera.name = "MatchedSideCamera"
    camera.position = Vector3(0.0, 3.55, 18.5)
    camera.fov = 59.0
    add_child(camera)
    camera.look_at(Vector3(0.0, 1.4, 0.0))
    camera.current = true

    var floor_material := _mat(Color(0.61, 0.66, 0.61))
    var datum_material := _mat(Color(0.27, 0.35, 0.34))
    var platform := BoxMesh.new()
    platform.size = Vector3(16.5, 0.10, 4.2)
    var floor := MeshInstance3D.new()
    floor.name = "CommonGroundDatum"
    floor.mesh = platform
    floor.material_override = floor_material
    floor.position = Vector3(0.0, -0.08, 0.0)
    add_child(floor)
    for x in [-4.0, 4.0]:
        _link(self, "GroundReference", Vector3(float(x) - 3.0, 0.012, 0.8),
            Vector3(float(x) + 3.0, 0.012, 0.8), 0.018, datum_material)

    var hud := CanvasLayer.new()
    hud.name = "ScientificUncertaintyHUD"
    add_child(hud)
    var panel := PanelContainer.new()
    panel.position = Vector2(16.0, 14.0)
    panel.custom_minimum_size = Vector2(760.0, 0.0)
    hud.add_child(panel)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 7)
    panel.add_child(column)
    var header := Label.new()
    header.text = "ALCHUL / M11 — PROVISIONAL COMPARATIVE ANATOMY"
    header.add_theme_font_size_override("font_size", 21)
    column.add_child(header)
    legend = Label.new()
    legend.text = ""
    legend.add_theme_font_size_override("font_size", 15)
    column.add_child(legend)
    var caution := Label.new()
    caution.text = "Illustrative units only. No mass, biological organ, measured gait, joint limit or approved canon."
    caution.add_theme_font_size_override("font_size", 13)
    column.add_child(caution)


func _create_body(spec: Dictionary, index: int) -> Node3D:
    var hypothesis_id: String = str(spec.get("id", "unknown"))
    var body := Node3D.new()
    body.name = "Candidate_" + hypothesis_id
    body.position.x = -4.0 if index == 0 else 4.0
    body.set_meta("hypothesis", hypothesis_id)
    body.set_meta("measurement_status", "dimensionless_not_validated")

    var soft_color := Color(0.58, 0.41, 0.27) if index == 0 else Color(0.37, 0.45, 0.44)
    var integument := _mat(soft_color)
    var mantle := _mat(Color(0.70, 0.61, 0.45) if index == 0 else Color(0.61, 0.67, 0.60))
    var keratin := _mat(Color(0.22, 0.26, 0.24))
    var ref_material := _mat(Color(0.67, 0.29, 0.16))

    var hip: float = float(spec.get("hip_height", 1.95))
    var torso: float = float(spec.get("torso_length", 1.45))
    var tail: float = float(spec.get("tail_length", 1.4))
    var rise: float = float(spec.get("neck_rise", 0.4))
    var reach: float = float(spec.get("forelimb_reach", 0.5))
    var spread: float = float(spec.get("stance_half_width", 0.3))

    _ellipsoid(body, "ThoracicMassCandidate", Vector3(0.24, hip + 0.10, 0.0),
        Vector3(torso * 0.65, 0.45, 0.36), integument)
    _ellipsoid(body, "PelvicMassCandidate", Vector3(-0.30, hip, 0.0),
        Vector3(0.43, 0.37, 0.35), integument)

    var shoulder := Vector3(torso * 0.60, hip + 0.23, 0.0)
    var cervical := Vector3(torso * 0.73 + 0.27, hip + 0.47 + rise, 0.0)
    _link(body, "TheropodDerivedNeckCandidate", shoulder, cervical, 0.21, integument)
    _ellipsoid(body, "NonhumanCraniumCandidate", cervical + Vector3(0.23, 0.03, 0.0),
        Vector3(0.35, 0.23, 0.25), integument)
    _ellipsoid(body, "ToothedSnoutPlaceholder", cervical + Vector3(0.53, -0.07, 0.0),
        Vector3(0.38, 0.10, 0.16), keratin)

    for i in range(4):
        var start_frac: float = float(i) / 4.0
        var end_frac: float = float(i + 1) / 4.0
        var tail_start := Vector3(-0.56 - tail * start_frac, hip - 0.03 - 0.32 * start_frac, 0.0)
        var tail_end := Vector3(-0.56 - tail * end_frac, hip - 0.03 - 0.32 * end_frac, 0.0)
        _link(body, "TailSegment_%d" % i, tail_start, tail_end,
            0.23 * (1.0 - 0.21 * float(i)), integument)
        _ellipsoid(body, "TailCover_%d" % i, (tail_start + tail_end) * 0.5 + Vector3(0, 0.11, 0),
            Vector3(0.24, 0.11, 0.18 - 0.026 * float(i)), mantle)

    for n in range(6):
        var px: float = -0.29 + float(n) * 0.25
        _ellipsoid(body, "FeatherMantle_%d" % n,
            Vector3(px, hip + 0.48, 0.0), Vector3(0.12, 0.18, 0.26),
            mantle)

    for side in [-1.0, 1.0]:
        var flank: float = float(side)
        var side_name: String = "Left" if flank < 0.0 else "Right"
        var hip_joint := Vector3(-0.2, hip - 0.06, flank * spread)
        var knee := Vector3(0.36, hip * 0.60, flank * spread)
        var ankle := Vector3(-0.09, 0.34, flank * spread)
        _link(body, "Thigh_" + side_name, hip_joint, knee, 0.17, integument)
        _link(body, "Shank_" + side_name, knee, ankle, 0.13, integument)
        _link(body, "Metatarsal_" + side_name, ankle,
            Vector3(0.24, 0.10, flank * spread), 0.09, keratin)
        for digit in range(3):
            var toe_start := Vector3(0.22, 0.10, flank * spread)
            var toe_end := Vector3(0.59, 0.07,
                flank * (spread + 0.12 * float(digit - 1)))
            _link(body, "PedalDigit_%s_%d" % [side_name, digit + 1],
                toe_start, toe_end, 0.048, keratin)

        var arm_root := Vector3(torso * 0.58, hip + 0.13, flank * 0.29)
        var elbow := arm_root + Vector3(0.18, -0.32, flank * 0.04)
        var wrist := elbow + Vector3(reach * 0.48, -0.21, flank * 0.02)
        _link(body, "UpperForelimb_" + side_name, arm_root, elbow, 0.12, integument)
        _link(body, "RestrictedForearm_" + side_name, elbow, wrist, 0.081, keratin)
        for digit in range(3):
            var offset: float = float(digit - 1)
            var finger_end := wrist + Vector3(reach * 0.48 + 0.04 * absf(offset),
                -0.06 + 0.075 * offset, flank * (0.04 + 0.12 * offset))
            _link(body, "ManualDigit_%s_%d" % [side_name, digit + 1],
                wrist, finger_end, 0.035, keratin)

    _ellipsoid(body, "IllustrativeHipDatumMarker", Vector3(-0.30, hip, 0.51),
        Vector3(0.075, 0.075, 0.075), ref_material)
    _study_label(body, hypothesis_id + " / " + str(spec.get("name", "")),
        Vector3(-tail * 0.40, 3.16, 0.0))
    _study_label(body, "Hip datum — assumed, not measured",
        Vector3(-1.60, 0.28, 0.0))
    return body


func set_view_mode(mode: String) -> bool:
    if not mode in ["both", "H-A", "H-B"]:
        return false
    selected_mode = mode
    for key in candidate_nodes.keys():
        var node: Node3D = candidate_nodes[key] as Node3D
        node.visible = mode == "both" or mode == str(key)
    if legend != null:
        legend.text = "0 Both | 1 H-A long-tail | 2 H-B compact-tail       View: " + mode
    return true


func validation_summary() -> Dictionary:
    return {
        "status": str(registry.get("status", "")),
        "candidate_count": candidate_nodes.size(),
        "ids": candidate_nodes.keys(),
        "view_mode": selected_mode,
        "unit_system": str(registry.get("units", ""))
    }


func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey:
        var key_event: InputEventKey = event as InputEventKey
        if not key_event.pressed or key_event.echo:
            return
        match key_event.keycode:
            KEY_0:
                set_view_mode("both")
            KEY_1:
                set_view_mode("H-A")
            KEY_2:
                set_view_mode("H-B")
