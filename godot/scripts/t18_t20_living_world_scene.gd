extends Node3D

## ALCHUL T18–T20: a playable WORLD-BUILDING scene, not a history claim.
## Uses T17's actual causal physical-response code while dramatizing four
## proposed inhabitants' different readings and multimodal communication.
const STORY_FILE: String = "res://data/t18_t20_the_river_answered_twice.json"
const T17_LAB: PackedScene = preload("res://scenes/m11_t17_physical_sensing_lab.tscn")
const M2_SOURCE: PackedScene = preload("res://assets/m2/ALC_M2_RIVER_STATION_v001.glb")
const LENSES: Array[String] = ["trace", "reading", "unclosed"]
const TRIALS: Array[String] = ["water", "support", "ambiguous"]

var story: Dictionary = {}
var sensing: Node3D
var source: Node3D
var camera: Camera3D
var reed_bed: Node3D
var reed_markers: Dictionary = {}
var beat_index: int = 0
var lens_index: int = 0
var trial_id: String = ""
var trial_record: Dictionary = {}
var record_log: Array[Dictionary] = []
var blind_repeat_done: bool = false
var heading: Label
var passage: Label
var lens_text: Label
var state_text: Label
var signal_text: Label
var science_text: Label
var import_mesh_count: int = 0


func _ready() -> void:
    var loaded: Variant = JSON.parse_string(FileAccess.get_file_as_string(STORY_FILE))
    if not (loaded is Dictionary) or loaded.get("status") != "PROVISIONAL_FICTIONAL_CULTURE_NOT_ANATOMY_CANON":
        push_error("T18–T20 fictional scene contract missing")
        return
    story = loaded
    _build_environment()
    _create_source()
    _create_hidden_physical_reference()
    _build_reed_bed()
    _build_interface()
    _update_view()


func _base_material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.83
    material.metallic = 0.0
    return material


func _make_box(group: Node3D, name: String, pos: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
    var box := BoxMesh.new()
    box.size = size
    var result := MeshInstance3D.new()
    result.name = name
    result.mesh = box
    result.position = pos
    result.material_override = _base_material(tint)
    group.add_child(result)
    return result


func _build_environment() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color(0.13, 0.19, 0.20)
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.82, 0.86, 0.79)
    e.ambient_light_energy = 0.8
    env.environment = e
    add_child(env)
    var sunlight := DirectionalLight3D.new()
    sunlight.name = "BraidedReachLateDay"
    sunlight.rotation_degrees = Vector3(-49, 31, 0)
    sunlight.light_energy = 1.4
    add_child(sunlight)
    camera = Camera3D.new()
    camera.name = "T18T20StoryCamera"
    camera.current = true
    camera.fov = 55.0
    add_child(camera)


func _create_source() -> void:
    source = M2_SOURCE.instantiate()
    source.name = "OriginalM2SettlementSource"
    add_child(source)
    var has_bounds: bool = false
    var bounds: AABB = AABB()
    var visual := StandardMaterial3D.new()
    visual.vertex_color_use_as_albedo = true
    visual.roughness = 0.86
    for item in source.find_children("*", "MeshInstance3D", true, false):
        var mesh: MeshInstance3D = item as MeshInstance3D
        if mesh.mesh == null:
            continue
        import_mesh_count += 1
        mesh.material_override = visual
        var local_box: AABB = mesh.mesh.get_aabb()
        for x in [local_box.position.x, local_box.end.x]:
            for y in [local_box.position.y, local_box.end.y]:
                for z in [local_box.position.z, local_box.end.z]:
                    var sample: Vector3 = mesh.global_transform * Vector3(x, y, z)
                    if not has_bounds:
                        bounds = AABB(sample, Vector3.ZERO)
                        has_bounds = true
                    else:
                        bounds = bounds.expand(sample)
    if not has_bounds:
        push_error("T18–T20 failed to load original first-party M2 meshes")
        return
    var span: float = maxf(bounds.size.length(), 8.0)
    var center: Vector3 = bounds.get_center()
    camera.position = center + Vector3(span * 0.66, span * 0.51, span * 0.85)
    camera.far = maxf(1200, span * 5.0)
    camera.look_at(center)
    camera.make_current()


func _create_hidden_physical_reference() -> void:
    sensing = T17_LAB.instantiate()
    sensing.name = "T17SourceOfPhysicalReadings_Hidden"
    add_child(sensing)
    sensing.visible = false
    var layer: CanvasLayer = sensing.get_node_or_null("ScientificPhysicalSensorHUD")
    if layer != null:
        layer.visible = false
    var physics_camera: Camera3D = sensing.get_node_or_null("Camera3D")
    if physics_camera != null:
        physics_camera.current = false
    camera.make_current()


