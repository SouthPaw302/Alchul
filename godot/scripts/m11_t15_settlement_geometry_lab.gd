extends Node3D

## T15 research-only: inspect actual original M2-M5 GLB triangle meshes and
## run transparent synthetic *intersections*, NOT archaeological access tests.
## T07 H-A / H-B are unmeasured body control references, never approved.
const CONFIG: String = "res://data/m11_t15_settlement_probes.json"
const RIG: String = "res://data/m11_t07_skeletal_reference.json"
const LAYER: int = 512
const STATUS: String = "UNSCALED_ORIGINAL_MESH_INTERSECTIONS_NOT_TRAVERSABILITY"
var config: Dictionary = {}
var rig: Dictionary = {}
var source_node: Node3D
var collider_container: Node3D
var overlay_boxes: Node3D
var camera: Camera3D
var head_label: Label
var details_label: Label
var warning_label: Label
var current_stage: String = ""
var source_bounds: AABB = AABB()
var bounds_ready: bool = false
var mesh_count: int = 0
var triangle_count: int = 0
var uv_surface_count: int = 0
var collider_count: int = 0
var source_sha256: String = ""
var body_envelopes: Dictionary = {}
var chosen_scale: int = 1
var selected_candidate: String = "both"
var last_probe: Dictionary = {}


func _read_json(path: String) -> Dictionary:
    var result: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    return result if result is Dictionary else {}


func _ready() -> void:
    config = _read_json(CONFIG)
    rig = _read_json(RIG)
    if str(config.get("status", "")) != STATUS:
        push_error("T15: missing explicit uncertainty")
        return
    if str(rig.get("status", "")) != "engineering_hypothesis_not_canon":
        push_error("T15: unapproved skeleton reference")
        return
    _read_body_envelopes()
    _build_stage()
    select_stage("M2")


func _read_body_envelopes() -> void:
    for body in rig.get("bodies", []):
        var key: String = str(body.get("id", ""))
        if key not in ["H-A", "H-B"]:
            continue
        var points: Array = body.get("bones", [])
        var lo: Vector3 = Vector3(INF, INF, INF)
        var hi: Vector3 = Vector3(-INF, -INF, -INF)
        for bone in points:
            var a: Array = bone.get("anchor", [])
            if a.size() != 3:
                continue
            var pos := Vector3(float(a[0]), float(a[1]), float(a[2]))
            lo = Vector3(minf(lo.x, pos.x), minf(lo.y, pos.y), minf(lo.z, pos.z))
            hi = Vector3(maxf(hi.x, pos.x), maxf(hi.y, pos.y), maxf(hi.z, pos.z))
        # Margins are *assumed* soft tissue. Not a true collision envelope.
        body_envelopes[key] = hi - lo + Vector3(0.40, 0.30, 0.40)


func _build_stage() -> void:
    var env := WorldEnvironment.new()
    env.name = "T15NeutralEnvironment"
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color(0.12, 0.18, 0.19)
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.76, 0.82, 0.76)
    e.ambient_light_energy = 0.8
    env.environment = e
    add_child(env)
    var sun := DirectionalLight3D.new()
    sun.name = "SourceGeometryLight"
    sun.rotation_degrees = Vector3(-48, 28, 0)
    sun.light_energy = 1.2
    add_child(sun)
    camera = Camera3D.new()
    camera.name = "SourceStudyCamera"
    camera.current = true
    camera.fov = 56.0
    add_child(camera)

    var layer := CanvasLayer.new()
    layer.name = "UnapprovedGeometryReport"
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(18, 15)
    panel.custom_minimum_size = Vector2(880, 155)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.06, 0.11, 0.12, 0.95)
    style.set_content_margin_all(14)
    panel.add_theme_stylebox_override("panel", style)
    layer.add_child(panel)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation", 5)
    panel.add_child(stack)
    head_label = _label("ALCHUL / T15 ORIGINAL M2-M5 GEOMETRY AUDIT", 20, Color(0.96, 0.75, 0.43))
    details_label = _label("Loading real GLB source...", 14, Color(0.90, 0.94, 0.87))
    warning_label = _label("Synthetic probes only. No approved body, meters, mapped doors, surveyed rooms or verified traversal.", 13, Color(0.70, 0.85, 0.82))
    stack.add_child(head_label)
    stack.add_child(details_label)
    stack.add_child(warning_label)
    stack.add_child(_label("1-4 source sites  |  5 H-A  |  6 H-B  |  7 both  |  S synthetic scale  |  C compare collisions", 13, Color(0.78, 0.83, 0.75)))


func _label(words: String, size: int, tint: Color) -> Label:
    var l := Label.new()
    l.text = words
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", tint)
    return l


