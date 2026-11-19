extends CanvasLayer

## ALCHUL: The Braided Reach — complete short exploratory game loop.
## No new external art, network access, invented canon or third-party runtime.
## The 4 existing worldbook locations form a finite, saveable field expedition.

const MAP_SCRIPT: Script = preload("res://scripts/game_map.gd")
const SAVE_PATH: String = "user://braided_reach_chapter_v1.json"
const SITE_ORDER: Array[String] = ["bank", "nursery", "harvest", "witness"]
const INK: Color = Color(0.058, 0.094, 0.104, 0.96)
const GOLD: Color = Color(0.95, 0.73, 0.43)
const PALE: Color = Color(0.91, 0.94, 0.88)
const MUTED: Color = Color(0.69, 0.76, 0.72)
const GREEN: Color = Color(0.37, 0.76, 0.62)

var world: Node3D
var visitor: AlchulObserver
var book: Dictionary = {}
var sites: Array = []
var visited: Dictionary = {}
var completed: bool = false
var state: String = "title"
var refresh_clock: float = 0.0
var root_ui: Control
var hud_card: PanelContainer
var map_card: PanelContainer
var overlay: ColorRect
var modal_card: PanelContainer
var modal_column: VBoxContainer
var heading_label: Label
var counter_label: Label
var objective_label: Label
var nearest_label: Label
var site_list_label: Label
var lens_label: Label
var map_widget: Control

func setup(scene: Node3D, player: AlchulObserver, data: Dictionary) -> void:
	world = scene
	visitor = player
	book = data
	sites = book.get("sites", [])

func _ready() -> void:
	_build_hud()
	_build_modal()
	_load()
	_show_title()
	set_process(true)

func is_playing() -> bool:
	return state == "playing"

func has_modal() -> bool:
	return state != "playing"

func get_recorded_count() -> int:
	return visited.size()

func is_complete() -> bool:
	return completed

func _card_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = INK
	box.border_color = Color(0.55, 0.43, 0.28, 0.85)
	box.set_border_width_all(1)
	box.set_corner_radius_all(9)
	box.content_margin_left = 18.0
	box.content_margin_right = 18.0
	box.content_margin_top = 15.0
	box.content_margin_bottom = 15.0
	return box

func _label(text_value: String, font_size: int = 15, color: Color = PALE) -> Label:
	var node := Label.new()
	node.text = text_value
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node

func _button(text_value: String, action: Callable, primary: bool = false) -> Button:
	var node := Button.new()
	node.text = text_value
	node.custom_minimum_size = Vector2(148, 42)
	node.add_theme_font_size_override("font_size", 15)
	node.add_theme_color_override("font_color", GOLD if primary else PALE)
	node.pressed.connect(action)
	return node

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
	hud_card.offset_right = 385.0
	hud_card.offset_bottom = 282.0
	root_ui.add_child(hud_card)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 8)
	hud_card.add_child(left)
	left.add_child(_label("ALCHUL  /  THE BRAIDED REACH", 19, GOLD))
	left.add_child(_label("A surface-era field expedition", 13, MUTED))
	counter_label = _label("0 / 4 accounts recorded", 16, PALE)
	left.add_child(counter_label)
	objective_label = _label("Survey the riverbank settlements.", 14, PALE)
	left.add_child(objective_label)
	nearest_label = _label("Find the nearest stone observation marker.", 14, GREEN)
	left.add_child(nearest_label)
	lens_label = _label("Viewing: Outside observer", 13, MUTED)
	left.add_child(lens_label)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 5)
	left.add_child(buttons)
	for id in ["outside", "resident", "contact"]:
		var names: Dictionary = {"outside": "1 Outside", "resident": "2 Resident", "contact": "3 Reports"}
		var btn := _button(str(names[id]), _choose_lens.bind(id))
		btn.custom_minimum_size = Vector2(96, 34)
		buttons.add_child(btn)

	map_card = PanelContainer.new()
	map_card.name = "AtlasCard"
	map_card.add_theme_stylebox_override("panel", _card_style())
	map_card.anchor_left = 1.0
	map_card.anchor_right = 1.0
	map_card.offset_left = -304.0
	map_card.offset_right = -16.0
	map_card.offset_top = 16.0
	map_card.offset_bottom = 430.0
	root_ui.add_child(map_card)
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 5)
	map_card.add_child(right)
	right.add_child(_label("FIELD MAP", 15, GOLD))
	map_widget = MAP_SCRIPT.new()
	map_widget.custom_minimum_size = Vector2(250, 202)
	map_widget.set("sites", sites)
	map_widget.set("visited", visited)
	map_widget.set("observer", visitor)
	right.add_child(map_widget)
	site_list_label = _label("", 13, PALE)
	right.add_child(site_list_label)
	right.add_child(_label("Gold: unvisited   Green: recorded", 12, MUTED))

	var help := PanelContainer.new()
	help.name = "ControlsHint"
	help.add_theme_stylebox_override("panel", _card_style())
	help.anchor_top = 1.0
	help.anchor_bottom = 1.0
	help.offset_top = -68.0
	help.offset_bottom = -15.0
	help.offset_left = 16.0
	help.offset_right = 835.0
	root_ui.add_child(help)
	help.add_child(_label("WASD move    Right-drag look    Shift faster    E examine    TAB journal    H help    ESC pause", 13, MUTED))

