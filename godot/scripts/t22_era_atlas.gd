extends Control
const Registry = preload("res://scripts/t22_era_registry.gd")
var registry = Registry.new()
var selection: OptionButton
var details: Label
var open_button: Button
var earth_only: CheckButton
var selected_id: String = ""
var earth_rows: Array = []
var story_index: int = 0
var earth_index: int = 0

func _ready() -> void:
    var panel := VBoxContainer.new()
    panel.position = Vector2(32,32)
    panel.custom_minimum_size = Vector2(1000,600)
    add_child(panel)
    var heading := Label.new()
    heading.text = "ALCHUL / T22 — ERA BOUNDARIES"
    heading.add_theme_font_size_override("font_size",32)
    panel.add_child(heading)
    earth_only = CheckButton.new()
    earth_only.text = "Earth history only — independent nine-period timeline"
    earth_only.button_pressed = true
    panel.add_child(earth_only)
    selection = OptionButton.new()
    panel.add_child(selection)
    details = Label.new()
    details.custom_minimum_size = Vector2(980,330)
    details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    details.add_theme_font_size_override("font_size",20)
    panel.add_child(details)
    open_button = Button.new()
    panel.add_child(open_button)
    open_button.disabled = true
    if not registry.load_registry():
        details.text = "Registry unavailable. All fictional scenes locked."
        return
    var earth: Variant = JSON.parse_string(FileAccess.get_file_as_string(registry.earth_path()))
    if not earth is Dictionary or not earth.get("eras") is Array or earth["eras"].size() != 9:
        details.text = "Independent Earth timeline unavailable. All scenes locked."
        return
    earth_rows = earth["eras"]
    selection.item_selected.connect(_select)
    earth_only.toggled.connect(_toggle)
    open_button.pressed.connect(_open_selected)
    _toggle(true)

func _toggle(enabled: bool) -> void:
    selection.clear()
    if enabled:
        for row in earth_rows:
            selection.add_item(str(row["name"]))
        _select(earth_index)
    else:
        for row in registry.data["eras"]:
            selection.add_item(str(row["title"]))
        _select(story_index)

func _select(index: int) -> void:
    if index < 0 or index >= selection.item_count:
        return
    selection.select(index)
    if earth_only.button_pressed:
        earth_index = index
        selected_id = str(earth_rows[index]["id"])
    else:
        story_index = index
        selected_id = str(registry.data["eras"][index]["id"])
    _refresh()

func _refresh() -> void:
    if earth_only.button_pressed:
        var row: Dictionary = earth_rows[earth_index]
        var real: Dictionary = row["real_world"]
        details.text = str(row["name"]) + "\n" + str(row["time"]) + "\n\nPUBLISHED EARTH CONTEXT / " + str(real["confidence"]).replace("_"," ") + "\n" + str(real["summary"])
        details.text += "\n\nLIMITS\n" + "\n".join(PackedStringArray(real["limits"]))
        details.text += "\n\nSources: " + str(real["source_urls"][0])
        open_button.text = "Earth history only — no fictional scene"
        open_button.disabled = true
        return
    var row: Dictionary = registry.era(selected_id)
    details.text = str(row["title"]) + "\n" + str(row["chronology"]) + "\n\nEARTH CONTEXT\n" + str(row["earth_context"])
    details.text += "\n\nFICTIONAL ALCHUL OVERLAY\n" + str(row["fiction"]) + "\nScene status: " + str(row["status"])
    open_button.disabled = registry.scene_for(selected_id).is_empty()
    open_button.text = "Scene locked — not built for this era" if open_button.disabled else "Open separate mature-surface study"

func _open_selected() -> void:
    if not earth_only.button_pressed and not open_button.disabled:
        get_tree().change_scene_to_file(registry.scene_for(selected_id))