func _stage_spec(key: String) -> Dictionary:
    for spec in config.get("geometry_source_stages", []):
        if str(spec.get("id", "")) == key:
            return spec
    return {}


func _world_box(node: MeshInstance3D) -> AABB:
    var local: AABB = node.mesh.get_aabb()
    var low: Vector3 = local.position
    var high: Vector3 = local.end
    var bounds: AABB = AABB(node.global_transform * low, Vector3.ZERO)
    for x in [low.x, high.x]:
        for y in [low.y, high.y]:
            for z in [low.z, high.z]:
                bounds = bounds.expand(node.global_transform * Vector3(x, y, z))
    return bounds


func _inventory_meshes() -> bool:
    bounds_ready = false
    mesh_count = 0
    triangle_count = 0
    uv_surface_count = 0
    collider_count = 0
    var color_mat := StandardMaterial3D.new()
    color_mat.resource_name = "Source COLOR_0; no invented texture UV"
    color_mat.vertex_color_use_as_albedo = true
    color_mat.roughness = 0.83
    for item in source_node.find_children("*", "MeshInstance3D", true, false):
        var mesh_node: MeshInstance3D = item as MeshInstance3D
        if mesh_node.mesh == null:
            continue
        mesh_count += 1
        mesh_node.material_override = color_mat
        var aabb: AABB = _world_box(mesh_node)
        source_bounds = aabb if not bounds_ready else source_bounds.merge(aabb)
        bounds_ready = true
        for surface in range(mesh_node.mesh.get_surface_count()):
            var index_count: int = mesh_node.mesh.surface_get_array_index_len(surface)
            var vertex_count: int = mesh_node.mesh.surface_get_array_len(surface)
            triangle_count += int((index_count if index_count > 0 else vertex_count) / 3)
            var arr: Array = mesh_node.mesh.surface_get_arrays(surface)
            var coords: Variant = arr[Mesh.ARRAY_TEX_UV]
            if coords is PackedVector2Array and not coords.is_empty():
                uv_surface_count += 1
        # Physics comes from actual source triangles, not placeholder boxes.
        var triangle_shape: Shape3D = mesh_node.mesh.create_trimesh_shape()
        if triangle_shape != null:
            var body := StaticBody3D.new()
            body.name = "OriginalTriangleCollider_" + str(mesh_count)
            body.collision_layer = LAYER
            body.collision_mask = 0
            collider_container.add_child(body)
            body.global_transform = mesh_node.global_transform
            var cs := CollisionShape3D.new()
            cs.shape = triangle_shape
            body.add_child(cs)
            collider_count += 1
    return bounds_ready and mesh_count > 0 and triangle_count > 0 and collider_count > 0


func select_stage(key: String) -> bool:
    var spec: Dictionary = _stage_spec(key)
    if spec.is_empty():
        return false
    var path: String = str(spec.get("path", ""))
    var resource: Resource = load(path)
    if not (resource is PackedScene):
        return false
    var instance: Node = (resource as PackedScene).instantiate()
    if not (instance is Node3D):
        instance.free()
        return false
    if source_node != null:
        remove_child(source_node)
        source_node.free()
    if collider_container != null:
        remove_child(collider_container)
        collider_container.free()
    if overlay_boxes != null:
        remove_child(overlay_boxes)
        overlay_boxes.free()
    source_node = instance as Node3D
    source_node.name = "ActualSourceGLB_" + key
    add_child(source_node)
    collider_container = Node3D.new()
    collider_container.name = "ActualSourceTriangleColliders"
    add_child(collider_container)
    current_stage = key
    source_sha256 = FileAccess.get_sha256(path)
    if not _inventory_meshes():
        push_error("T15 source GLB has no usable triangles: " + path)
        return false
    last_probe.clear()
    _update_camera()
    _show_envelopes()
    _refresh_hud()
    return true


func _update_camera() -> void:
    var span: float = maxf(source_bounds.size.length(), 4.0)
    var middle: Vector3 = source_bounds.get_center()
    camera.position = middle + Vector3(span * 0.76, span * 0.60, span * 0.93)
    camera.far = maxf(1500.0, span * 5.0)
    camera.look_at(middle, Vector3.UP)
    camera.make_current()


func _probe_center(fraction: Array) -> Vector3:
    return source_bounds.position + Vector3(
        source_bounds.size.x * float(fraction[0]),
        source_bounds.size.y * float(config["probe_center_y_aabb_fraction"]),
        source_bounds.size.z * float(fraction[1]))


func _scale_value() -> float:
    return float(config["synthetic_unverified_body_to_asset_scale_factors"][chosen_scale])