func _build_modal() -> void:
	overlay = ColorRect.new()
	overlay.name = "GameModalBackdrop"
	overlay.color = Color(0.015, 0.03, 0.035, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root_ui.add_child(overlay)
	modal_card = PanelContainer.new()
	modal_card.name = "GameModal"
	modal_card.add_theme_stylebox_override("panel", _card_style())
	modal_card.anchor_left = 0.5
	modal_card.anchor_right = 0.5
	modal_card.anchor_top = 0.5
	modal_card.anchor_bottom = 0.5
	modal_card.offset_left = -355.0
	modal_card.offset_right = 355.0
	modal_card.offset_top = -292.0
	modal_card.offset_bottom = 292.0
	overlay.add_child(modal_card)
	modal_column = VBoxContainer.new()
	modal_column.add_theme_constant_override("separation", 12)
	modal_card.add_child(modal_column)

func _change_state(next: String) -> void:
	state = next
	if visitor != null:
		visitor.movement_enabled = state == "playing"
	overlay.visible = state != "playing"
	hud_card.visible = state != "title" and state != "ending"
	map_card.visible = state != "title" and state != "ending"
	var hint: Control = root_ui.get_node("ControlsHint") as Control
	hint.visible = state == "playing"
	_refresh_hud()

func _clear_modal() -> void:
	for child in modal_column.get_children():
		modal_column.remove_child(child)
		child.queue_free()

func _modal_screen(kicker: String, title: String, sections: Array, actions: Array) -> void:
	_clear_modal()
	modal_column.add_child(_label(kicker, 13, GOLD))
	modal_column.add_child(_label(title, 27, PALE))
	var line := HSeparator.new()
	modal_column.add_child(line)
	var scroller := ScrollContainer.new()
	scroller.custom_minimum_size = Vector2(635, 365)
	scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
	modal_column.add_child(scroller)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroller.add_child(body)
	for section in sections:
		var tag: String = str(section.get("heading", ""))
		var paragraph: String = str(section.get("body", ""))
		if not tag.is_empty():
			body.add_child(_label(tag, 16, GOLD))
		if not paragraph.is_empty():
			body.add_child(_label(paragraph, 15, PALE))
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 14)
	modal_column.add_child(action_row)
	for action in actions:
		var button := _button(str(action["text"]), action["callable"], bool(action.get("primary", false)))
		action_row.add_child(button)
	overlay.visible = true

func _show_title() -> void:
	_change_state("title")
	var intro: Array = [
		{"heading": "One river. Four places. A contested history.",
		"body": "Explore an ancient engineered river margin, record what its residents might have known, and return to the river-reading station with all four accounts."},
		{"heading": "An independent world",
		"body": "The terrain and surviving structures are provisional reconstructions. The inhabitants evolved from Earth life; their exact form is unresolved. No model depicts Alchul itself."},
		{"heading": "How the chapter works",
		"body": "Find four stone markers, press E to examine them, and read the Outside, Resident and Contact interpretations. Once all four are recorded, return to the river-reading station to finish your report. Progress saves locally."}
	]
	var actions: Array = [{"text": "Begin expedition", "callable": Callable(self, "_start_new"), "primary": true}]
	if FileAccess.file_exists(SAVE_PATH) and (visited.size() > 0 or completed):
		actions.append({"text": "Continue saved journey", "callable": Callable(self, "_continue")})
	actions.append({"text": "Exit", "callable": Callable(self, "_quit")})
	_modal_screen("A SELF-CONTAINED EXPLORATION CHAPTER", "ALCHUL / THE BRAIDED REACH", intro, actions)

