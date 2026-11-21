extends Node3D

## T07 standalone, noncanonical Skeleton3D study. Child bone transforms and
## editable pose controls are working Godot objects, but joint numbers are
## illustrative safety gates, NOT measured physiology or biomechanics.
const FILE: String = "res://data/m11_t07_skeletal_reference.json"

var registry: Dictionary = {}
var rigs: Dictionary = {}
var visual_nodes: Dictionary = {}
var last_pose: Dictionary = {}
var selected: String = "both"
var info: Label

func _ready() -> void:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(FILE))
    if not (parsed is Dictionary):
        push_error("T07: missing reference registry")
        return
    registry = parsed
    if str(registry.get("status", "")) != "engineering_hypothesis_not_canon":
        push_error("T07: unapproved skeleton specification")
        return
    _environment()
    var alternatives: Array = registry.get("bodies", [])
    if alternatives.size() != 2:
        push_error("T07: require two independent bone sets")
        return
    for i in range(alternatives.size()):
        var spec: Dictionary = alternatives[i]
        _create_skeleton(spec, i)
    set_display_mode("both")

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.83
    return material

func _environment() -> void:
    var env := WorldEnvironment.new()
    env.name = "ResearchAmbient"
    var settings := Environment.new()
    settings.background_mode = Environment.BG_COLOR
    settings.background_color = Color(0.81, 0.84, 0.83)
    settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    settings.ambient_light_color = Color(0.91, 0.91, 0.88)
    env.environment = settings
    add_child(env)
    var light := DirectionalLight3D.new()
    light.name = "AnatomyKey"
    light.rotation_degrees = Vector3(-45, -32, 0)
    light.light_energy = 1.3
    add_child(light)
    var camera := Camera3D.new()
    camera.name = "MatchedT07Camera"
    camera.position = Vector3(0, 3.65, 17.5)
    camera.fov = 62.0
    camera.current = true
    add_child(camera)
    camera.look_at(Vector3(0.0, 1.6, 0.0))
    var stage := MeshInstance3D.new()
    stage.name = "SharedFloorReference"
    var floor_mesh := BoxMesh.new()
    floor_mesh.size = Vector3(17.0, 0.07, 4.8)
    stage.mesh = floor_mesh
    stage.material_override = _material(Color(0.59, 0.62, 0.57))
    stage.position.y = -0.04
    add_child(stage)
    var layer := CanvasLayer.new()
    layer.name = "SkeletalStudyHud"
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(15, 12)
    panel.custom_minimum_size = Vector2(950, 0)
    layer.add_child(panel)
    var list := VBoxContainer.new()
    panel.add_child(list)
    var head := Label.new()
    head.text = "ALCHUL / T07 — SKELETAL JOINT REFERENCE • NOT CANON"
    head.add_theme_font_size_override("font_size", 21)
    list.add_child(head)
    info = Label.new()
    info.add_theme_font_size_override("font_size", 14)
    list.add_child(info)
    var caution := Label.new()
    caution.text = "43 articulated reference bones / candidate. Units and joint angles are NOT fossil measurements."
    caution.add_theme_font_size_override("font_size", 13)
    list.add_child(caution)

func _create_skeleton(spec: Dictionary, order: int) -> void:
    var key: String = str(spec.get("id", ""))
    var group := Node3D.new()
    group.name = "T07_" + key
    group.position.x = -3.7 if order == 0 else 3.7
    add_child(group)
    var skeleton := Skeleton3D.new()
    skeleton.name = "ResearchSkeleton3D"
    group.add_child(skeleton)
    var display := Node3D.new()
    display.name = "JointAndBoneVisuals"
    group.add_child(display)
    var graph: Array = spec.get("bones", [])
    var anchors: Dictionary = {}
    var indices: Dictionary = {}
    for record in graph:
        if not (record is Dictionary):
            push_error("T07: unexpected bone record")
            return
        var name: String = str(record.get("name", ""))
        var point: Array = record.get("anchor", [])
        if point.size() != 3:
            push_error("T07: missing normalized anchor " + name)
            return
        var global_anchor := Vector3(float(point[0]), float(point[1]), float(point[2]))
        var parent_name: String = str(record.get("parent", ""))
        skeleton.add_bone(name)
        var index: int = skeleton.get_bone_count() - 1
        var local_anchor: Vector3 = global_anchor
        if not parent_name.is_empty():
            if not indices.has(parent_name):
                push_error("T07: parent order incorrect for " + name)
                return
            skeleton.set_bone_parent(index, int(indices[parent_name]))
            local_anchor = global_anchor - (anchors[parent_name] as Vector3)
        skeleton.set_bone_rest(index, Transform3D(Basis.IDENTITY, local_anchor))
        anchors[name] = global_anchor
        indices[name] = index
    rigs[key] = {"root":group, "skeleton":skeleton, "indices":indices}
    visual_nodes[key] = {"segments":{}, "dots":{}}
    var bone_mesh := CylinderMesh.new()
    bone_mesh.height = 1.0
    bone_mesh.top_radius = 0.035
    bone_mesh.bottom_radius = 0.047
    bone_mesh.radial_segments = 10
    var dot_mesh := SphereMesh.new()
    dot_mesh.radius = 0.071
    dot_mesh.height = 0.142
    dot_mesh.radial_segments = 10
    dot_mesh.rings = 7
    var skeleton_mat := _material(Color(0.68, 0.40, 0.22) if order == 0 else Color(0.28, 0.46, 0.49))
    var joint_mat := _material(Color(0.17, 0.21, 0.23))
    for record in graph:
        var name: String = str(record["name"])
        var joint := MeshInstance3D.new()
        joint.name = "Joint_" + name
        joint.mesh = dot_mesh
        joint.material_override = joint_mat
        display.add_child(joint)
        (visual_nodes[key]["dots"] as Dictionary)[name] = joint
        if record.get("parent") != null:
            var link := MeshInstance3D.new()
            link.name = "Bone_" + name
            link.mesh = bone_mesh
            link.material_override = skeleton_mat
            display.add_child(link)
            (visual_nodes[key]["segments"] as Dictionary)[name] = link
    var title := Label3D.new()
    title.name = "HypothesisLabel"
    title.text = str(spec.get("label", key)) + " | unmeasured"
    title.font_size = 52
    title.pixel_size = 0.008
    title.modulate = Color(0.12, 0.19, 0.19)
    title.position = Vector3(-1.8, 3.65, 0.0)
    group.add_child(title)
    _update_visuals(key)