func _show_envelopes() -> void:
    if overlay_boxes != null:
        remove_child(overlay_boxes)
        overlay_boxes.free()
    overlay_boxes = Node3D.new()
    overlay_boxes.name = "SyntheticEnvelopes_NotWalkingPaths"
    add_child(overlay_boxes)
    var sample_points: Array = config.get("sample_site_aabb_fractions", [])
    for key in ["H-A", "H-B"]:
        if selected_candidate != "both" and selected_candidate != key:
            continue
        var sample: Array = sample_points[1] if key == "H-A" else sample_points[3]
        var box := MeshInstance3D.new()
        box.name = key + "_Synthetic3DEnvelope"
        var box_mesh := BoxMesh.new()
        box_mesh.size = (body_envelopes[key] as Vector3) * _scale_value()
        box.mesh = box_mesh
        box.position = _probe_center(sample)
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.92, 0.53, 0.23, 0.31) if key == "H-A" else Color(0.36, 0.85, 0.77, 0.31)
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        mat.cull_mode = BaseMaterial3D.CULL_DISABLED
        box.material_override = mat
        box.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        overlay_boxes.add_child(box)


func set_candidate(key: String) -> bool:
    if key not in ["both", "H-A", "H-B"]:
        return false
    selected_candidate = key
    _show_envelopes()
    _refresh_hud()
    return true


func set_synthetic_scale(index: int) -> bool:
    if index < 0 or index >= config["synthetic_unverified_body_to_asset_scale_factors"].size():
        return false
    chosen_scale = index
    _show_envelopes()
    _refresh_hud()
    return true


func run_probe_suite() -> Dictionary:
    if not bounds_ready:
        return {}
    var output: Dictionary = {}
    var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
    var points: Array = config["sample_site_aabb_fractions"]
    for key in ["H-A", "H-B"]:
        var scale_rows: Array = []
        for factor in config["synthetic_unverified_body_to_asset_scale_factors"]:
            var shape := BoxShape3D.new()
            shape.size = (body_envelopes[key] as Vector3) * float(factor)
            var sample_hits: Array[int] = []
            for fraction in points:
                var probe := PhysicsShapeQueryParameters3D.new()
                probe.shape = shape
                probe.transform = Transform3D(Basis.IDENTITY, _probe_center(fraction))
                probe.collision_mask = LAYER
                probe.collide_with_bodies = true
                probe.collide_with_areas = false
                var overlaps: Array[Dictionary] = space.intersect_shape(probe, 256)
                sample_hits.append(overlaps.size())
            scale_rows.append({"factor_not_calibrated":factor,
                "triangle_collider_hits_per_probe":sample_hits,
                "sample_has_no_hits":sample_hits.count(0),
                "traversability":"UNKNOWN"})
        output[key] = scale_rows
    last_probe = {"status":STATUS, "stage":current_stage,
        "real_glb_triangle_collision":true, "source_sha256":source_sha256,
        "source_units_meters":false, "calibrated_body_scale":false,
        "approved_anatomy":false, "site_function_mapped":false,
        "walkability_verified":false, "results":output}
    _refresh_hud()
    return last_probe.duplicate(true)


func geometry_summary() -> Dictionary:
    return {"status":STATUS, "stage":current_stage, "source_sha256":source_sha256,
        "mesh_count":mesh_count, "source_triangles":triangle_count,
        "uv_surfaces":uv_surface_count, "triangle_colliders":collider_count,
        "bounds":source_bounds, "bodies":body_envelopes.duplicate(true),
        "source_units_meters":false, "model_to_asset_scale_validated":false,
        "creator_anatomy_approved":false, "hypotheses":["H-A","H-B"],
        "present_day_body_known":false, "walkability_verified":false}


func _refresh_hud() -> void:
    if head_label == null:
        return
    var desc: String = str(_stage_spec(current_stage).get("label", "unknown"))
    head_label.text = "ALCHUL / T15 — " + current_stage + " " + desc.to_upper()
    details_label.text = "REAL GLB: %d meshes / %d triangles / %d source UV surfaces / %d triangle colliders  |  SYNTHETIC RATIO: %.2f" % [
        mesh_count, triangle_count, uv_surface_count, collider_count, _scale_value()]
    warning_label.text = "H-A/H-B translucent rectangles: NOT measured bodies or actual designed corridors. " + (
        "Probe suite recorded; traversal remains UNKNOWN." if not last_probe.is_empty()
        else "Press C to check actual triangles at 5 arbitrary AABB-fraction locations.")


func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1, KEY_2, KEY_3, KEY_4:
            select_stage(["M2","M3","M4","M5"][event.keycode - KEY_1])
        KEY_5:
            set_candidate("H-A")
        KEY_6:
            set_candidate("H-B")
        KEY_7:
            set_candidate("both")
        KEY_S:
            set_synthetic_scale((chosen_scale + 1) % config["synthetic_unverified_body_to_asset_scale_factors"].size())
        KEY_C:
            run_probe_suite()
