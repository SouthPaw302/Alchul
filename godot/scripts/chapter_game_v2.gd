extends "res://scripts/game_loop.gd"

## Chapter I 1.1 visual/gameplay rebuild. Preserves the tested four-site
## Chapter I contract but makes room for the actual 3D world and optional
## player-controlled, paired-reference studies at each site.
const SURVEY_SCRIPT: Script = preload("res://scripts/chapter_signal_instrument.gd")
var surveyed: Dictionary = {}
var map_visible: bool = true
var source_visible: bool = false
var progress_marks: Label
var center_reticle: Label
var _survey_site: String = ""


func _build_hud() -> void:
    root_ui = Control.new()
    root_ui.name = "GameScreen"
    root_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
    root_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root_ui)
    hud_card = PanelContainer.new()
    hud_card.name = "ExpeditionHUD"
    hud_card.add_theme_stylebox_override("panel", _card_style())
    hud_card.offset_left = 16.0
    hud_card.offset_top = 16.0
    hud_card.offset_right = 382.0
    hud_card.offset_bottom = 214.0
    root_ui.add_child(hud_card)
    var left := VBoxContainer.new()
    left.add_theme_constant_override("separation", 5)
    hud_card.add_child(left)
    left.add_child(_label("A L C H U L     /     C H A P T E R  0 1", 16, GOLD))
    left.add_child(_label("THE BRAIDED REACH  /  LATE SURFACE STUDY", 12, MUTED))
    progress_marks = _label("○    ○    ○    ○", 17, GOLD)
    left.add_child(progress_marks)
    counter_label = _label("0/4 places   ·   0/4 field comparisons", 13, PALE)
    left.add_child(counter_label)
    objective_label = _label("Walk the river. Record four locations.", 13, PALE)
    left.add_child(objective_label)
    nearest_label = _label("Approach a marker and press E.", 12, GREEN)
    left.add_child(nearest_label)
    lens_label = _label("OUTSIDE: material evidence", 12, MUTED)
    left.add_child(lens_label)
    var buttons := HBoxContainer.new()
    buttons.add_theme_constant_override("separation", 5)
    left.add_child(buttons)
    for id in ["outside", "resident", "contact"]:
        var names: Dictionary = {"outside":"1  Outside", "resident":"2  Resident", "contact":"3  Testimony"}
        var btn := _button(str(names[id]), _choose_lens.bind(id))
        btn.custom_minimum_size = Vector2(99, 30)
        buttons.add_child(btn)

    map_card = PanelContainer.new()
    map_card.name = "AtlasCard"
    map_card.add_theme_stylebox_override("panel", _card_style())
    map_card.anchor_left = 1.0
    map_card.anchor_right = 1.0
    map_card.offset_left = -275.0
    map_card.offset_right = -16.0
    map_card.offset_top = 16.0
    map_card.offset_bottom = 304.0
    root_ui.add_child(map_card)
    var right := VBoxContainer.new()
    right.add_theme_constant_override("separation", 4)
    map_card.add_child(right)
    right.add_child(_label("FIELD ATLAS   /   M: TOGGLE", 13, GOLD))
    map_widget = MAP_SCRIPT.new()
    map_widget.custom_minimum_size = Vector2(225, 169)
    map_widget.set("sites", sites)
    map_widget.set("visited", visited)
    map_widget.set("observer", visitor)
    right.add_child(map_widget)
    site_list_label = _label("", 12, PALE)
    right.add_child(site_list_label)

    stage_card = PanelContainer.new()
    stage_card.name = "OriginalArchiveMediaSelector"
    stage_card.add_theme_stylebox_override("panel", _card_style())
    stage_card.anchor_left = 1.0
    stage_card.anchor_right = 1.0
    stage_card.offset_left = -319.0
    stage_card.offset_right = -16.0
    stage_card.offset_top = 320.0
    stage_card.offset_bottom = 473.0
    root_ui.add_child(stage_card)
    var stage_column := VBoxContainer.new()
    stage_column.add_theme_constant_override("separation", 7)
    stage_card.add_child(stage_column)
    stage_column.add_child(_label("ORIGINAL MEDIA / OPTIONAL SOURCE LAB", 13, GOLD))
    stage_picker = OptionButton.new()
    stage_picker.name = "ModelSelect"
    stage_picker.custom_minimum_size = Vector2(239, 32)
    if asset_atlas != null:
        var idx: int = 0
        for source in asset_atlas.list_stages():
            stage_picker.add_item(str(source["name"]), idx)
            idx += 1
    stage_picker.item_selected.connect(_choose_scene)
    stage_column.add_child(stage_picker)
    stage_status = _label("F1–F7 load archived independent 3D studies. Not game levels.", 12, MUTED)
    stage_column.add_child(stage_status)

    center_reticle = _label("+", 19, Color(0.95, 0.95, 0.88))
    center_reticle.name = "ExplorationReticle"
    center_reticle.anchor_left = 0.5
    center_reticle.anchor_right = 0.5
    center_reticle.anchor_top = 0.5
    center_reticle.anchor_bottom = 0.5
    center_reticle.offset_left = -8.0
    center_reticle.offset_right = 20.0
    center_reticle.offset_top = -14.0
    center_reticle.offset_bottom = 22.0
    center_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root_ui.add_child(center_reticle)

    var help := PanelContainer.new()
    help.name = "ControlsHint"
    help.add_theme_stylebox_override("panel", _card_style())
    help.anchor_top = 1.0
    help.anchor_bottom = 1.0
    help.offset_top = -58.0
    help.offset_bottom = -12.0
    help.offset_left = 16.0
    help.offset_right = 880.0
    root_ui.add_child(help)
    help.add_child(_label("WASD MOVE   ·   RIGHT DRAG LOOK   ·   E EXAMINE   ·   M MAP   ·   TAB JOURNAL   ·   F8 SOURCE MODELS", 12, MUTED))