func _build_reed_bed() -> void:
    reed_bed = Node3D.new()
    reed_bed.name = "ReedRecord_ThreeIndependentAccounts"
    add_child(reed_bed)
    # Spatial arrangement is for the scene display, not an archaeological
    # claim about real settled ALCHUL architecture or metric dimensions.
    reed_bed.position = Vector3(0, 0.7, 0)
    _make_box(reed_bed, "RecordBed", Vector3.ZERO,
        Vector3(5.2, 0.25, 2.1), Color(0.47, 0.38, 0.30))
    var translations: Array[String] = ["TRACE", "READING", "UNCLOSED"]
    var palette: Array[Color] = [
        Color(0.35, 0.73, 0.78), Color(0.92, 0.70, 0.40), Color(0.66, 0.57, 0.79)]
    for i in range(3):
        var cue := Node3D.new()
        cue.name = translations[i] + "_RemovableReed"
        cue.position = Vector3(float(i - 1) * 1.55, 0.25, 0)
        reed_bed.add_child(cue)
        _make_box(cue, "EngravedStave", Vector3.ZERO,
            Vector3(0.16, 0.22, 1.45), palette[i])
        var marker := Label3D.new()
        marker.text = translations[i]
        marker.font_size = 34
        marker.pixel_size = 0.006
        marker.position = Vector3(0, 0.5, -0.72)
        marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        cue.add_child(marker)
        reed_markers[LENSES[i]] = cue


func _styled_label(size: int, color: Color, wrap_width: float) -> Label:
    var label := Label.new()
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.custom_minimum_size = Vector2(wrap_width, 0)
    return label


func _build_interface() -> void:
    var layer := CanvasLayer.new()
    layer.name = "T18T20FictionalSceneHUD"
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(18, 14)
    panel.custom_minimum_size = Vector2(1205, 170)
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color(0.06, 0.11, 0.13, 0.94)
    panel_style.set_content_margin_all(13)
    panel.add_theme_stylebox_override("panel", panel_style)
    layer.add_child(panel)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation", 7)
    panel.add_child(content)
    heading = _styled_label(21, Color(0.97, 0.76, 0.46), 1140)
    passage = _styled_label(16, Color(0.92, 0.92, 0.86), 1140)
    lens_text = _styled_label(14, Color(0.68, 0.84, 0.81), 1140)
    content.add_child(heading)
    content.add_child(passage)
    content.add_child(lens_text)

    var foot := PanelContainer.new()
    foot.position = Vector2(18, 560)
    foot.custom_minimum_size = Vector2(1205, 140)
    var foot_style := StyleBoxFlat.new()
    foot_style.bg_color = Color(0.07, 0.12, 0.14, 0.94)
    foot_style.set_content_margin_all(12)
    foot.add_theme_stylebox_override("panel", foot_style)
    layer.add_child(foot)
    var stack := VBoxContainer.new()
    foot.add_child(stack)
    state_text = _styled_label(16, Color(0.99, 0.86, 0.63), 1140)
    signal_text = _styled_label(13, Color(0.78, 0.91, 0.86), 1140)
    science_text = _styled_label(12, Color(0.68, 0.79, 0.78), 1140)
    stack.add_child(state_text)
    stack.add_child(signal_text)
    stack.add_child(science_text)


func _lens_info() -> Dictionary:
    for row in story.get("narrative_lenses", []):
        if row.get("id") == LENSES[lens_index]:
            return row
    return {}


func _trial_info(id: String) -> Dictionary:
    for trial in story.get("trials", []):
        if trial.get("id") == id:
            return trial
    return {}


func next_beat() -> bool:
    if beat_index + 1 >= story.get("opening", []).size():
        return false
    beat_index += 1
    _update_view()
    return true


func change_lens() -> String:
    lens_index = (lens_index + 1) % LENSES.size()
    _update_view()
    return LENSES[lens_index]


func set_lens(name: String) -> bool:
    if name not in LENSES:
        return false
    lens_index = LENSES.find(name)
    _update_view()
    return true


func reset_scene() -> void:
    beat_index = 0
    trial_id = ""
    trial_record.clear()
    record_log.clear()
    blind_repeat_done = false
    if sensing != null:
        sensing.set_source_active("river_pulse", true)
        sensing.set_source_active("bank_vibration", true)
        sensing.demo_false_positive = false
        sensing.update_readings()
    _update_view()


func _interpret_observer(water: float, substrate: float, observer: String) -> String:
    # Interpretation is narratively biased by experience. These are *not*
    # different biological receptor claims or calibrated probabilities.
    var water_bias: float = 0.08 if observer == "listener" else -0.10
    var support_bias: float = -0.03 if observer == "listener" else 0.11
    var w: float = water + water_bias
    var s: float = substrate + support_bias
    if maxf(w, s) < 0.18 or absf(w - s) < 0.055:
        return "undetermined"
    return "bank pulse" if w > s else "support strain"


func choose_trial(id: String) -> bool:
    if not id in TRIALS or sensing == null:
        return false
    var trial: Dictionary = _trial_info(id)
    if trial.is_empty():
        return false
    trial_id = id
    trial_record.clear()
    record_log.clear()
    blind_repeat_done = false
    var enabled_sources: Array = trial.get("stimulus", [])
    sensing.set_source_active("river_pulse", "river_pulse" in enabled_sources)
    sensing.set_source_active("bank_vibration", "bank_vibration" in enabled_sources)
    sensing.demo_false_positive = id == "ambiguous"
    sensing.time_sample = 0.0
    sensing.update_readings()
    _update_view()
    return true


