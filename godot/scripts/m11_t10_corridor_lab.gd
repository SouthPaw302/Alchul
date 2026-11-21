extends Node2D

## Independent 2D debug renderer of the T10 *assumption-driven* mechanical
## results and T07 reference anchors. Not a physical skeleton animation,
## animal gait model, or surveyed M1–M6 settlement geometry.
const CONFIG_PATH: String = "res://data/m11_t10_force_locomotion_config.json"
const RESULT_PATH: String = "res://data/m11_t10_force_locomotion_results.json"
const T07_PATH: String = "res://data/m11_t07_skeletal_reference.json"
const SCIENCE_STATUS: String = "ASSUMPTION_DRIVEN_MATH_AND_ENGINEERING_CONSISTENCY_NOT_BIOLOGICAL_VALIDATION"

var config: Dictionary = {}
var results: Dictionary = {}
var reference: Dictionary = {}
var poses: Array[Vector3] = []
var frame_index: int = 65
var width_index: int = 2
var playing: bool = false
var elapsed: float = 0.0
var highlight: String = "both"


func _read_json(path: String) -> Dictionary:
    var decoded: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(decoded) != TYPE_DICTIONARY:
        push_error("T10: missing or malformed JSON " + path)
        return {}
    return decoded


func _ready() -> void:
    config = _read_json(CONFIG_PATH)
    results = _read_json(RESULT_PATH)
    reference = _read_json(T07_PATH)
    if str(results.get("status", "")) != SCIENCE_STATUS:
        push_error("T10: unapproved science confidence in results")
        return
    if str(config.get("status", "")) != "noncanonical_mechanical_feasibility_not_biological_validation":
        push_error("T10: source assumptions not provisional")
        return
    poses = _generate_turn_poses()
    queue_redraw()


func _generate_turn_poses() -> Array[Vector3]:
    var list: Array[Vector3] = []
    var settings: Dictionary = config.get("clearance", {})
    var r: float = float(settings.get("turn_radius_normalized", 1.1))
    var straight: int = int(settings.get("samples_straight_per_leg", 21))
    var arc: int = int(settings.get("samples_turn", 61))
    if straight < 2 or arc < 2 or r <= 0:
        return list
    for i in range(straight):
        var x: float = -2.8 + (-r + 2.8) * float(i) / float(straight - 1)
        list.append(Vector3(x, 0, 0))
    for i in range(1, arc):
        var th: float = -PI / 2.0 + PI / 2.0 * float(i) / float(arc - 1)
        list.append(Vector3(-r + r * cos(th), r + r * sin(th), th + PI / 2.0))
    for i in range(1, straight):
        var z: float = r + (2.9 - r) * float(i) / float(straight - 1)
        list.append(Vector3(0, z, PI / 2.0))
    return list


func _pose_point(u: float, lateral: float, pose: Vector3) -> Vector2:
    return Vector2(pose.x + u * cos(pose.z) - lateral * sin(pose.z),
        pose.y + u * sin(pose.z) + lateral * cos(pose.z))


func _is_inside(point: Vector2, width: float) -> bool:
    var h: float = width / 2.0
    return (point.x <= h and point.y >= -h and point.y <= h) or (point.x >= -h and point.x <= h and point.y >= -h)


func _anchors(candidate: Dictionary) -> Dictionary:
    var points: Dictionary = {}
    for bone in candidate.get("bones", []):
        var record: Dictionary = bone
        var xyz: Array = record.get("anchor", [])
        points[str(record.get("name", ""))] = Vector3(float(xyz[0]), float(xyz[1]), float(xyz[2]))
    return points


func _width_value() -> float:
    var widths: Array = config.get("clearance", {}).get("corridor_test_widths_normalized", [])
    if widths.is_empty():
        return 2.8
    return float(widths[clampi(width_index, 0, widths.size() - 1)])


