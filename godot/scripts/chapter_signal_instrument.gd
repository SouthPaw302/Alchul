extends VBoxContainer

## Chapter I: an interactive, explicitly illustrative *paired physical control*.
## No units, not a scientific sensor; cannot prove Alchul/ESP or dinosaur physiology.
signal reading_confirmed(site_id: String, normalized_strength: float)

const PROFILES: Dictionary = {
    "bank":{"center":0.27, "title":"River margin", "cue":"Compare moving-bank vibration against the upstream reference.", "ref":"Still bank / active edge"},
    "nursery":{"center":0.71, "title":"Nursery route", "cue":"Compare the sheltered passage's air motion with the open approach.", "ref":"Outside air / sheltered route"},
    "harvest":{"center":0.47, "title":"Harvest work", "cue":"Compare an inactive preparation vessel with the working site.", "ref":"Unused vessel / active preparation"},
    "witness":{"center":0.84, "title":"Witness circle", "cue":"Compare two substrate points. The testimony is NOT a measured signal.", "ref":"Control stone / comparison stone"}
}
const GOLD: Color = Color(0.93, 0.74, 0.48)
const PALE: Color = Color(0.90, 0.95, 0.91)
const QUIET: Color = Color(0.48, 0.68, 0.70)
var site_id: String = ""
var tuning: float = 0.5
var data_ready: bool = false
var locked: bool = false
var graph: Control
var readout: Label
var feedback: Label
var capture_button: Button
var dial: HSlider
var _phase: float = 0.0


func _label(words: String, size: int, tint: Color) -> Label:
    var label := Label.new()
    label.text = words
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", tint)
    return label


func configure(key: String, recorded: bool = false) -> bool:
    if not PROFILES.has(key):
        return false
    site_id = key
    locked = recorded
    data_ready = false
    tuning = 0.5
    if is_node_ready():
        _rebuild()
    return true


func _ready() -> void:
    add_theme_constant_override("separation", 9)
    if not site_id.is_empty():
        _rebuild()


func _rebuild() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()
    var profile: Dictionary = PROFILES[site_id]
    add_child(_label("FIELD INSTRUMENT  /  PAIRED CONTROL", 18, GOLD))
    add_child(_label(str(profile["cue"]), 14, PALE))
    add_child(_label(str(profile["ref"]) + "  ·  normalized display, NOT physical units", 13, QUIET))
    graph = Control.new()
    graph.name = "PairedTraces"
    graph.custom_minimum_size = Vector2(560, 140)
    graph.draw.connect(_draw_graph)
    add_child(graph)
    add_child(_label("TUNE TO THE STRONGEST REPEATABLE DIFFERENCE", 13, GOLD))
    dial = HSlider.new()
    dial.name = "FrequencyDial"
    dial.min_value = 0.0
    dial.max_value = 1.0
    dial.step = 0.01
    dial.value = tuning
    dial.value_changed.connect(_on_tune)
    add_child(dial)
    readout = _label("", 15, PALE)
    readout.name = "StrengthReadout"
    add_child(readout)
    feedback = _label("", 13, QUIET)
    feedback.name = "ScientificCaution"
    add_child(feedback)
    capture_button = Button.new()
    capture_button.name = "RecordPairedReading"
    capture_button.custom_minimum_size = Vector2(260, 40)
    capture_button.text = "Record independent comparison"
    capture_button.pressed.connect(_capture)
    add_child(capture_button)
    _refresh()


func differential(at_value: float) -> float:
    if not PROFILES.has(site_id) or not is_finite(at_value):
        return 0.0
    var target: float = float(PROFILES[site_id]["center"])
    var delta: float = (at_value - target) / 0.125
    return 0.03 + 0.93 * exp(-delta * delta)


func _on_tune(value: float) -> void:
    if locked:
        return
    tuning = clampf(value, 0.0, 1.0)
    data_ready = true
    _refresh()


func _refresh() -> void:
    if readout == null or feedback == null or capture_button == null:
        return
    var strength: float = differential(tuning)
    readout.text = "Relative difference: %d%%    |    Dial: %d/100" % [roundi(strength * 100.0), roundi(tuning * 100.0)]
    feedback.text = ("Archived paired control. Repeatable in the prototype; historical mechanism unverified."
        if locked else "Compare the blue baseline and gold condition. This is a visual teaching model, not recovered data.")
    capture_button.disabled = locked or not data_ready or strength < 0.80
    capture_button.text = "Comparison archived" if locked else ("Tune closer before recording" if capture_button.disabled else "Record independent comparison")
    if graph != null:
        graph.queue_redraw()


func _capture() -> bool:
    if locked or not data_ready or differential(tuning) < 0.80:
        return false
    locked = true
    _refresh()
    reading_confirmed.emit(site_id, differential(tuning))
    return true


func _process(delta: float) -> void:
    if is_visible_in_tree() and graph != null:
        _phase += delta * 0.5
        graph.queue_redraw()


func _draw_graph() -> void:
    if graph == null:
        return
    var rect := Rect2(Vector2.ZERO, graph.size)
    graph.draw_rect(rect, Color(0.065, 0.13, 0.145, 1.0), true)
    for k in range(1, 5):
        var xx: float = rect.size.x * float(k) / 5.0
        graph.draw_line(Vector2(xx, 0), Vector2(xx, rect.size.y), Color(0.27, 0.37, 0.37, 0.35), 1.0)
    graph.draw_line(Vector2(0, rect.size.y * 0.5), Vector2(rect.size.x, rect.size.y * 0.5), Color(0.60, 0.68, 0.66, 0.25), 1.0)
    var quiet_curve := PackedVector2Array()
    var active_curve := PackedVector2Array()
    var difference: float = differential(tuning)
    for i in range(160):
        var s: float = float(i) / 159.0
        var wobble: float = sin(s * TAU * 6.0 + _phase * 0.35) + 0.22 * sin(s * TAU * 15.0)
        var control: float = 0.19 * wobble
        var active: float = control + difference * 0.27 * sin(s * TAU * 3.3 + _phase * 0.2)
        quiet_curve.append(Vector2(s * rect.size.x, rect.size.y * (0.5 - control)))
        active_curve.append(Vector2(s * rect.size.x, rect.size.y * (0.5 - active)))
    graph.draw_polyline(quiet_curve, Color(0.34, 0.69, 0.76), 2.2, true)
    graph.draw_polyline(active_curve, GOLD, 2.6, true)
    graph.draw_rect(rect, Color(0.50, 0.66, 0.61, 0.28), false, 1.0)


func validation_summary() -> Dictionary:
    return {"site":site_id, "status":"illustrative_control_not_science", "locked":locked,
        "peak":differential(float(PROFILES[site_id]["center"])) if PROFILES.has(site_id) else 0.0,
        "off_target":differential(0.0), "has_repeatable_control":true,
        "contact_testimony_as_evidence":false, "has_fictional_units":false}