func repeat_blind_test() -> Dictionary:
    if trial_id == "" or sensing == null:
        return {}
    # The reader scene *does not know* which source controls were changed;
    # only T17's physical measurements and the observers' scene priors enter.
    var water: Dictionary = sensing.sensor_reading("bank_reader", "water", 0.0)
    var substrate: Dictionary = sensing.sensor_reading("bank_reader", "vibration", 0.0)
    var witness: Dictionary = sensing.sensor_reading("witness_reader", "water", 0.0,
        trial_id == "ambiguous")
    var w: float = float(water.get("reading_normalized", 0.0))
    var v: float = float(substrate.get("reading_normalized", 0.0))
    var listener_read: String = _interpret_observer(w, v, "listener")
    var turner_read: String = _interpret_observer(w, v, "turner")
    var log_entry: Dictionary = {
        "repeat_index":record_log.size() + 1,
        "physical_trace":{"water_normalized":w,"substrate_normalized":v,
            "matched_water_sources":water.get("matched_sources", []),
            "matched_vibration_sources":substrate.get("matched_sources", [])},
        "observer_readings":{"river_listener":listener_read,
            "reed_turner":turner_read},
        "independent_readings":true,
        "disagreement":listener_read != turner_read,
        "safety_decision":"close_narrow_route_keep_broad_route_checked",
        "witness_account":"same river bend briefly without water; explanation unclosed",
        "witness_signal_normalized":witness.get("reading_normalized", 0.0),
        "witness_claim_is_measured_Alchul":false,
        "truth_status":"physical source conditions are a reversible fictional experiment",
        "anatomy_certified":false
    }
    trial_record = log_entry.duplicate(true)
    record_log.append(log_entry.duplicate(true))
    blind_repeat_done = true
    _update_view()
    return trial_record.duplicate(true)


func _update_view() -> void:
    if heading == null or story.is_empty():
        return
    var mode: Dictionary = _lens_info()
    heading.text = "ALCHUL / T18–T20  •  THE RIVER ANSWERED TWICE  |  " + str(mode.get("name", ""))
    var opening: Array = story.get("opening", [])
    passage.text = str(opening[beat_index]) if beat_index < opening.size() else ""
    lens_text.text = str(mode.get("description", "")) + "   /   proposed lived culture, not established history"
    for key in reed_markers:
        var item: Node3D = reed_markers[key]
        item.scale.y = 1.3 if key == LENSES[lens_index] else 0.85
        item.rotation_degrees.z = 8.0 if key == "unclosed" else (0.0 if key == "trace" else -8.0)
    if trial_id == "":
        state_text.text = "SPACE next scene beat  |  L perspective  |  1 water intervention  |  2 support test  |  3 ambiguous case"
        signal_text.text = "Four residents keep three records: material trace, independent interpretation, and contact testimony."
    elif not blind_repeat_done:
        var trial: Dictionary = _trial_info(trial_id)
        state_text.text = "INTERVENTION: " + str(trial.get("title", "")) + "   |   T repeat blind reading   |   R reset"
        signal_text.text = str(trial.get("intent", ""))
    else:
        var current: Dictionary = _trial_info(trial_id)
        var readers: Dictionary = trial_record.get("observer_readings", {})
        state_text.text = str(current.get("ending", "")) + "   |   Listener: " + str(readers.get("river_listener", "")) + "   /   Turner: " + str(readers.get("reed_turner", ""))
        signal_text.text = str(current.get("conclusion", "")) + "   |   T repeat   |   R reset"
    science_text.text = "Three account lenses • proposed gestures/translation • inherited T17 signal source • no Alchul POV • no approved anatomy"


func story_summary() -> Dictionary:
    return {"status":story.get("status", ""),
        "stage":"mature surface hypothetical lived scene",
        "original_first_party_scene":source != null,
        "original_mesh_count":import_mesh_count,
        "t17_source_integrated":sensing != null and sensing.has_method("sensor_reading"),
        "lens_count":LENSES.size(),
        "proposed_gesture_count":story.get("lexicon", []).size(),
        "character_roles":story.get("actors", []).size(),
        "trial_count":TRIALS.size(),
        "blind_records":record_log.size(),
        "body_anatomy_approved":false,
        "alchul_entity_rendered":false,
        "contact_claim_proved_by_physics":false,
        "public_chapter_changed":false}


func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_SPACE:
            next_beat()
        KEY_L:
            change_lens()
        KEY_1:
            choose_trial("water")
        KEY_2:
            choose_trial("support")
        KEY_3:
            choose_trial("ambiguous")
        KEY_T:
            repeat_blind_test()
        KEY_R:
            reset_scene()
        _:
            return