func select_width_index(next_index: int) -> bool:
    var widths: Array = config.get("clearance", {}).get("corridor_test_widths_normalized", [])
    if next_index < 0 or next_index >= widths.size():
        return false
    width_index = next_index
    queue_redraw()
    return true


func set_frame(next_frame: int) -> bool:
    if next_frame < 0 or next_frame >= poses.size():
        return false
    frame_index = next_frame
    queue_redraw()
    return true


func set_highlight(next_key: String) -> bool:
    if next_key not in ["both", "H-A", "H-B"]:
        return false
    highlight = next_key
    queue_redraw()
    return true


func summary() -> Dictionary:
    var values: Dictionary = {}
    for key in ["H-A", "H-B"]:
        var rows: Array = results.get("candidates", {}).get(key, {}).get("corner_clearance", {}).get("width_results", [])
        for row in rows:
            if is_equal_approx(float(row.get("corridor_width", -1)), _width_value()):
                values[key] = bool(row.get("clearance_pass", false))
    return {"status":results.get("status", ""), "pose_count":poses.size(),
        "frame":frame_index, "width":_width_value(), "passed":values,
        "case_keys":results.get("candidates", {}).keys(),
        "force_closure_verified":false, "biological_gait_validated":false,
        "selected":highlight}


func _process(delta: float) -> void:
    if not playing or poses.is_empty():
        return
    elapsed += delta
    if elapsed >= 0.12:
        elapsed = 0.0
        frame_index = (frame_index + 1) % poses.size()
        queue_redraw()


