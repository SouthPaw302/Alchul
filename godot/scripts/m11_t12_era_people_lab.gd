extends Node2D

## T12 native study atlas, NOT Chapter I and NOT actual anatomy.
## Earth history and hypothetical ALCHUL people must remain separate views.
const EARTH_PATH: String = "res://data/m11_t12_real_earth_timeline.json"
const PEOPLE_PATH: String = "res://data/m11_t12_inhabitant_candidates.json"
const SCIENCE_STATUS: String = "science_history_grounded_fiction_layer_explicit"

var earth: Dictionary = {}
var people: Dictionary = {}
var view: String = "real_earth"
var era_index: int = 8
var role_index: int = 0


func _read_dictionary(path: String) -> Dictionary:
    var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(parsed) != TYPE_DICTIONARY:
        push_error("T12 missing native registry: " + path)
        return {}
    return parsed


func _ready() -> void:
    earth = _read_dictionary(EARTH_PATH)
    people = _read_dictionary(PEOPLE_PATH)
    if earth.get("version", "") != "t12_real_earth_v1":
        push_error("T12 Earth-science version invalid")
        return
    if people.get("schema_version", "") != "m11_t12_people_v1":
        push_error("T12 people register version invalid")
        return
    if not bool(earth.get("authority_policy", {}).get("real_science_precedes_story", false)):
        push_error("T12 cannot render fictional claims as Earth history")
        return
    queue_redraw()


func set_view(next_view: String) -> bool:
    if next_view not in ["real_earth", "surface_candidates"]:
        return false
    view = next_view
    queue_redraw()
    return true


func select_era(index: int) -> bool:
    var eras: Array = earth.get("eras", [])
    if index < 0 or index >= eras.size():
        return false
    era_index = index
    queue_redraw()
    return true


func select_role(key: String) -> bool:
    var roles: Array = people.get("roles", [])
    for i in range(roles.size()):
        if str(roles[i].get("id", "")) == key:
            role_index = i
            queue_redraw()
            return true
    return false


func summary() -> Dictionary:
    var eras: Array = earth.get("eras", [])
    var roster: Array = people.get("roles", [])
    var era: Dictionary = eras[clampi(era_index, 0, maxi(0, eras.size() - 1))] if not eras.is_empty() else {}
    var profile: Dictionary = roster[clampi(role_index, 0, maxi(0, roster.size() - 1))] if not roster.is_empty() else {}
    return {
        "status": SCIENCE_STATUS,
        "view": view,
        "era_count": eras.size(),
        "role_count": roster.size(),
        "selected_era": str(era.get("id", "")),
        "selected_role": str(profile.get("id", "")),
        "present_intraplate": bool(earth.get("authority_policy", {}).get("correct_intraplate_tectonics", false)),
        "modern_body_reconstructed": bool(earth.get("authority_policy", {}).get("modern_alchul_body_reconstructed", true)),
        "nonavian_survival_established": bool(earth.get("authority_policy", {}).get("surviving_non_avian_dinosaurs_claimed", true)),
        "biology_approved": people.get("biological_approval", "") == "approved",
        "timeline_reaches_present": str(eras[eras.size() - 1].get("time", "")) == "2026 CE" if not eras.is_empty() else false,
        "selected_role_era_scope": str(people.get("selected_era_scope", "")),
        "fiction_is_real_world_observation": false
    }


func _label(point: Vector2, content: String, font_size: int = 15,
        pigment: Color = Color(0.18, 0.23, 0.26)) -> void:
    draw_string(ThemeDB.fallback_font, point, content, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, pigment)


func _lines(content: String, limit: int) -> Array[String]:
    var output: Array[String] = []
    var current: String = ""
    for word in content.split(" ", false):
        if current.is_empty():
            current = word
        elif current.length() + 1 + word.length() <= limit:
            current += " " + word
        else:
            output.append(current)
            current = word
    if not current.is_empty():
        output.append(current)
    return output


