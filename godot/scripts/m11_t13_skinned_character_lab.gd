extends "res://scripts/m11_t07_joint_lab.gd"

## T13: actual Skeleton3D-skinned procedural surface and deterministic pose cycles.
## Entirely NONCANONICAL: H-A/H-B are undated pre-KPg engineering alternatives.
## The geometry, skin coverage, clip timing and materials are art-tool hypotheses.
const CLIPS: Array[String] = ["walk", "turn", "grip", "rest", "communicate"]
const VARIANTS: Array[String] = ["river_silt", "shade_moss", "contrast_study"]
const SCIENCE_GATE: String = "provisional_surface_not_approved"
var clip: String = "walk"
var phase: float = 0.0
var playing: bool = true
var lod_index: int = 0
var surface_variant: String = "river_silt"
var skins: Dictionary = {}
var materials: Dictionary = {}


func _ready() -> void:
    super._ready()
    if rigs.size() != 2:
        push_error("T13 requires both T07 hypotheses")
        return
    _prepare_materials()
    for candidate in registry.get("bodies", []):
        _create_character_shell(candidate)
    var hud: Node = get_node_or_null("SkeletalStudyHud/PanelContainer/VBoxContainer")
    if hud != null and hud.get_child_count() > 0:
        (hud.get_child(0) as Label).text = "ALCHUL / T13 — SKINNED CHARACTER ENGINEERING STUDY • NOT CANON"
    _apply_pose(0.0)
    _update_hud()


func _prepare_materials() -> void:
    var palettes: Dictionary = {
        "river_silt": [Color(0.49, 0.43, 0.35), Color(0.63, 0.54, 0.41), Color(0.32, 0.31, 0.29)],
        "shade_moss": [Color(0.36, 0.44, 0.37), Color(0.38, 0.52, 0.46), Color(0.28, 0.35, 0.33)],
        "contrast_study": [Color(0.64, 0.45, 0.32), Color(0.28, 0.59, 0.62), Color(0.19, 0.22, 0.26)]
    }
    for variant in VARIANTS:
        var group: Array = []
        var colors: Array = palettes[variant]
        for j in range(3):
            var base: Color = colors[j]
            var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
            var roughness := Image.create(64, 64, false, Image.FORMAT_RGBA8)
            for y in range(64):
                for x in range(64):
                    var wave: float = 0.5 + 0.5 * sin(float(x * 13 + y * 7 + j * 19) * 0.11)
                    image.set_pixel(x, y, base.lerp(Color(0.92, 0.89, 0.82), 0.08 * wave))
                    roughness.set_pixel(x, y, Color(0.77 + 0.13 * wave, 0.77 + 0.13 * wave, 0.77 + 0.13 * wave))
            var mat := StandardMaterial3D.new()
            mat.albedo_texture = ImageTexture.create_from_image(image)
            mat.roughness_texture = ImageTexture.create_from_image(roughness)
            mat.roughness = 0.87
            mat.metallic = 0.0
            mat.cull_mode = BaseMaterial3D.CULL_DISABLED
            group.append(mat)
        materials[variant] = group


func _surface_id(name: String, region: String) -> int:
    if name.begins_with("manual_") or name.begins_with("pedal_") or name == "mandible":
        return 2  # keratin / digit rendering convention only
    if name.begins_with("caudal_") or name.begins_with("scapula") or region == "forelimb":
        return 1  # filament concept, coverage unapproved
    return 0


func _radius(name: String) -> float:
    if name == "thorax":
        return 0.34
    if name == "spine":
        return 0.30
    if name == "skull":
        return 0.28
    if name.begins_with("neck_"):
        return 0.16
    if name.begins_with("caudal_"):
        return maxf(0.065, 0.19 - 0.03 * float(name.trim_prefix("caudal_").to_int()))
    if name.begins_with("femur"):
        return 0.19
    if name.begins_with("tibia"):
        return 0.13
    if name.begins_with("metatarsus"):
        return 0.105
    if name.begins_with("humerus"):
        return 0.12
    if name.begins_with("antebrachium"):
        return 0.085
    if name.begins_with("manual_"):
        return 0.048
    if name.begins_with("pedal_"):
        return 0.058
    return 0.12


