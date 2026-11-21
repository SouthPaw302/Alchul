extends SceneTree

## Real Godot scene test for a finite, playable, offline 4-site expedition.
## Inspects state changes, saving, resuming, map and completion without
## relying on fabricated screenshots or human input automation.
func _initialize() -> void:
	call_deferred("_run")

func _fail(reason: String) -> void:
	push_error("ALCHUL CHAPTER GAME FAIL: " + reason)
	quit(1)

func _run() -> void:
	var packed: Resource = load("res://scenes/main.tscn")
	if not (packed is PackedScene):
		_fail("main scene cannot load")
		return
	var scene: Node = (packed as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var chapter: Node = scene.get_node_or_null("BraidedReachChapter")
	var observer: Node = scene.get_node_or_null("OutsideVisitor")
	if chapter == null or observer == null:
		_fail("full chapter HUD or observer missing")
		return
	if chapter.state != "title" or observer.movement_enabled:
		_fail("launch should show title and freeze walking")
		return
	if chapter.map_widget == null or chapter.sites.size() != 4:
		_fail("four worldbook sites not present on the real field map")
		return
	chapter._start_new()
	if not chapter.is_playing() or not observer.movement_enabled:
		_fail("begin button did not start visitor movement")
		return
	for id in ["bank", "nursery", "harvest", "witness"]:
		var data: Dictionary = chapter._get_site(id)
		if data.is_empty():
			_fail("site missing: " + id)
			return
		chapter.on_site_interaction(data)
		if chapter.get_recorded_count() < 1 or chapter.state != "entry" or observer.movement_enabled:
			_fail("inspect did not record an entry and freeze movement: " + id)
			return
		chapter._resume()
		if not chapter.is_playing():
			_fail("resume after field entry failed")
			return
	if chapter.get_recorded_count() != 4 or chapter.is_complete():
		_fail("all four should be recorded but not finished until the bank return")
		return
	if not FileAccess.file_exists(chapter.SAVE_PATH):
		_fail("local offline save file absent")
		return
	chapter._load()
	if chapter.get_recorded_count() != 4:
		_fail("local save did not restore all four visits")
		return
	chapter.on_site_interaction(chapter._get_site("bank"))
	if not chapter.is_complete() or chapter.state != "ending":
		_fail("return-to-bank chapter finale did not trigger")
		return
	chapter._load()
	if not chapter.is_complete():
		_fail("completed ending not persisted")
		return
	chapter._start_new()
	if chapter.get_recorded_count() != 0 or chapter.is_complete() or not chapter.is_playing():
		_fail("replay did not reset expedition")
		return
	chapter._pause()
	if observer.movement_enabled or chapter.state != "paused":
		_fail("pause menu did not stop walking")
		return
	chapter._resume()
	if not observer.movement_enabled:
		_fail("resume did not restore walking")
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(chapter.SAVE_PATH))
	print("ALCHUL CHAPTER FULL LOOP PASS: 4 locations, field map, saved journal, finale, reset, pause")
	scene.queue_free()
	quit(0)