func _paragraph(point: Vector2, content: String, char_width: int, max_lines: int,
        ink: Color = Color(0.20, 0.26, 0.27), size: int = 15) -> void:
    var wrapped: Array[String] = _lines(content, char_width)
    for i in range(mini(max_lines, wrapped.size())):
        _label(point + Vector2(0, i * 22), wrapped[i], size, ink)


func _header() -> void:
    draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.971, 0.966, 0.944))
    _label(Vector2(24, 40), "ALCHUL  |  T12 SCIENCE-FIRST EARTH / RESIDENT STUDY", 24)
    _label(Vector2(24, 68),
        "REAL HISTORICAL EVIDENCE stays separate from STORY and UNSOLVED survivor biology.", 15,
        Color(0.59, 0.30, 0.25))
    var left_active: bool = view == "real_earth"
    draw_rect(Rect2(Vector2(22, 82), Vector2(240, 36)),
        Color(0.77, 0.87, 0.84) if left_active else Color(0.90, 0.91, 0.88))
    draw_rect(Rect2(Vector2(267, 82), Vector2(278, 36)),
        Color(0.77, 0.87, 0.84) if not left_active else Color(0.90, 0.91, 0.88))
    _label(Vector2(32, 107), "R  /  REAL EARTH", 16)
    _label(Vector2(277, 107), "P  /  PROVISIONAL PEOPLE", 16)


func _draw_earth() -> void:
    var eras: Array = earth.get("eras", [])
    _label(Vector2(25, 150), "REGIONAL HISTORY TO PRESENT   (not to scale)", 17)
    for i in range(eras.size()):
        var y: float = 163.0 + i * 51.0
        var era: Dictionary = eras[i]
        var selected: bool = i == era_index
        draw_rect(Rect2(Vector2(20, y), Vector2(382, 47)),
            Color(0.79, 0.87, 0.85) if selected else Color(0.91, 0.92, 0.89))
        _label(Vector2(32, y + 19), "%d  %s" % [i + 1, str(era.get("name", ""))], 16)
        _label(Vector2(33, y + 38), str(era.get("time", "")), 12, Color(0.36, 0.43, 0.44))
    var active: Dictionary = eras[clampi(era_index, 0, eras.size() - 1)]
    var true_world: Dictionary = active.get("real_world", {})
    var story: Dictionary = active.get("fiction", {})
    draw_rect(Rect2(Vector2(426, 154), Vector2(828, 486)), Color(0.93, 0.94, 0.91))
    _label(Vector2(444, 184), "REAL HISTORY   /   %s" % str(active.get("name", "")), 19)
    _paragraph(Vector2(446, 219), str(true_world.get("summary", "")), 79, 4)
    _label(Vector2(446, 328), "EVIDENCE BOUNDARIES", 16)
    var limits: Array = true_world.get("limits", [])
    if not limits.is_empty():
        _paragraph(Vector2(446, 353), str(limits[0]), 81, 3, Color(0.40, 0.31, 0.25), 14)
    draw_line(Vector2(443, 432), Vector2(1232, 432), Color(0.69, 0.73, 0.71), 2)
    _label(Vector2(446, 460), "FICTIONAL OVERLAY — NEVER FOSSIL EVIDENCE", 16,
        Color(0.61, 0.30, 0.23))
    _paragraph(Vector2(446, 487), str(story.get("summary", "")), 81, 5)
    _label(Vector2(446, 602), "Status: " + str(story.get("status", "")), 13)
    _label(Vector2(27, 673), "REAL SCIENCE: regional limits / stratigraphy / Earth history; not a precise site.", 15)
    _label(Vector2(27, 701), "1–9: era   |   LEFT/RIGHT: chronology   |   P: six provisional surface individuals", 14)


