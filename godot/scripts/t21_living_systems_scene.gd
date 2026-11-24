extends Node3D

## ALCHUL T21: independently evolved, everyday settlement engineering.
## All numbers are normalized, author-chosen story mechanics; no calibrated hydraulics,
## verified fossil receptors, approved body anatomy, Alchul actuation or recovered history.
const DATA_PATH: String = "res://data/t21_living_systems.json"
const EXPECTED_STATUS: String = "PROVISIONAL_FICTIONAL_SETTLEMENT_NOT_HISTORY_OR_APPROVED_ANATOMY"
const M2_SOURCE: PackedScene = preload("res://assets/m2/ALC_M2_RIVER_STATION_v001.glb")
const T17_PROXY: PackedScene = preload("res://scenes/m11_t17_physical_sensing_lab.tscn")
const METERS: Array[String] = ["pressure","integrity","clarity","nursery","gas","food","materials"]

var config: Dictionary = {}
var state: Dictionary = {}
var turn: int = 0
var uses: Dictionary = {}
var history: Array[Dictionary] = []
var concluded: bool = false
var ending: String = ""
var original_mesh_count: int = 0
var source_span: float = 10.0
var source_center: Vector3 = Vector3.ZERO
var original_scene: Node3D
var proxy: Node3D
var camera: Camera3D
var site_markers: Dictionary = {}
var title_text: Label
var meter_text: Label
var action_text: Label
var event_text: Label
var provenance_text: Label


func _ready() -> void:
    var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
    if not (payload is Dictionary) or payload.get("status","") != EXPECTED_STATUS:
        push_error("T21 living-world contract not found")
        return
    config = payload
    _create_world()
    _place_original_source()
    _add_physical_comparison()
    _build_place_markers()
    _build_hud()
    reset_day()