func _build_modal() -> void:
    super._build_modal()
    overlay.color = Color(0.01, 0.026, 0.036, 0.61)
    modal_card.offset_left = -391.0
    modal_card.offset_right = 391.0
    modal_card.offset_top = -280.0
    modal_card.offset_bottom = 280.0


func _modal_screen(kicker: String, title: String, sections: Array, actions: Array) -> void:
    var next_actions: Array = actions.duplicate()
    if state == "entry":
        for item in sites:
            if str(item.get("label", "")) == title:
                next_actions.insert(1, {"text":"Run paired field study",
                    "callable":Callable(self,"_show_survey").bind(str(item.get("id", "")))})
                break
    super._modal_screen(kicker, title, sections, next_actions)
    for item in modal_column.get_children():
        if item is ScrollContainer:
            (item as ScrollContainer).custom_minimum_size = Vector2(700.0, 305.0)


func _change_state(next: String) -> void:
    super._change_state(next)
    hud_card.visible = next == "playing"
    map_card.visible = next == "playing" and map_visible
    stage_card.visible = next == "playing" and source_visible
    if center_reticle != null:
        center_reticle.visible = next == "playing"


func _show_title() -> void:
    if asset_atlas != null:
        asset_atlas.select_stage(0)
        stage_picker.select(0)
    _change_state("title")
    var intro: Array = [
        {"heading":"A place remembered by the river",
         "body":"A working river station. A sheltered nursery. A Harvest where chemistry becomes culture. A witness circle where observations do not agree."},
        {"heading":"You are here to investigate",
         "body":"Walk between four landmarks and preserve their accounts. Tune a paired-control instrument to compare physical evidence with a reference before deciding what can actually be known."},
        {"heading":"Fiction built upon real Earth's history",
         "body":"This is a provisional Late Cretaceous reconstruction, not proof of lost dinosaurs or a visible Alchul. The inhabitants' final anatomy remains unapproved."}
    ]
    var actions: Array = [{"text":"ENTER THE BRAIDED REACH",
        "callable":Callable(self,"_start_new"), "primary":true}]
    if FileAccess.file_exists(SAVE_PATH) and (visited.size() > 0 or completed):
        actions.append({"text":"Continue expedition", "callable":Callable(self,"_continue")})
    if not OS.has_feature("web"):
        actions.append({"text":"Exit", "callable":Callable(self,"_quit")})
    _modal_screen("ALCHUL   /   CHAPTER 01   /   FIELD EXPEDITION", "THE BRAIDED REACH", intro, actions)


func _start_new() -> void:
    surveyed.clear()
    source_visible = false
    super._start_new()
    # The authored M1–M6 source GLBs are separate comparative studies; the
    # integrated M7–M8 chapter is the coherent playable geography.
    _choose_scene(0)
    _save()
    _change_state("playing")


func _continue() -> void:
    super._continue()
    _choose_scene(0)


