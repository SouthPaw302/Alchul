extends Node3D

## T17 research-only causal physical signal -> sensor -> reaction pipeline.
## No claimed fossil receptor, nonlocal physics, or Alchul entity representation.
const CONFIG_PATH: String = "res://data/m11_t17_physical_sensing.json"
const STATUS: String = "FICTIONAL_CAUSAL_SENSOR_ENGINEERING_NOT_VERIFIED_RECEPTOR_BIOLOGY"
const CHANNELS: Array[String] = ["water","vibration","stress","heat","gas","acoustic"]
var config: Dictionary = {}
var active_sources: Dictionary = {}
var source_visuals: Dictionary = {}
var reader_visuals: Dictionary = {}
var time_sample: float = 0.0
var playing: bool = false
var demo_false_positive: bool = false
var title_text: Label
var audit_text: Label
var last_reports: Dictionary = {}


func _ready() -> void:
    var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH))
    if not (payload is Dictionary) or payload.get("status") != STATUS:
        push_error("T17 physical source contract absent")
        return
    config = payload
    for src in config["sources"]:
        active_sources[src["id"]] = true
    _build_scene()
    update_readings()


func _material(c: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = c
    m.roughness = 0.88
    return m


func _box(parent: Node3D, name: String, location: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = size
    var node := MeshInstance3D.new()
    node.name = name
    node.mesh = mesh
    node.position = location
    node.material_override = _material(tint)
    parent.add_child(node)
    return node


func _build_scene() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color(0.13,0.20,0.22)
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.84,0.87,0.80)
    env.environment = e
    add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-46,28,0)
    add_child(sun)
    _box(self,"UnscaledSignalField",Vector3(1,-0.12,3),Vector3(40,0.12,30),Color(0.31,0.38,0.35))
    var channel_color: Dictionary = {
        "water":Color(0.31,0.65,0.78), "vibration":Color(0.78,0.62,0.36),
        "stress":Color(0.93,0.47,0.32),"heat":Color(0.83,0.35,0.29),
        "gas":Color(0.43,0.78,0.47),"acoustic":Color(0.68,0.58,0.89)}
    for src in config["sources"]:
        var at: Array = src["position"]
        var container := Node3D.new()
        container.name = "PhysicalCause_" + str(src["id"])
        container.position = Vector3(float(at[0]),0,float(at[1]))
        add_child(container)
        _box(container,"ObservableOrigin",Vector3(0,.30,0),Vector3(.75,.60,.75),channel_color[src["channel"]])
        var label := Label3D.new()
        label.text = str(src["id"]).replace("_"," ").to_upper()
        label.font_size = 24
        label.pixel_size = 0.009
        label.position = Vector3(0,1.14,0)
        label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        container.add_child(label)
        source_visuals[src["id"]] = container
    for sensor in config["sensors"]:
        var at: Array = sensor["position"]
        var pillar := Node3D.new()
        pillar.name = "ProxyReader_" + str(sensor["id"])
        pillar.position = Vector3(float(at[0])+1.2,0,float(at[1])+1.2)
        add_child(pillar)
        _box(pillar,"ReferencePillar",Vector3(0,0.40,0),Vector3(.6,.8,.6),Color(0.20,0.29,0.30))
        var gauge: MeshInstance3D = _box(pillar,"ResponseBar",Vector3(0,1.00,0),Vector3(.45,1.00,.45),Color(0.65,.86,.77))
        var label := Label3D.new()
        label.text = str(sensor["id"]).replace("_"," ").to_upper()
        label.font_size = 26
        label.pixel_size = 0.008
        label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        label.position = Vector3(0,2.25,0)
        pillar.add_child(label)
        reader_visuals[sensor["id"]] = gauge
    var cam := Camera3D.new()
    cam.position = Vector3(35,30,43)
    cam.fov = 57
    cam.far = 150
    cam.current = true
    add_child(cam)
    cam.look_at(Vector3(0,0,3))
    var layer := CanvasLayer.new()
    layer.name = "ScientificPhysicalSensorHUD"
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(18,14)
    panel.custom_minimum_size = Vector2(1160,112)
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.07,0.11,0.13,0.96)
    style.set_content_margin_all(14)
    panel.add_theme_stylebox_override("panel",style)
    layer.add_child(panel)
    var stack := VBoxContainer.new()
    panel.add_child(stack)
    title_text = Label.new()
    title_text.text = "ALCHUL / T17 — PHYSICAL SIGNAL → CAUSAL READER → REACTION"
    title_text.add_theme_font_size_override("font_size",21)
    title_text.add_theme_color_override("font_color",Color(0.91,0.72,0.42))
    stack.add_child(title_text)
    audit_text = Label.new()
    audit_text.add_theme_font_size_override("font_size",13)
    audit_text.add_theme_color_override("font_color",Color(0.87,0.93,0.90))
    stack.add_child(audit_text)
    var hint := Label.new()
    hint.text = "1–6 toggle actual source; F tests false alarm; SPACE animate. No verified sensor organ, historical units, or Alchul body."
    hint.add_theme_font_size_override("font_size",13)
    hint.add_theme_color_override("font_color",Color(0.75,0.86,0.82))
    stack.add_child(hint)