func _start_new() -> void:
	visited = {}
	completed = false
	visitor.position = Vector3(0.0, world.terrain_height(0.0, 15.0), 15.0)
	map_widget.set("visited", visited)
	_save()
	_change_state("playing")

func _continue() -> void:
	_load()
	if completed:
		_show_ending()
	else:
		_change_state("playing")

func _quit() -> void:
	get_tree().quit()

func _resume() -> void:
	_change_state("playing")

func _choose_lens(id: String) -> void:
	world._set_lens(id)
	lens_label.text = "Viewing: " + str(book.get("lenses", {}).get(id, {}).get("title", id))

func _get_site(id: String) -> Dictionary:
	for site in sites:
		if str(site.get("id", "")) == id:
			return site
	return {}

func _objective_text() -> String:
	if completed:
		return "Report complete. Explore freely or restart from the menu."
	for id in SITE_ORDER:
		if not visited.has(id):
			var site: Dictionary = _get_site(id)
			return "Next account: " + str(site.get("label", id))
	return "All four recorded. Return to the river-reading station and press E."

func _refresh_hud() -> void:
	if counter_label == null or visitor == null:
		return
	counter_label.text = str(visited.size()) + " / 4 accounts recorded"
	objective_label.text = _objective_text()
	var closest_distance: float = 99999.0
	var closest: Dictionary = {}
	var lines: Array[String] = []
	for id in SITE_ORDER:
		var site: Dictionary = _get_site(id)
		var coords: Array = site.get("position", [])
		if coords.size() != 2:
			continue
		var distance: float = Vector2(visitor.position.x - float(coords[0]), visitor.position.z - float(coords[1])).length()
		if distance < closest_distance:
			closest_distance = distance
			closest = site
		var symbol: String = "✓" if visited.has(id) else "○"
		lines.append(symbol + " " + str(site.get("label", id)) + "  ·  " + str(roundi(distance)) + "m")
	site_list_label.text = "\n".join(lines)
	if closest.is_empty():
		nearest_label.text = "No known site in range."
	elif closest_distance < 6.0:
		nearest_label.text = "E  EXAMINE  " + str(closest.get("label", "site"))
	else:
		nearest_label.text = "Nearest: " + str(closest.get("label", "site")) + "  (" + str(roundi(closest_distance)) + "m)"
	if map_widget != null:
		map_widget.set("visited", visited)

func _save() -> void:
	var serial: Dictionary = {"schema": "alchul.braided-reach-save.v1", "visited": visited.keys(), "completed": completed}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Unable to save local field notes")
		return
	file.store_string(JSON.stringify(serial))
	file.close()

func _load() -> void:
	visited = {}
	completed = false
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(raw) != TYPE_DICTIONARY:
		return
	if raw.get("schema", "") != "alchul.braided-reach-save.v1":
		return
	var known: Array = raw.get("visited", [])
	for id in SITE_ORDER:
		if known.has(id):
			visited[id] = true
	completed = bool(raw.get("completed", false)) and visited.size() == SITE_ORDER.size()
	if map_widget != null:
		map_widget.set("visited", visited)

func on_site_interaction(site: Dictionary) -> void:
	if state != "playing":
		return
	var id: String = str(site.get("id", ""))
	if not SITE_ORDER.has(id):
		return
	if id == "bank" and visited.size() == SITE_ORDER.size() and not completed:
		_finish()
		return
	if not visited.has(id):
		visited[id] = true
		_save()
	_refresh_hud()
	var status_text: String = "ACCOUNT RECORDED" if visited.has(id) else "SITE REPORT"
	var paragraphs: Array = [
		{"heading": "OUTSIDE  /  MATERIAL EVIDENCE", "body": str(site.get("lenses", {}).get("outside", ""))},
		{"heading": "RESIDENT  /  WORKING INTERPRETATION", "body": str(site.get("lenses", {}).get("resident", ""))},
		{"heading": "CONTACT  /  UNVERIFIED TESTIMONY", "body": str(site.get("lenses", {}).get("contact", ""))}
	]
	if visited.size() == SITE_ORDER.size() and not completed:
		paragraphs.append({"heading": "THE LAST STEP", "body": "All four observations are archived. Return to the river-reading station and press E once more to compare the accounts."})
	_change_state("entry")
	_modal_screen(status_text + "    " + str(visited.size()) + " / 4", str(site.get("label", "")), paragraphs, [
		{"text": "Return to the expedition", "callable": Callable(self, "_resume"), "primary": true},
		{"text": "Field journal", "callable": Callable(self, "_show_journal")}
	])