func _create_character_shell(spec: Dictionary) -> void:
    var key: String = str(spec.get("id", ""))
    var entry: Dictionary = rigs[key]
    var root_node: Node3D = entry["root"]
    var skeleton: Skeleton3D = entry["skeleton"]
    var old_visual: Node3D = root_node.get_node("JointAndBoneVisuals")
    old_visual.visible = false
    skins[key] = {}
    for lod in range(2):
        var mesh := MeshInstance3D.new()
        mesh.name = "SkinnedShell_LOD" + str(lod)
        mesh.mesh = _make_mesh(spec, skeleton, 10 if lod == 0 else 5)
        mesh.skeleton = NodePath("../ResearchSkeleton3D")
        mesh.skin = skeleton.create_skin_from_rest_transforms()
        root_node.add_child(mesh)
        (skins[key] as Dictionary)[lod] = mesh
        mesh.visible = lod == lod_index
        for surface_index in range(mesh.mesh.get_surface_count()):
            mesh.set_surface_override_material(surface_index, (materials[surface_variant] as Array)[surface_index])
    _add_collision_proxies(root_node)


func _make_mesh(spec: Dictionary, skeleton: Skeleton3D, radial: int) -> ArrayMesh:
    var graph: Array = spec.get("bones", [])
    var anchors: Dictionary = {}
    var records: Dictionary = {}
    for record in graph:
        var xyz: Array = record["anchor"]
        anchors[record["name"]] = Vector3(float(xyz[0]), float(xyz[1]), float(xyz[2]))
        records[record["name"]] = record
    var surfaces: Array = [[], [], []]
    for record in graph:
        var name: String = str(record["name"])
        if record.get("parent") == null:
            continue
        var parent: String = str(record["parent"])
        var a: Vector3 = anchors[parent]
        var b: Vector3 = anchors[name]
        var axis: Vector3 = (b - a).normalized()
        var u: Vector3 = axis.cross(Vector3.UP)
        if u.length_squared() < 0.002:
            u = axis.cross(Vector3.RIGHT)
        u = u.normalized()
        var v: Vector3 = axis.cross(u).normalized()
        var parent_id: int = skeleton.find_bone(parent)
        var own_id: int = skeleton.find_bone(name)
        var radius: float = _radius(name)
        var category: int = _surface_id(name, str(record.get("region", "")))
        var record_data: Dictionary = {"v":PackedVector3Array(), "n":PackedVector3Array(),
            "uv":PackedVector2Array(), "b":PackedInt32Array(), "w":PackedFloat32Array(), "ix":PackedInt32Array()}
        for ring in range(3):
            var t: float = float(ring) / 2.0
            var center: Vector3 = a.lerp(b, t)
            var taper: float = 1.07 - 0.22 * t
            var child_weight: float = 0.04 if ring == 0 else (0.5 if ring == 1 else 0.96)
            for j in range(radial + 1):
                var angle: float = TAU * float(j) / float(radial)
                var normal: Vector3 = u * cos(angle) + v * sin(angle)
                record_data["v"].append(center + normal * radius * taper)
                record_data["n"].append(normal)
                record_data["uv"].append(Vector2(float(j) / float(radial), t))
                record_data["b"].append_array(PackedInt32Array([parent_id, own_id, 0, 0]))
                record_data["w"].append_array(PackedFloat32Array([1.0 - child_weight, child_weight, 0.0, 0.0]))
        for ring in range(2):
            for j in range(radial):
                var i: int = ring * (radial + 1) + j
                record_data["ix"].append_array(PackedInt32Array([
                    i, i + radial + 1, i + 1, i + 1, i + radial + 1, i + radial + 2]))
        surfaces[category].append(record_data)
    var output := ArrayMesh.new()
    for category in range(3):
        var vertices := PackedVector3Array()
        var normals := PackedVector3Array()
        var uv := PackedVector2Array()
        var bones := PackedInt32Array()
        var weights := PackedFloat32Array()
        var indices := PackedInt32Array()
        for piece in surfaces[category]:
            var offset: int = vertices.size()
            vertices.append_array(piece["v"])
            normals.append_array(piece["n"])
            uv.append_array(piece["uv"])
            bones.append_array(piece["b"])
            weights.append_array(piece["w"])
            for old_index in piece["ix"]:
                indices.append(offset + int(old_index))
        var arrays: Array = []
        arrays.resize(Mesh.ARRAY_MAX)
        arrays[Mesh.ARRAY_VERTEX] = vertices
        arrays[Mesh.ARRAY_NORMAL] = normals
        arrays[Mesh.ARRAY_TEX_UV] = uv
        arrays[Mesh.ARRAY_BONES] = bones
        arrays[Mesh.ARRAY_WEIGHTS] = weights
        arrays[Mesh.ARRAY_INDEX] = indices
        output.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    return output