func set_source_active(id: String, on: bool) -> bool:
    if not active_sources.has(id):
        return false
    active_sources[id] = on
    if source_visuals.has(id):
        (source_visuals[id] as Node3D).visible = on
    update_readings()
    return true


func _read_sensor(id: String) -> Dictionary:
    for sensor in config.get("sensors", []):
        if sensor["id"] == id:
            return sensor
    return {}


func _readings(sensor_id: String, channel: String, t: float, injected: bool) -> Dictionary:
    if channel not in CHANNELS or not is_finite(t):
        return {}
    var sensor: Dictionary = _read_sensor(sensor_id)
    if sensor.is_empty():
        return {}
    var direct: float = 0.0
    var indirect: float = 0.0
    var contributors: Array[String] = []
    var position: Array = sensor["position"]
    for src in config["sources"]:
        if active_sources.get(src["id"],true) != true:
            continue
        var src_pos: Array = src["position"]
        var distance: float = Vector2(float(position[0]),float(position[1])).distance_to(
            Vector2(float(src_pos[0]),float(src_pos[1])))
        var periodic: float = 0.82 + 0.18 * sin(t * float(src["frequency"]) * TAU + float(src["phase"]))
        var signal: float = float(src["amplitude"]) * exp(-distance / float(src["spread"])) * periodic
        if src["channel"] == channel:
            direct += signal
            contributors.append(str(src["id"]))
        else:
            indirect += signal
    var cross: float = float(sensor["cross_talk"]) * indirect / float(CHANNELS.size())
    var noise: float = float(sensor["noise"]) * sin((t+13.0) *
        float(CHANNELS.find(channel)+2) * 1.73 + float(sensor_id.length()))
    var demo: float = 0.0
    if injected and sensor_id == config["false_positive_demo"]["sensor"] and channel == config["false_positive_demo"]["channel"]:
        demo = float(config["false_positive_demo"]["amplitude"])
    var value: float = clampf(float(sensor["sensitivity"]) * direct + cross + noise + demo,0.0,1.0)
    var detected: bool = value >= float(sensor["threshold"])
    return {"sensor":sensor_id,"channel":channel,"reading_normalized":snappedf(value,.000001),
        "threshold":float(sensor["threshold"]),"detect":detected,
        "source_energy":snappedf(direct,.000001),"matched_sources":contributors,
        "cross_talk":cross,"noise":noise,"demo_injection":demo,
        "false_positive":detected and direct < .05,
        "causal_physics_only":true,"is_Alchul_contact_evidence":false}


func sensor_reading(id: String, channel: String, t: float, demo: bool = false) -> Dictionary:
    return _readings(id,channel,t,demo)


func update_readings() -> Dictionary:
    var reports: Dictionary = {}
    for sensor in config.get("sensors", []):
        var name: String = sensor["id"]
        var strongest: Dictionary = {}
        for channel in CHANNELS:
            var reading: Dictionary = _readings(name,channel,time_sample,demo_false_positive)
            if strongest.is_empty() or float(reading["reading_normalized"]) > float(strongest["reading_normalized"]):
                strongest = reading
        reports[name] = strongest
        var gauge: MeshInstance3D = reader_visuals[name]
        var level: float = float(strongest["reading_normalized"])
        gauge.scale.y = maxf(.10,level*2.0)
        gauge.position.y = .80 + level
        var mat: StandardMaterial3D = gauge.material_override
        mat.albedo_color = Color(0.86,0.53,0.29) if strongest["false_positive"] else (
            Color(0.43,0.90,0.65) if strongest["detect"] else Color(0.45,0.52,0.57))
    last_reports = reports
    if audit_text != null:
        var found: int = 0
        var fakes: int = 0
        for row in reports.values():
            found += int(bool(row["detect"]))
            fakes += int(bool(row["false_positive"]))
        audit_text.text = "%d / 6 source processes enabled   •   %d / 4 strongest channels flagged   •   %d false alarms   •   all units normalized" % [
            active_sources.values().count(true), found, fakes]
    return reports.duplicate(true)


func scientific_summary() -> Dictionary:
    return {"status":STATUS,"sources":active_sources.size(),"readers":reader_visuals.size(),
        "channels":CHANNELS.duplicate(),"reproducible":true,
        "false_positive_supported":true,"real_hardware_receptors":false,
        "evolved_species_organ_verified":false,
        "alchul_measured_signal":false,"actual_physical_units":false,
        "contact_testimony_is_physical_data":false}


func _process(delta: float) -> void:
    if playing:
        time_sample += delta
        update_readings()


func _unhandled_key_input(event: InputEvent) -> void:
    if not(event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5,KEY_6]:
        var idx: int = event.keycode - KEY_1
        var id: String = str(config["sources"][idx]["id"])
        set_source_active(id,not bool(active_sources[id]))
    elif event.keycode == KEY_F:
        demo_false_positive = not demo_false_positive
        update_readings()
    elif event.keycode == KEY_SPACE:
        playing = not playing
