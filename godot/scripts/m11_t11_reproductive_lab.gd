extends Node2D

## M11 T11: assumption-index chart only. No organs, embryos or biology shown.
## 75% refers to normalized developmental progress, NOT elapsed gestation time.
const CONFIG_PATH: String = "res://data/m11_t11_reproductive_constraints.json"
const RESULTS_PATH: String = "res://data/m11_t11_screening_results.json"
const SCIENCE_STATUS: String = "noncanonical_dimensionless_screening_not_biological_viability"
const KEYS: Array[String] = [
    "reference", "internal_hypoxia", "restrictive_internal_transfer",
    "stagnant_nursery", "excessive_maternal_load",
    "desiccating_nursery", "overheated_nursery"
]

var config: Dictionary = {}
var results: Dictionary = {}
var selected_scenario: String = "reference"


func _load_dictionary(path: String) -> Dictionary:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("T11: missing or bad science data: " + path)
        return {}
    return parsed


func _ready() -> void:
    config = _load_dictionary(CONFIG_PATH)
    results = _load_dictionary(RESULTS_PATH)
    if str(results.get("scientific_status", "")) != SCIENCE_STATUS:
        push_error("T11: result claims unsupported scientific status")
        return
    if str(config.get("scientific_status", "")) != SCIENCE_STATUS:
        push_error("T11: config claims unsupported scientific status")
        return
    if not is_equal_approx(float(config.get("fixed_canon", {}).get("fraction_internal_development", 0)), 0.75):
        push_error("T11: canonical retention fraction changed")
        return
    queue_redraw()


func select_scenario(key: String) -> bool:
    if key not in KEYS or not results.get("scenarios", {}).has(key):
        return false
    selected_scenario = key
    queue_redraw()
    return true


func summary() -> Dictionary:
    var record: Dictionary = results.get("scenarios", {}).get(selected_scenario, {})
    return {
        "status": results.get("scientific_status", ""),
        "scenario": selected_scenario,
        "scenario_count": KEYS.size(),
        "canon_fraction": float(results.get("canon_fraction_internal", 0)),
        "model_units": str(results.get("units", "")),
        "screening_pass": bool(record.get("screening_pass", false)),
        "constraints": record.get("constraints", {}),
        "real_biological_viability_verified": false,
        "embryonic_transfer_organ_known": false,
        "elapsed_time_calculated": false,
        "clutch_size_established": false,
    }


func _label(pos: Vector2, caption: String, size: int = 17, ink: Color = Color(0.14, 0.21, 0.23)) -> void:
    draw_string(ThemeDB.fallback_font, pos, caption, HORIZONTAL_ALIGNMENT_LEFT, -1, size, ink)


func _plot(stage: float, index_value: float) -> Vector2:
    var left: float = 75.0
    var width: float = 850.0
    var bottom: float = 580.0
    var height: float = 390.0
    return Vector2(left + stage * width, bottom - minf(1.65, maxf(0.0, index_value)) / 1.65 * height)


func _draw() -> void:
    if config.is_empty() or results.is_empty():
        return
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.969, 0.962, 0.934))
    _label(Vector2(27, 40), "ALCHUL / M11 T11 - EGG RETENTION CONSTRAINT SCREEN", 25)
    _label(Vector2(27, 69), "NONCANONICAL model: oxygen, burden and nursery indices. NO observed biology.", 15, Color(0.58, 0.27, 0.22))
    var conf: Dictionary = config.get("scenarios", {}).get(selected_scenario, {})
    var model: Dictionary = config.get("model", {})
    var current: Dictionary = results.get("scenarios", {}).get(selected_scenario, {})
    var all_flags: Dictionary = current.get("constraints", {})
    var screen_pass: bool = bool(current.get("screening_pass", false))
    _label(Vector2(77, 113), selected_scenario.replace("_", " ").to_upper(), 22)
    _label(Vector2(77, 140), "SCREENING " + ("PASS" if screen_pass else "FAIL") + " (not biological viability)", 17,
        Color(0.19, 0.45, 0.33) if screen_pass else Color(0.72, 0.28, 0.22))
    var split: float = float(config.get("fixed_canon", {}).get("fraction_internal_development", 0.75))
    draw_rect(Rect2(Vector2(75, 189), Vector2(850.0 * split, 391)), Color(0.91, 0.91, 0.85))
    draw_rect(Rect2(Vector2(75 + 850 * split, 189), Vector2(850.0 * (1.0 - split), 391)), Color(0.87, 0.92, 0.93))
    for y in [0.0, 0.5, 1.0, 1.5]:
        draw_line(_plot(0, y), _plot(1, y), Color(0.76, 0.79, 0.77), 1)
        _label(Vector2(38, _plot(0, y).y + 4), "%.1f" % y, 12)
    var x_boundary: float = _plot(split, 0).x
    draw_line(Vector2(x_boundary, 181), Vector2(x_boundary, 583), Color(0.35, 0.37, 0.38), 2)
    _label(Vector2(84, 177), "INTERNAL DEVELOPMENT", 15)
    _label(Vector2(x_boundary + 12, 177), "EXTERNAL INCUBATION", 13)
    _label(Vector2(x_boundary - 34, 604), "75% laying", 12)
    for k in range(100):
        var t0: float = float(k) / 100.0
        var t1: float = float(k + 1) / 100.0
        var d0: float = float(model.get("relative_demand_at_start", 0.18)) + 0.82 * pow(t0, 2.0)
        var d1: float = float(model.get("relative_demand_at_start", 0.18)) + 0.82 * pow(t1, 2.0)
        draw_line(_plot(t0, d0), _plot(t1, d1), Color(0.69, 0.34, 0.24), 3.0, true)
    var internal_supply: float = float(conf.get("internal_conductance", 0.0)) * float(conf.get("internal_gradient", 0.0))
    var external_supply: float = float(conf.get("external_conductance", 0.0)) * float(conf.get("external_gradient", 0.0)) * float(conf.get("external_ventilation", 0.0))
    draw_line(_plot(0.0, internal_supply), _plot(split, internal_supply), Color(0.21, 0.47, 0.47), 4, true)
    draw_line(_plot(split, external_supply), _plot(1.0, external_supply), Color(0.24, 0.39, 0.61), 4, true)
    _label(Vector2(77, 624), "Stage 0                                               Stage 1 | developmental progress, NOT days", 14)
    _label(Vector2(960, 198), "MODEL-ONLY FLAGS", 16)
    var flags: Array[String] = [
        "internal_oxygen_index", "external_oxygen_index", "maternal_load_index",
        "nursery_moisture_index", "nursery_heat_index"
    ]
    for i in range(flags.size()):
        var flag: String = flags[i]
        var ok: bool = bool(all_flags.get(flag, false))
        _label(Vector2(958, 240 + 55 * i), ("PASS " if ok else "FAIL ") + flag.replace("_index", "").replace("_", " "),
            14, Color(0.18, 0.43, 0.32) if ok else Color(0.70, 0.27, 0.22))
    _label(Vector2(958, 548), "Demand / internal / external", 14)
    _label(Vector2(958, 573), "are UNCALIBRATED indices", 13)
    _label(Vector2(24, 678), "1..7: scenarios | two-phase boundary fixed at 75% development | independent of Chapter I", 16)
    _label(Vector2(24, 704), "No known egg shell, vascular mechanism, clutch, reproductive roles, measured air or thermal ranges.", 14)


func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return
    var press: InputEventKey = event as InputEventKey
    if not press.pressed or press.echo:
        return
    if press.keycode >= KEY_1 and press.keycode <= KEY_7:
        select_scenario(KEYS[press.keycode - KEY_1])