func _show_journal() -> void:
	if state == "title":
		return
	var paragraphs: Array = [
		{"heading": "The archive is not a verdict.",
		"body": "Records can disagree. Each site is a place where residents might compare material evidence, learned behavior and anomalous testimony without assuming one interpretation is automatically correct."}
	]
	for id in SITE_ORDER:
		var site: Dictionary = _get_site(id)
		if visited.has(id):
			paragraphs.append({"heading": "RECORDED  /  " + str(site.get("label", id)),
			"body": str(site.get("lenses", {}).get("outside", ""))})
		else:
			paragraphs.append({"heading": "UNVISITED  /  " + str(site.get("label", id)),
			"body": "Find this site's low stone marker on the field map, approach, and press E to record its evidence."})
	_change_state("journal")
	_modal_screen("FIELD JOURNAL   " + str(visited.size()) + " / 4", "Evidence and disagreement", paragraphs, [
		{"text": "Close journal", "callable": Callable(self, "_resume"), "primary": true}
	])

func _show_help() -> void:
	if state == "title":
		return
	_change_state("help")
	_modal_screen("FIELD GUIDE", "Controls and purpose", [
		{"heading": "Navigation", "body": "WASD or arrow keys: walk. Hold right mouse button and drag: look. Hold Shift: faster movement. Your body and map marker show an outside visitor, not a reconstructed species viewpoint."},
		{"heading": "Research", "body": "Press E near a marker to record an account. Tab opens the field journal. Keys 1, 2, 3 switch the interpretive lens. H opens this guide. Escape opens the pause menu."},
		{"heading": "Completion", "body": "Record the four sites and return to the River-reading station for the concluding report. The save file lives on this computer and contains only recorded site IDs."}
	], [{"text": "Continue", "callable": Callable(self, "_resume"), "primary": true}])

func _pause() -> void:
	_change_state("paused")
	_modal_screen("EXPEDITION PAUSED", "The river continues", [
		{"heading": "Your records are saved", "body": str(visited.size()) + " of 4 site accounts archived. Continue investigating, review your journal, or return to the opening screen."}
	], [
		{"text": "Resume", "callable": Callable(self, "_resume"), "primary": true},
		{"text": "Journal", "callable": Callable(self, "_show_journal")},
		{"text": "Main menu", "callable": Callable(self, "_show_title")}
	])

func _finish() -> void:
	if visited.size() != SITE_ORDER.size():
		return
	completed = true
	_save()
	_show_ending()

func _show_ending() -> void:
	_change_state("ending")
	_modal_screen("CHAPTER COMPLETE    FOUR ACCOUNTS • ONE OPEN QUESTION", "The unclosed record", [
		{"heading": "The river cannot be held still.",
		"body": "Four places have given you four kinds of evidence: a bank that can fail, a nursery that depends on shared care, a Harvest that turns chemistry into inherited practice, and witnesses who disagree about what they perceived."},
		{"heading": "What survives is method.",
		"body": "The inhabitants do not survive by knowing everything. They survive by testing what they think they know, preserving error, and making their environment responsive to what they learn."},
		{"heading": "Beyond the Braided Reach",
		"body": "The later descent beneath Earth and the identity of Alchul remain unresolved. This completed expedition is a provisional surface-era story, not proof of a lost real civilization."}
	], [
		{"text": "Explore after the ending", "callable": Callable(self, "_resume"), "primary": true},
		{"text": "Play again", "callable": Callable(self, "_start_new")},
		{"text": "Exit", "callable": Callable(self, "_quit")}
	])

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var handled: bool = true
	match event.keycode:
		KEY_TAB:
			if state == "playing":
				_show_journal()
			elif state == "journal":
				_resume()
		KEY_H:
			if state == "playing":
				_show_help()
		KEY_ESCAPE:
			if state == "playing":
				_pause()
			elif state in ["paused", "journal", "entry", "help"]:
				_resume()
		KEY_ENTER, KEY_KP_ENTER:
			if state == "entry":
				_resume()
		_:
			handled = false
	if handled:
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	refresh_clock += delta
	if refresh_clock >= 0.25:
		refresh_clock = 0.0
		if state != "title":
			_refresh_hud()
