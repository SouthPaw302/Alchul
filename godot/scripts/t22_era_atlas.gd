extends Control
const Registry = preload("res://scripts/t22_era_registry.gd")
var registry = Registry.new()
var selection: OptionButton
var details: Label
var open_button: Button
var earth_only: CheckButton
var selected_id: String = ""

func _ready() -> void:
    var panel := VBoxContainer.new()
    panel.position = Vector2(32,32)
    panel.custom_minimum_size = Vector2(1000,600)
    add_child(panel)
    var heading := Label.new()
    heading.text = "ALCHUL / T22 — ERA BOUNDARIES"
    heading.add_theme_font_size_override("font_size",32)
    panel.add_child(heading)
    selection = OptionButton.new()
    panel.add_child(selection)
    earth_only = CheckButton.new()
    earth_only.text = "Earth history only — hide fictional overlay"
    earth_only.button_pressed = true
    panel.add_child(earth_only)
    details = Label.new()
    details.custom_minimum_size = Vector2(980,290)
    details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    details.add_theme_font_size_override("font_size",24)
    panel.add_child(details)
    open_button = Button.new()
    open_button.text = "Open separate mature-surface study"
    panel.add_child(open_button)
    open_button.disabled = true
    if not registry.load_registry():
        details.text = "Registry unavailable. All fictional scenes locked."
        return
    for row in registry.data["eras"]:
        selection.add_item(row["title"])
    selection.item_selected.connect(_select)
    earth_only.toggled.connect(_toggle)
    open_button.pressed.connect(_open_selected)
    _select(0)

func _select(index: int) -> void:
    selected_id = str(registry.data["eras"][index]["id"])
    _refresh()

func _toggle(_enabled: bool) -> void:
    _refresh()

func _refresh() -> void:
    var row: Dictionary = registry.era(selected_id)
    details.text = str(row["title"]) + "\n" + str(row["chronology"]) + "\n\nEARTH CONTEXT\n" + str(row["earth_context"])
    if not earth_only.button_pressed:
        details.text += "\n\nFICTIONAL ALCHUL OVERLAY\n" + str(row["fiction"]) + "\nScene status: " + str(row["status"])
    open_button.disabled = earth_only.button_pressed or registry.scene_for(selected_id).is_empty()

func _open_selected() -> void:
    if not open_button.disabled:
        get_tree().change_scene_to_file(registry.scene_for(selected_id))
