extends RefCounted
const PATH: String = "res://data/t22_era_registry.json"
const EARTH_PATH: String = "res://data/m11_t12_real_earth_timeline.json"
const SURFACE_SCENE: String = "res://scenes/t21_p9_integrated_settlement.tscn"
const ERA_IDS: Array[String] = ["mature_surface","first_below","long_descent","kpg_aftermath","modern_new_madrid"]
const DENIED: Array[String] = ["approved_anatomy","surface_rig_as_modern_body","alchul_actuation","fiction_as_earth_evidence","modern_fault_as_ancient_cave","calibrated_physics"]
const FEATURES: Dictionary = {"mature_surface":["surface_m2","root_craft","culture_stores","late_egg_development","season_record"],
    "first_below":["first_below_trials"],"long_descent":["staged_descent"],"kpg_aftermath":["fictional_deep_survival"],
    "modern_new_madrid":["fictional_modern_civilization"]}
var data: Dictionary = {}

func load_registry() -> bool:
    data.clear()
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
    if not parsed is Dictionary:
        return false
    if parsed.get("schema") != "alchul.t22.era_registry.v1" or parsed.get("status") != "FICTIONAL_OVERLAY_SEPARATE_FROM_EARTH":
        return false
    if parsed.get("earth_index") != EARTH_PATH or not parsed.get("eras") is Array or parsed["eras"].size() != ERA_IDS.size():
        return false
    for i in range(ERA_IDS.size()):
        var row: Variant = parsed["eras"][i]
        if not row is Dictionary or row.get("id") != ERA_IDS[i] or row.get("features") != FEATURES[ERA_IDS[i]]:
            return false
        if i == 0:
            if row.get("scene") != SURFACE_SCENE or row.get("status") != "prototype":
                return false
        elif row.get("scene") != null or row.get("status") != "unbuilt":
            return false
    if parsed.get("global_denials") != Array(DENIED):
        return false
    data = parsed
    return true

func era(id: String) -> Dictionary:
    for row in data.get("eras", []):
        if row.get("id") == id:
            return row.duplicate(true)
    return {}

func allows(id: String, feature: String) -> bool:
    var row: Dictionary = era(id)
    return not row.is_empty() and not feature in DENIED and feature in FEATURES.get(id,[]) and feature in row.get("features", [])

func scene_for(id: String) -> String:
    var row: Dictionary = era(id)
    if id != "mature_surface" or row.get("status") != "prototype" or row.get("scene") != SURFACE_SCENE:
        return ""
    return SURFACE_SCENE

func earth_path() -> String:
    return EARTH_PATH if not data.is_empty() else ""