func _add_collision_proxies(group: Node3D) -> void:
    var body := StaticBody3D.new()
    body.name = "ProxyEnvelope_NotAnatomical"
    body.collision_layer = 16
    body.collision_mask = 0
    group.add_child(body)
    var center := CollisionShape3D.new()
    center.name = "Torso_ClearanceProxy"
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.57
    capsule.height = 2.8
    center.shape = capsule
    center.position = Vector3(0.65, 1.45, 0.0)
    body.add_child(center)
    var tail := CollisionShape3D.new()
    tail.name = "Tail_ClearanceProxy"
    var shape := BoxShape3D.new()
    shape.size = Vector3(3.15, 0.45, 0.6)
    tail.shape = shape
    tail.position = Vector3(-1.6, 1.66, 0.0)
    body.add_child(tail)


func _set_joint_pose(skeleton: Skeleton3D, control: String, side: String, angle: float) -> void:
    var rule: Dictionary = registry["joints"][control]
    var bone_name: String = str(rule["bone"]).replace("{side}", side)
    var index: int = skeleton.find_bone(bone_name)
    if index < 0:
        return
    var bounded: float = clampf(angle, float(rule["min_deg"]), float(rule["max_deg"]))
    var axis: Vector3 = Vector3.FORWARD
    if rule["axis"] == "y":
        axis = Vector3.UP
    elif rule["axis"] == "x":
        axis = Vector3.RIGHT
    skeleton.set_bone_pose_rotation(index, Quaternion(axis, deg_to_rad(bounded)))


func _apply_pose(at_phase: float) -> void:
    phase = fposmod(at_phase, 1.0)
    var beat: float = sin(phase * TAU)
    for key in rigs.keys():
        var skeleton: Skeleton3D = rigs[key]["skeleton"]
        for i in range(skeleton.get_bone_count()):
            skeleton.set_bone_pose_rotation(i, Quaternion.IDENTITY)
        match clip:
            "walk":
                _set_joint_pose(skeleton, "hip_pitch", "L", beat * 17.0)
                _set_joint_pose(skeleton, "hip_pitch", "R", -beat * 17.0)
                _set_joint_pose(skeleton, "knee_flex", "L", -10.0 - maxf(0.0, beat) * 24.0)
                _set_joint_pose(skeleton, "knee_flex", "R", -10.0 - maxf(0.0, -beat) * 24.0)
                _set_joint_pose(skeleton, "ankle_flex", "L", -beat * 12.0)
                _set_joint_pose(skeleton, "ankle_flex", "R", beat * 12.0)
                _set_joint_pose(skeleton, "tail_yaw", "", beat * 8.0)
            "turn":
                _set_joint_pose(skeleton, "tail_yaw", "", beat * 12.0)
                _set_joint_pose(skeleton, "neck_pitch", "", beat * 9.0)
                _set_joint_pose(skeleton, "hip_pitch", "L", beat * 11.0)
                _set_joint_pose(skeleton, "hip_pitch", "R", -beat * 7.0)
            "grip":
                for side in ["L", "R"]:
                    _set_joint_pose(skeleton, "shoulder_swing", side, 10.0 + beat * 6.0)
                    _set_joint_pose(skeleton, "elbow_flex", side, -32.0 - 9.0 * beat)
                    _set_joint_pose(skeleton, "wrist_fold", side, 7.0 + 8.0 * beat)
                    for digit in ["I", "II", "III"]:
                        _set_joint_pose(skeleton, "manual_" + digit + "_flex", side, -18.0 - 12.0 * beat)
            "rest":
                _set_joint_pose(skeleton, "neck_pitch", "", -5.0 + 3.0 * beat)
                _set_joint_pose(skeleton, "tail_yaw", "", 2.0 * beat)
            "communicate":
                _set_joint_pose(skeleton, "neck_pitch", "", 7.0 + beat * 12.0)
                _set_joint_pose(skeleton, "mandible_open", "", 5.0 + beat * 7.0)
                _set_joint_pose(skeleton, "tail_yaw", "", beat * 10.0)
        skeleton.force_update_all_bone_transforms()