func _update_visuals(key: String) -> void:
    var entry: Dictionary = rigs[key]
    var skeleton: Skeleton3D = entry["skeleton"]
    skeleton.force_update_all_bone_transforms()
    var display: Dictionary = visual_nodes[key]
    for i in range(skeleton.get_bone_count()):
        var name: String = skeleton.get_bone_name(i)
        var point: Vector3 = skeleton.get_bone_global_pose(i).origin
        var marker: MeshInstance3D = display["dots"][name]
        marker.position = point
        var parent_idx: int = skeleton.get_bone_parent(i)
        if parent_idx < 0:
            continue
        var parent_point: Vector3 = skeleton.get_bone_global_pose(parent_idx).origin
        var vector: Vector3 = point - parent_point
        var mesh_node: MeshInstance3D = display["segments"][name]
        mesh_node.position = (point + parent_point) * 0.5
        mesh_node.scale = Vector3(1.0, maxf(vector.length(), 0.01), 1.0)
        mesh_node.quaternion = Quaternion(Vector3.UP, vector.normalized()) if vector.length_squared() > 0.0001 else Quaternion.IDENTITY

func request_joint_pose(key: String, control_name: String, side: String, requested_deg: float) -> Dictionary:
    if not rigs.has(key):
        return {"accepted":false, "reason":"unknown hypothesis"}
    if not is_finite(requested_deg):
        return {"accepted":false, "reason":"nonfinite angle"}
    if not registry.get("joints", {}).has(control_name):
        return {"accepted":false, "reason":"unlisted joint action"}
    var constraint: Dictionary = registry["joints"][control_name]
    var pattern: String = str(constraint.get("bone", ""))
    if pattern.contains("{side}") and not side in ["L", "R"]:
        return {"accepted":false, "reason":"invalid limb side"}
    if not pattern.contains("{side}") and not side.is_empty():
        return {"accepted":false, "reason":"axial joint does not have limb side"}
    var bone_name: String = pattern.replace("{side}", side)
    var bone_index: int = (rigs[key]["skeleton"] as Skeleton3D).find_bone(bone_name)
    if bone_index < 0:
        return {"accepted":false, "reason":"joint bone missing"}
    var bounded: float = clampf(requested_deg, float(constraint.get("min_deg", 0.0)), float(constraint.get("max_deg", 0.0)))
    var axis := Vector3.ZERO
    match str(constraint.get("axis", "")):
        "x":
            axis = Vector3.RIGHT
        "y":
            axis = Vector3.UP
        "z":
            axis = Vector3.FORWARD
        _:
            return {"accepted":false, "reason":"illegal control axis"}
    var skeleton: Skeleton3D = rigs[key]["skeleton"]
    skeleton.set_bone_pose_rotation(bone_index, Quaternion(axis, deg_to_rad(bounded)))
    _update_visuals(key)
    var result: Dictionary = {"accepted":true, "hypothesis":key, "joint":control_name,
        "bone":bone_name, "requested_deg":requested_deg, "applied_deg":bounded,
        "clamped":not is_equal_approx(requested_deg, bounded),
        "scientific_confidence":"engineering_demo_only"}
    last_pose[key] = result
    return result

func reset_candidate(key: String) -> bool:
    if not rigs.has(key):
        return false
    var skeleton: Skeleton3D = rigs[key]["skeleton"]
    for index in range(skeleton.get_bone_count()):
        skeleton.set_bone_pose_rotation(index, Quaternion.IDENTITY)
    last_pose.erase(key)
    _update_visuals(key)
    return true

func set_display_mode(mode: String) -> bool:
    if not mode in ["both", "H-A", "H-B"]:
        return false
    selected = mode
    for key in rigs.keys():
        (rigs[key]["root"] as Node3D).visible = mode == "both" or mode == key
    if info != null:
        info.text = "0 Compare | 1 H-A | 2 H-B   •   Show: " + mode + "   •   Axial forearm pronation excluded"
    return true

func validation_summary() -> Dictionary:
    var counts: Dictionary = {}
    for key in rigs.keys():
        counts[key] = (rigs[key]["skeleton"] as Skeleton3D).get_bone_count()
    return {"status":registry.get("status",""), "counts":counts, "mode":selected,
        "unit_system":registry.get("units",""), "last_pose":last_pose.duplicate(true)}

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey:
        var key: InputEventKey = event as InputEventKey
        if not key.pressed or key.echo:
            return
        match key.keycode:
            KEY_0:
                set_display_mode("both")
            KEY_1:
                set_display_mode("H-A")
            KEY_2:
                set_display_mode("H-B")