func _text(where: Vector2, text: String, size: int = 17, color: Color = Color(0.14, 0.19, 0.20)) -> void:
    draw_string(ThemeDB.fallback_font, where, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _world(point: Vector2, center: Vector2, scale_factor: float) -> Vector2:
    return center + Vector2(point.x, -point.y) * scale_factor


func _draw_corridor(center: Vector2, scale_factor: float, width: float) -> void:
    var h: float = width / 2.0
    var pale := Color(0.87, 0.88, 0.83)
    draw_rect(Rect2(_world(Vector2(-4.4, h), center, scale_factor),
        Vector2((4.4 + h) * scale_factor, 2.0 * h * scale_factor)), pale)
    draw_rect(Rect2(_world(Vector2(-h, 4.4), center, scale_factor),
        Vector2(2.0 * h * scale_factor, (4.4 + h) * scale_factor)), pale)
    var wall := Color(0.46, 0.49, 0.47)
    for segment in [
        [Vector2(-4.4, -h), Vector2(-h, -h)],
        [Vector2(-4.4, h), Vector2(-h, h)],
        [Vector2(-h, h), Vector2(-h, 4.4)],
        [Vector2(h, h), Vector2(h, 4.4)]
    ]:
        draw_line(_world(segment[0], center, scale_factor),
            _world(segment[1], center, scale_factor), wall, 2.1, true)


func _draw_candidate(candidate: Dictionary, center: Vector2, scale_factor: float, tint: Color, width: float) -> void:
    var pts: Dictionary = _anchors(candidate)
    var pose: Vector3 = poses[clampi(frame_index, 0, poses.size() - 1)]
    var longitudinal: Array = []
    for i in range(4, 0, -1):
        longitudinal.append(float((pts["caudal_0%d" % i] as Vector3).x))
    longitudinal.append(0.0)
    for name in ["thorax", "neck_02", "skull"]:
        longitudinal.append(float((pts[name] as Vector3).x))
    for j in range(longitudinal.size() - 1):
        var a: Vector2 = _world(_pose_point(float(longitudinal[j]), 0, pose), center, scale_factor)
        var b: Vector2 = _world(_pose_point(float(longitudinal[j + 1]), 0, pose), center, scale_factor)
        draw_line(a, b, tint, 6.0, true)
    var pelvis: Vector2 = _world(Vector2(pose.x, pose.y), center, scale_factor)
    draw_circle(pelvis, 7.0, Color(0.13, 0.17, 0.19))
    for side in ["L", "R"]:
        var p: Vector3 = pts["metatarsus_" + side]
        var foot: Vector2 = _world(_pose_point(p.x, p.z, pose), center, scale_factor)
        draw_circle(foot, 5, tint)
    # Reuse the Python study's rigid-envelope assumptions solely for overlays.
    var tail: float = -(pts["caudal_04"] as Vector3).x
    var head: float = maxf((pts["skull"] as Vector3).x, (pts["mandible"] as Vector3).x)
    var margin: float = float(config["clearance"]["safety_allowance"])
    var body_w: float = float(config["clearance"]["body_half_width"])
    var tail_w: float = float(config["clearance"]["tail_half_width"])
    var head_w: float = float(config["clearance"]["head_half_width"])
    var sections: Array = [
        [-tail, tail_w], [-tail * .75, tail_w], [-tail * .5, tail_w],
        [-tail * .25, body_w * .65], [-.45, body_w], [0.0, body_w],
        [.65, body_w], [1.15, body_w * .85], [head, head_w]
    ]
    for section in sections:
        for sign in [-1.0, 1.0]:
            var p: Vector2 = _pose_point(float(section[0]), sign * (float(section[1]) + margin), pose)
            var ok: bool = _is_inside(p, width)
            draw_circle(_world(p, center, scale_factor), 3.1,
                Color(0.22, 0.50, 0.36) if ok else Color(0.69, 0.26, 0.20))


func _draw() -> void:
    if poses.is_empty() or results.is_empty():
        return
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.968, 0.96, 0.935))
    _text(Vector2(26, 42), "ALCHUL  /  T10  —  MOVING CONTACT + TURN CLEARANCE", 25)
    _text(Vector2(26, 73), "NOT CANON • Assumed rigid body/tail • No measured corridors or biological joint forces", 15, Color(0.53, 0.29, 0.23))
    var bodies: Array = reference.get("bodies", [])
    var width: float = _width_value()
    for i in range(mini(2, bodies.size())):
        var body: Dictionary = bodies[i]
        var key: String = str(body.get("id", ""))
        var center := Vector2(328 + 625 * i, 420)
        var color := Color(0.70, 0.38, 0.22) if key == "H-A" else Color(0.19, 0.43, 0.50)
        _draw_corridor(center, 68.0, width)
        _draw_candidate(body, center, 68.0, color, width)
        var clears: bool = bool(summary().get("passed", {}).get(key, false))
        var text_color := Color(0.23, 0.47, 0.32) if clears else Color(0.68, 0.27, 0.21)
        _text(Vector2(31 + 625 * i, 116), key + "  |  " + ("CLEAR" if clears else "COLLISION PROXY"), 19, text_color)
        _text(Vector2(31 + 625 * i, 610), "Rigid-tail width grid: " + str(results["candidates"][key]["corner_clearance"]["first_passing_width_IN_TEST_GRID"]), 15)
    _text(Vector2(27, 659), "Width " + str(width) + " (normalized) | Frame " + str(frame_index + 1) + " / " + str(poses.size()), 17)
    _text(Vector2(27, 693), "SPACE Play/Pause  •  LEFT/RIGHT Step  •  C Toggle 2.8/4.6  •  0/1/2 Highlight candidate", 15)


func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return
    var press: InputEventKey = event as InputEventKey
    if not press.pressed or press.echo:
        return
    match press.keycode:
        KEY_SPACE:
            playing = not playing
        KEY_LEFT:
            set_frame(maxi(0, frame_index - 1))
        KEY_RIGHT:
            set_frame(mini(poses.size() - 1, frame_index + 1))
        KEY_C:
            select_width_index(5 if width_index == 2 else 2)
        KEY_0:
            set_highlight("both")
        KEY_1:
            set_highlight("H-A")
        KEY_2:
            set_highlight("H-B")