func _surface(color: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.88
    return m


func _box(parent: Node3D, name: String, at: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    var item := MeshInstance3D.new()
    item.name = name
    item.mesh = mesh
    item.position = at
    item.material_override = _surface(color)
    parent.add_child(item)
    return item


func _create_world() -> void:
    var environment := WorldEnvironment.new()
    var settings := Environment.new()
    settings.background_mode = Environment.BG_COLOR
    settings.background_color = Color(0.11,0.16,0.17)
    settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    settings.ambient_light_color = Color(0.84,0.87,0.80)
    settings.ambient_light_energy = 0.9
    environment.environment = settings
    add_child(environment)
    var sun := DirectionalLight3D.new()
    sun.name = "BraidedReachT21Daylight"
    sun.light_energy = 1.45
    sun.rotation_degrees = Vector3(-46,35,0)
    add_child(sun)
    camera = Camera3D.new()
    camera.name = "T21WorkingSettlementCamera"
    camera.fov = 56.0
    camera.current = true
    add_child(camera)


func _place_original_source() -> void:
    original_scene = M2_SOURCE.instantiate()
    original_scene.name = "OriginalFirstParty_M2_RiverStation"
    add_child(original_scene)
    var bounds := AABB()
    var have_bounds: bool = false
    var base_material := StandardMaterial3D.new()
    base_material.vertex_color_use_as_albedo = true
    base_material.roughness = 0.87
    for child in original_scene.find_children("*", "MeshInstance3D", true, false):
        var mesh: MeshInstance3D = child as MeshInstance3D
        if mesh.mesh == null:
            continue
        original_mesh_count += 1
        mesh.material_override = base_material
        var aabb: AABB = mesh.mesh.get_aabb()
        for x in [aabb.position.x,aabb.end.x]:
            for y in [aabb.position.y,aabb.end.y]:
                for z in [aabb.position.z,aabb.end.z]:
                    var loc: Vector3 = mesh.global_transform * Vector3(x,y,z)
                    if not have_bounds:
                        bounds = AABB(loc,Vector3.ZERO)
                        have_bounds = true
                    else:
                        bounds = bounds.expand(loc)
    if not have_bounds:
        push_error("T21 could not find original source triangles in M2")
        return
    source_span = maxf(8.0,bounds.size.length())
    source_center = bounds.get_center()
    camera.position = source_center + Vector3(source_span*0.63,source_span*0.56,source_span*0.86)
    camera.far = maxf(1200.0,source_span*5.0)
    camera.look_at(source_center)
    camera.make_current()


func _add_physical_comparison() -> void:
    # This existing T17 reference is independent of the authored eight-watch hydraulic
    # state. It is a **comparison** only, not a calibrated measurement of this game.
    proxy = T17_PROXY.instantiate()
    proxy.name = "T17IndependentOrdinaryPhysicalProxy_NotSyncedToGameplay"
    add_child(proxy)
    proxy.visible = false
    var proxy_hud: CanvasLayer = proxy.get_node_or_null("ScientificPhysicalSensorHUD")
    if proxy_hud != null:
        proxy_hud.visible = false
    var proxy_camera: Camera3D = proxy.get_node_or_null("Camera3D")
    if proxy_camera != null:
        proxy_camera.current = false
    camera.make_current()


func _build_place_markers() -> void:
    # Markers are an interpretive inset overlay; not original imported structures or
    # architecture scaled against approved species morphometrics.
    var board := Node3D.new()
    board.name = "FourResponsibilityStations_InterpretiveInserts"
    add_child(board)
    board.position = source_center
    board.scale = Vector3.ONE * clampf(source_span*0.027,0.8,5.2)
    var tint_by_place: Dictionary = {
        "bank":Color(0.37,0.68,0.84),
        "nursery":Color(0.85,0.66,0.43),
        "culture":Color(0.43,0.77,0.54),
        "workshop":Color(0.78,0.54,0.48)}
    for row in config.get("places",[]):
        var site_id: String = str(row.get("id",""))
        var offset: Array = row.get("visual_offset",[0.0,0.0,0.0])
        var point := Node3D.new()
        point.name = "T21Provisional_" + site_id
        point.position = Vector3(float(offset[0]),float(offset[1]),float(offset[2])) * source_span / board.scale.x
        board.add_child(point)
        _box(point,"WorkingSite",Vector3.ZERO,Vector3(1.2,0.32,1.2),tint_by_place[site_id])
        var cap := Label3D.new()
        cap.text = str(row.get("name",""))
        cap.font_size = 23
        cap.pixel_size = 0.009
        cap.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        cap.position = Vector3(0.0,0.85,0.0)
        point.add_child(cap)
        site_markers[site_id] = point


func _label(size: int, tint: Color, width: float) -> Label:
    var item := Label.new()
    item.add_theme_font_size_override("font_size",size)
    item.add_theme_color_override("font_color",tint)
    item.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    item.custom_minimum_size = Vector2(width,0)
    return item


func _panel(layer: CanvasLayer, top_left: Vector2, dimensions: Vector2) -> VBoxContainer:
    var panel := PanelContainer.new()
    panel.position = top_left
    panel.custom_minimum_size = dimensions
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.055,0.11,0.13,0.94)
    style.set_content_margin_all(12)
    panel.add_theme_stylebox_override("panel",style)
    layer.add_child(panel)
    var stack := VBoxContainer.new()
    stack.add_theme_constant_override("separation",6)
    panel.add_child(stack)
    return stack


func _build_hud() -> void:
    var layer := CanvasLayer.new()
    layer.name = "T21LivingCivilizationWorkingHUD"
    add_child(layer)
    var top := _panel(layer,Vector2(18,15),Vector2(1210,146))
    title_text = _label(23,Color(0.94,0.76,0.46),1140)
    meter_text = _label(16,Color(0.88,0.95,0.88),1140)
    provenance_text = _label(12,Color(0.74,0.84,0.80),1140)
    top.add_child(title_text)
    top.add_child(meter_text)
    top.add_child(provenance_text)

    var bottom := _panel(layer,Vector2(18,522),Vector2(1210,179))
    action_text = _label(16,Color(0.92,0.82,0.63),1140)
    event_text = _label(14,Color(0.85,0.93,0.89),1140)
    bottom.add_child(action_text)
    bottom.add_child(event_text)


func _action(id: String) -> Dictionary:
    for item in config.get("actions",[]):
        if item.get("id","") == id:
            return item
    return {}


func reset_day() -> void:
    if config.is_empty():
        return
    state = config.get("initial_state",{}).duplicate(true)
    turn = 0
    uses.clear()
    history.clear()
    concluded = false
    ending = ""
    _update_hud()


func take_action(id: String) -> bool:
    if concluded or config.is_empty():
        return false
    var chosen: Dictionary = _action(id)
    if chosen.is_empty():
        return false
    if int(uses.get(id,0)) >= int(chosen.get("max_uses",1)):
        return false
    var effects: Dictionary = chosen.get("effects",{})
    if float(state.get("materials",0.0)) + float(effects.get("materials",0.0)) < 0.0:
        return false

    for key in effects.keys():
        var old_value: float = float(state.get(key,0.0))
        state[key] = clampf(old_value + float(effects[key]),0.0,100.0)
    if id == "brace" and float(state.get("record",0.0)) >= 1.0:
        state["integrity"] = clampf(float(state["integrity"])+5.0,0.0,100.0)
    for field in chosen.get("set_true",[]):
        state[str(field)] = true
    uses[id] = int(uses.get(id,0))+1
    _end_watch(id,str(chosen.get("description","")))
    return true


func wait_watch() -> bool:
    if concluded or config.is_empty():
        return false
    _end_watch("wait","Necessary work continues elsewhere; delay is not free.")
    return true


func _end_watch(id: String, explanation: String) -> void:
    # Authored ordinary physical and logistical pressures only.
    # These units are not real hydrogeology, clinical thresholds or fossil data.
    turn += 1
    var drift: Dictionary = config.get("drift",{})
    state["pressure"] = clampf(float(state["pressure"])+float(drift["pressure"]),0.0,120.0)
    state["gas"] = clampf(float(state["gas"])+float(drift["gas"]),0.0,110.0)
    state["nursery"] = clampf(float(state["nursery"])+float(drift["nursery"]),0.0,100.0)
    state["food"] = clampf(float(state["food"])+float(drift["food"]),0.0,100.0)
    var clarity_cost: float = float(drift["clarity_base"])
    if float(state["pressure"]) >= 70.0:
        clarity_cost += float(drift["clarity_high_pressure_extra"])
    state["clarity"] = clampf(float(state["clarity"])+clarity_cost,0.0,100.0)
    var excess: float = maxf(0.0,float(state["pressure"])-60.0)
    state["integrity"] = clampf(float(state["integrity"]) -
        excess*float(drift["bank_damage_per_pressure_above_60"]),0.0,100.0)
    if float(state["gas"]) > 65.0:
        state["nursery"] = maxf(0.0,float(state["nursery"])+float(drift["nursery_high_gas_extra"]))
    if float(state["clarity"]) < 45.0:
        state["food"] = maxf(0.0,float(state["food"])+float(drift["food_low_clarity_extra"]))
    history.append({"watch":turn,"action":id,"consequence":explanation,"state":state.duplicate(true)})

    var terminal: Dictionary = config.get("terminal",{})
    if float(state["pressure"]) >= float(terminal["pressure_over"]) or (
        float(state["integrity"]) <= float(terminal["integrity_below"])) or (
        float(state["gas"]) >= float(terminal["gas_over"])) or (
        float(state["nursery"]) <= float(terminal["nursery_below"])):
        concluded = true
        ending = "CRITICAL LOSS — the settlement's interdependent protections did not hold."
    elif turn >= int(config.get("max_watches",8)):
        concluded = true
        if _all_systems_safe():
            ending = "PROTECTED, AT A COST — the nursery and community hold; destroyed cultures and consumed labor remain real losses."
        else:
            ending = "INCOMPLETE — something survived, but the river, air, food or safe route still fails the collective duty."
    _update_hud()


func _all_systems_safe() -> bool:
    var bounds: Dictionary = config.get("bands",{})
    return (
        float(state["pressure"]) <= float(bounds["pressure_max"])
        and float(state["integrity"]) >= float(bounds["integrity_min"])
        and float(state["clarity"]) >= float(bounds["clarity_min"])
        and float(state["nursery"]) >= float(bounds["nursery_min"])
        and float(state["gas"]) <= float(bounds["gas_max"])
        and float(state["food"]) >= float(bounds["food_min"])
        and bool(state["route_safe"]) == bool(bounds["route_safe"])
    )


func _update_hud() -> void:
    if title_text == null or config.is_empty():
        return
    title_text.text = "ALCHUL  /  T21 — THE LIVING CIVILIZATION  |  WATCH %d / %d" % [turn,int(config["max_watches"])]
    meter_text.text = "BANK %.0f  •  LOAD %.0f  |  WATER %.0f  •  NURSERY %.0f  |  GAS %.0f  •  STORES %.0f  |  MATERIAL %.0f  •  SAFE ROUTE %s" % [
        float(state["integrity"]),float(state["pressure"]),float(state["clarity"]),float(state["nursery"]),
        float(state["gas"]),float(state["food"]),float(state["materials"]),
        ("YES" if bool(state["route_safe"]) else "NO")]
    provenance_text.text = "Dimensionless story trade-offs. Original M2 geometry; T17 proxy shown for comparison only. No approved body or exceptional matter control."
    action_text.text = "1 Survey  |  2 Brace  |  3 Relief  |  4 Screen  |  5 Vent  |  6 Warm  |  7 Save food  |  8 Check route  |  SPACE Wait  |  R Reset"
    if concluded:
        event_text.text = ending + "   |   R to replay with another strategy."
    elif history.is_empty():
        event_text.text = "Four living workplaces share one vulnerable riverbank. Every action costs a watch; every successful repair creates a cost elsewhere."
    else:
        var latest: Dictionary = history.back()
        event_text.text = "Watch %d: %s" % [turn,str(latest["consequence"])]
    var score: Dictionary = {"bank":float(state["integrity"]),"nursery":float(state["nursery"]),
        "culture":float(state["food"]),"workshop":100.0-float(state["gas"])}
    for site in site_markers:
        var node: Node3D = site_markers[site]
        node.scale.y = clampf(float(score[site])/100.0,0.35,1.2)


func snapshot() -> Dictionary:
    return {
        "status":config.get("status",""),
        "turn":turn,
        "max_watches":int(config.get("max_watches",0)),
        "state":state.duplicate(true),
        "history":history.duplicate(true),
        "concluded":concluded,
        "ending":ending,
        "all_systems_safe":_all_systems_safe() if not config.is_empty() else false,
        "original_first_party_source":original_mesh_count > 0,
        "original_mesh_count":original_mesh_count,
        "t17_proxy_available":proxy != null and proxy.has_method("sensor_reading"),
        "visual_place_markers":site_markers.size(),
        "anatomy_approved":false,
        "alchul_gave_inventions":false,
        "calibrated_hydraulics":false,
        "human_archaeological_evidence":false,
        "public_chapter_modified":false}


func _unhandled_key_input(event: InputEvent) -> void:
    if not(event is InputEventKey) or not event.pressed or event.echo:
        return
    if event.keycode >= KEY_1 and event.keycode <= KEY_8:
        var i: int = int(event.keycode)-int(KEY_1)
        var choices: Array = config.get("actions",[])
        if i >= 0 and i < choices.size():
            take_action(str(choices[i]["id"]))
    elif event.keycode == KEY_SPACE:
        wait_watch()
    elif event.keycode == KEY_R:
        reset_day()
