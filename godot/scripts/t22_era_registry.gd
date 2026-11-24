extends RefCounted
const PATH: String = "res://data/t22_era_registry.json"
var data: Dictionary = {}

func load_registry() -> bool:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
    if not parsed is Dictionary:
        return false
    data = parsed
    return data.get("schema") == "alchul.t22.era_registry.v1" and data.get("status") == "FICTIONAL_OVERLAY_SEPARATE_FROM_EARTH"

func era(id: String) -> Dictionary:
    for row in data.get("eras", []):
        if row.get("id") == id:
            return row.duplicate(true)
    return {}

func allows(id: String, feature: String) -> bool:
    var row: Dictionary = era(id)
    return not row.is_empty() and not feature in data.get("global_denials", []) and feature in row.get("features", [])

func scene_for(id: String) -> String:
    var row: Dictionary = era(id)
    if row.get("status") != "prototype" or not row.get("scene") is String:
        return ""
    return str(row["scene"])

func earth_path() -> String:
    return str(data.get("earth_index", ""))