func _save() -> void:
    var serial: Dictionary = {
        "schema":"alchul.braided-reach-save.v1",
        "visited":visited.keys(), "surveyed":surveyed.keys(), "completed":completed}
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_warning("Local expedition notes could not be saved")
        return
    file.store_string(JSON.stringify(serial))
    file.close()


func _load() -> void:
    super._load()
    surveyed.clear()
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if typeof(raw) != TYPE_DICTIONARY:
        return
    var historical: Array = raw.get("surveyed", [])
    for id in SITE_ORDER:
        if historical.has(id) and visited.has(id):
            surveyed[id] = true


func _refresh_hud() -> void:
    super._refresh_hud()
    if progress_marks != null:
        var dots: Array[String] = []
        for id in SITE_ORDER:
            dots.append("●" if visited.has(id) else "○")
        progress_marks.text = "     ".join(dots)
    if counter_label != null:
        counter_label.text = "%d / 4 sites       %d / 4 field comparisons" % [visited.size(), surveyed.size()]


func _choose_lens(id: String) -> void:
    super._choose_lens(id)
    if lens_label != null:
        lens_label.text = "VIEWPOINT / " + str(book.get("lenses", {}).get(id, {}).get("title", id))


func _show_survey(key: String) -> void:
    if not SITE_ORDER.has(key):
        return
    _survey_site = key
    _change_state("survey")
    _clear_modal()
    modal_column.add_child(_label("ALCHUL   /   PAIRED PHYSICAL CONTROL  •  NO HISTORICAL MEASUREMENTS", 13, GOLD))
    modal_column.add_child(_label(str(_get_site(key).get("label", key)), 23, PALE))
    var instrument: VBoxContainer = SURVEY_SCRIPT.new()
    instrument.name = "StationSurvey"
    instrument.configure(key, surveyed.has(key))
    instrument.reading_confirmed.connect(_on_survey_recorded)
    modal_column.add_child(instrument)
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    modal_column.add_child(row)
    row.add_child(_button("Back to site report", Callable(self,"_revisit_site").bind(key), true))
    row.add_child(_button("Continue exploring", Callable(self,"_resume")))
    overlay.visible = true


func _revisit_site(key: String) -> void:
    _resume()
    var site: Dictionary = _get_site(key)
    if not site.is_empty():
        on_site_interaction(site)


func _on_survey_recorded(key: String, _strength: float) -> void:
    if not SITE_ORDER.has(key) or surveyed.has(key):
        return
    surveyed[key] = true
    _save()
    _refresh_hud()


func _show_journal() -> void:
    super._show_journal()
    # The primary four accounts are still the original source worldbook text;
    # append only an explicitly provisional instrument status.
    if state == "journal":
        var paragraph: Label = _label("Optional independent field comparisons: %d / 4. Instrument traces are simulated normalized teaching models, not measured archaeology." % surveyed.size(), 13, MUTED)
        modal_column.add_child(paragraph)


func _show_help() -> void:
    if state == "title":
        return
    _change_state("help")
    _modal_screen("A FIELD GUIDE", "How to investigate", [
        {"heading":"Navigate the living river margin",
         "body":"WASD / arrow keys walk, Shift moves faster, right-mouse drag looks around. Follow the four labeled markers. M hides/shows the map. F8 opens an optional original-media inspector."},
        {"heading":"Make your own observations",
         "body":"Press E near a marker, then choose Run paired field study. Adjust the dial until the gold trace differs repeatably from the blue reference; capture the result. These simulated relative traces demonstrate controlled comparison, not ESP or actual prehistoric measurements."},
        {"heading":"Interpret without inventing certainty",
         "body":"1 / 2 / 3 switch material evidence, resident accounts, and contact testimony. Tab opens your journal, Escape pauses. After recording all four places, return to the bank to end Chapter I."}
    ], [{"text":"Return to expedition", "callable":Callable(self,"_resume"), "primary":true}])


func _unhandled_input(event: InputEvent) -> void:
    super._unhandled_input(event)
    if not (event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_M:
            if state == "playing":
                map_visible = not map_visible
                map_card.visible = map_visible
                get_viewport().set_input_as_handled()
        KEY_F8:
            if state == "playing":
                source_visible = not source_visible
                stage_card.visible = source_visible
                get_viewport().set_input_as_handled()
        KEY_ESCAPE:
            if state == "survey":
                _resume()
                get_viewport().set_input_as_handled()
        _:
            pass