func _draw_role_glyph(point: Vector2, marker: String, tint: Color) -> void:
    # Abstract task topology, NOT fossil morphology, no real biological size.
    draw_circle(point + Vector2(34, 27), 23, Color(0.88, 0.91, 0.88))
    draw_line(point + Vector2(19, 38), point + Vector2(39, 21), tint, 3.5, true)
    for dx in [-13.0, 0.0, 13.0]:
        draw_line(point + Vector2(39, 21), point + Vector2(53 + dx * .45, 6), tint, 2.5, true)
    if marker == "water":
        draw_line(point + Vector2(4, 60), point + Vector2(65, 60), tint, 2, true)
    elif marker == "compare":
        draw_circle(point + Vector2(65, 52), 4.5, tint)
    elif marker == "burden":
        draw_circle(point + Vector2(63, 51), 7, tint)
    elif marker == "learning":
        draw_circle(point + Vector2(62, 45), 4, tint)
        draw_circle(point + Vector2(76, 52), 3, tint)
    elif marker == "nest":
        draw_arc(point + Vector2(65, 52), 13, 0.15, PI - 0.15, 20, tint, 2, true)
    elif marker == "harvest":
        draw_rect(Rect2(point + Vector2(56, 43), Vector2(15, 18)), tint, false, 2)


func _draw_people() -> void:
    var roster: Array = people.get("roles", [])
    _label(Vector2(26, 143), "SIX INDEPENDENT STUDY INDIVIDUALS — PRE-K–Pg SURFACE, EXACT AGE UNDECIDED", 17)
    for i in range(roster.size()):
        var profile: Dictionary = roster[i]
        var col: int = i % 3
        var line: int = i / 3
        var x: float = 26.0 + col * 414.0
        var y: float = 161.0 + line * 230.0
        var selected: bool = i == role_index
        draw_rect(Rect2(Vector2(x, y), Vector2(395, 215)),
            Color(0.81, 0.89, 0.86) if selected else Color(0.91, 0.92, 0.88))
        _draw_role_glyph(Vector2(x + 10, y + 43), str(profile.get("render_marker", "")),
            Color(0.19, 0.43, 0.42) if selected else Color(0.41, 0.48, 0.45))
        _label(Vector2(x + 19, y + 27), "%d. %s" % [i + 1, str(profile.get("title", ""))], 18)
        _label(Vector2(x + 111, y + 77), "Stage: " + str(profile.get("life_stage", "")), 14)
        _label(Vector2(x + 111, y + 98), "UNAPPROVED anatomy", 13, Color(0.61, 0.29, 0.23))
        _paragraph(Vector2(x + 17, y + 128), str(profile.get("activity", "")), 43, 4,
            Color(0.28, 0.32, 0.32), 13)
    var selected_person: Dictionary = roster[clampi(role_index, 0, roster.size() - 1)]
    _label(Vector2(28, 655), "Selected study: %s  |  %s" % [
        str(selected_person.get("title", "")), str(selected_person.get("environments", []))], 15)
    _label(Vector2(28, 681), "Markers encode research tasks, NOT body shape, sex, caste or modern descendants.", 14,
        Color(0.59, 0.30, 0.25))
    _label(Vector2(28, 705), "1–6: individual   |   R: return to real-Earth timeline   |   H-A/H-B both UNAPPROVED", 13)


func _draw() -> void:
    if earth.is_empty() or people.is_empty():
        return
    _header()
    if view == "real_earth":
        _draw_earth()
    else:
        _draw_people()


func _unhandled_key_input(event: InputEvent) -> void:
    if not (event is InputEventKey):
        return
    var key: InputEventKey = event as InputEventKey
    if not key.pressed or key.echo:
        return
    match key.keycode:
        KEY_R:
            set_view("real_earth")
        KEY_P:
            set_view("surface_candidates")
        KEY_LEFT:
            if view == "real_earth":
                select_era(maxi(0, era_index - 1))
        KEY_RIGHT:
            if view == "real_earth":
                select_era(mini(8, era_index + 1))
        _:
            if key.keycode >= KEY_1 and key.keycode <= KEY_9:
                var selected: int = key.keycode - KEY_1
                if view == "real_earth":
                    select_era(selected)
                elif selected < 6:
                    role_index = selected
                    queue_redraw()