func _process(delta: float) -> void:
    if playing and not rigs.is_empty():
        _apply_pose(phase + delta * 0.33)


func set_clip(name: String) -> bool:
    if name not in CLIPS:
        return false
    clip = name
    _apply_pose(phase)
    _update_hud()
    return true


func sample_pose(time_fraction: float) -> bool:
    if not is_finite(time_fraction):
        return false
    _apply_pose(time_fraction)
    return true


func set_lod(index: int) -> bool:
    if index not in [0, 1]:
        return false
    lod_index = index
    for key in skins:
        for detail in skins[key]:
            (skins[key][detail] as MeshInstance3D).visible = int(detail) == index
    _update_hud()
    return true


func set_surface_variant(name: String) -> bool:
    if name not in VARIANTS:
        return false
    surface_variant = name
    for key in skins:
        for index in skins[key]:
            var mesh: MeshInstance3D = skins[key][index]
            for surface_index in range(mesh.mesh.get_surface_count()):
                mesh.set_surface_override_material(surface_index,
                    (materials[name] as Array)[surface_index])
    _update_hud()
    return true


func _update_hud() -> void:
    if info != null:
        info.text = "0 Both / 1 H-A / 2 H-B  |  3-7 motions  |  L LOD  |  V material  |  SPACE pause"
    var existing: Node = get_node_or_null("SkeletalStudyHud/T13State")
    if existing == null:
        var label := Label.new()
        label.name = "T13State"
        label.position = Vector2(20, 112)
        label.add_theme_font_size_override("font_size", 16)
        (get_node("SkeletalStudyHud") as CanvasLayer).add_child(label)
        existing = label
    (existing as Label).text = "MOTION: %s  |  LOD: %s  |  SURFACE: %s  |  %s" % [
        clip.to_upper(), str(lod_index), surface_variant, SCIENCE_GATE]


func engineering_summary() -> Dictionary:
    var counts: Dictionary = {}
    var triangles: Dictionary = {}
    for key in skins:
        var skeleton: Skeleton3D = rigs[key]["skeleton"]
        counts[key] = skeleton.get_bone_count()
        var mesh: MeshInstance3D = skins[key][0]
        var tri_count: int = 0
        for s in range(mesh.mesh.get_surface_count()):
            tri_count += mesh.mesh.surface_get_array_index_len(s) / 3
        triangles[key] = tri_count
    return {"status": SCIENCE_GATE, "clips": CLIPS.duplicate(), "surface_variants": VARIANTS.duplicate(),
        "skinned":true, "lod_count":2, "collision_proxies":true, "skeleton_bones":counts,
        "rendered_triangles_lod0":triangles, "clip":clip, "lod":lod_index,
        "modern_body_claim":false, "biology_approved":false, "canon_promoted":false,
        "era":"undated pre_KPg surface design hypothesis", "alchul_ontology_defined":false}


func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_0:
            set_display_mode("both")
        KEY_1:
            set_display_mode("H-A")
        KEY_2:
            set_display_mode("H-B")
        KEY_3, KEY_4, KEY_5, KEY_6, KEY_7:
            set_clip(CLIPS[event.keycode - KEY_3])
        KEY_L:
            set_lod(1 - lod_index)
        KEY_V:
            set_surface_variant(VARIANTS[(VARIANTS.find(surface_variant) + 1) % VARIANTS.size()])
        KEY_SPACE:
            playing = not playing
        _:
            return
    _update_hud()
