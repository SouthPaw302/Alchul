extends "res://scripts/t21_p3_seasonal_terrace.gd"

## T21.4–9: separate provisional mature-surface study.
var phase_water: MeshInstance3D
var crop_shoots: Array[MeshInstance3D] = []
var repair_strips: Array[MeshInstance3D] = []
var care_tokens: Array[MeshInstance3D] = []
var learning_tokens: Array[MeshInstance3D] = []
var review_choice: String = ""
var ambience: AudioStreamPlayer
var ambiance_enabled: bool = false
var sun_light: DirectionalLight3D

func _ready() -> void:
    super._ready()
    var bank: Node3D = process_nodes["bank"]
    phase_water = _box(bank, "SeasonalWaterIndex_NotFluidModel", Vector3(0,0.23,-0.28),
        Vector3(3.02,0.055,0.79), WATER)
    phase_water.visible = false
    var culture: Node3D = process_nodes["culture"]
    var nursery: Node3D = process_nodes["nursery"]
    for i in range(6):
        var x: float = -1.25+float(i)*0.50
        var shoot: MeshInstance3D = _cylinder(culture, "CultivationStage_%02d" % i,
            Vector3(x,0.43,1.18),0.06,0.60,REED)
        crop_shoots.append(shoot)
        repair_strips.append(_timber(bank, "MaintenanceReserve_%02d" % i,
            Vector3(x,0.32,1.08),Vector3(x,0.98,1.19),0.045,PALE))
        care_tokens.append(_box(nursery, "CareDutyReserve_%02d" % i,
            Vector3(x,0.31,1.12),Vector3(0.24,0.20,0.18),WARM))
        learning_tokens.append(_box(ledger_shelf, "SharedTeachingRecord_%02d" % i,
            Vector3(x,0.53,3.41),Vector3(0.19,0.12,0.12),PALE))
    for group in [crop_shoots,repair_strips,care_tokens,learning_tokens]:
        for token in group:
            token.visible = false
    _build_ambience()
    _update_hud()

func _build_ambience() -> void:
    # Original synthesized abstract water/resonance bed; not a recovered voice.
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = 22050
    stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
    var count: int = 44100
    stream.loop_end = count
    var samples := PackedByteArray()
    samples.resize(count*2)
    for i in range(count):
        var t: float = float(i)/22050.0
        var envelope: float = 0.55+0.30*sin(TAU*0.5*t)
        var signal_value: float = envelope*(sin(TAU*53.0*t)*0.38+sin(TAU*97.0*t)*0.15+sin(TAU*211.0*t)*0.06)
        samples.encode_s16(i*2,roundi(signal_value*2400.0))
    stream.data = samples
    ambience = AudioStreamPlayer.new()
    ambience.name = "OriginalAbstractResonance_NotSpeciesVoice"
    ambience.stream = stream
    ambience.volume_db = -18.0
    add_child(ambience)

func toggle_ambience() -> void:
    if ambience == null:
        return
    ambiance_enabled = not ambiance_enabled
    if ambiance_enabled:
        ambience.play()
    else:
        ambience.stop()
    _update_hud()

func choose_review(id: String) -> bool:
    if not calendar.finished or not review_choice.is_empty():
        return false
    if not id in ["share_record","prioritize_repair","repeat_study"]:
        return false
    review_choice = id
    _update_hud()
    return true

func reset_day() -> void:
    review_choice = ""
    super.reset_day()

func _update_hud() -> void:
    super._update_hud()
    if title_text == null or config.is_empty() or phase_water == null:
        return
    title_text.text = title_text.text.replace("T21.3","T21.9")
    action_text.text += " | M Sound"
    if calendar.day == 0:
        phase_water.visible = false
        for group in [crop_shoots,repair_strips,care_tokens,learning_tokens]:
            for token in group:
                token.visible = false
        return
    var phase: int = calendar.phase_index()
    var stock: Dictionary = calendar.resources
    phase_water.visible = true
    phase_water.scale.z = [1.0,0.82,0.48,0.72][phase]
    phase_water.position.y = [0.28,0.25,0.22,0.24][phase]
    phase_water.material_override = _surface(WATER.lerp(CLAY, [0.30,0.05,0.15,0.22][phase]))
    for i in range(6):
        crop_shoots[i].visible = i < int(ceil(float(stock["food"])/2.0))
        crop_shoots[i].scale.y = [0.55,1.0,0.70,0.50][phase]
        repair_strips[i].visible = i < int(ceil(float(stock["repair"])/2.0))
        care_tokens[i].visible = i < int(ceil(float(stock["care"])/2.0))
        learning_tokens[i].visible = i < int(stock["knowledge"])
    provenance_text.text = "Mature surface only | qualitative resource markers, not calibrated ecology | sound is an abstract study"
    if calendar.finished:
        action_text.text = "J Share record | K Prioritize repair | L Repeat study | R Restart | M Sound"
        event_text.text = "Season complete. Choose a recommendation; it cannot erase unmet needs." if review_choice.is_empty() else "Council record: " + review_choice.replace("_"," ") + " | unmet needs: %d" % calendar.deficits

func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_M: toggle_ambience()
        KEY_J: choose_review("share_record")
        KEY_K: choose_review("prioritize_repair")
        KEY_L: choose_review("repeat_study")
        _: super._unhandled_key_input(event)

func integration_report() -> Dictionary:
    return {"era":"mature_surface","fictional":true,"calendar":calendar.report(),
        "review_choice":review_choice,"sound_enabled":ambiance_enabled,
        "visible_crops":_visible_count(crop_shoots),"visible_repairs":_visible_count(repair_strips),
        "visible_care":_visible_count(care_tokens),"visible_learning":_visible_count(learning_tokens),
        "water_visible":phase_water.visible,"water_width":phase_water.scale.z,
        "approved_anatomy":false,"calibrated_ecology":false,"public_chapter_modified":false}

func _visible_count(group: Array[MeshInstance3D]) -> int:
    var count: int = 0
    for token in group:
        if token.visible:
            count += 1
    return count
