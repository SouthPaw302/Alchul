extends SceneTree

## Six genuine Godot views of the redesigned Chapter I, including the playable instrument.
## Native Compatibility renderer under a virtual desktop; no mock images.
const NAMES: Array[String] = [
	"01_title", "02_expedition", "03_river_account",
	"04_paired_control", "05_field_journal", "06_chapter_ending"
]

func _initialize() -> void:
	call_deferred("_run")

func _capture(path: String) -> bool:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var result: Image = root.get_texture().get_image()
	if result == null or result.is_empty():
		return false
	return result.save_png(path) == OK

func _run() -> void:
	var out: String = OS.get_environment("ALCHUL_GAME_SCREEN_DIR")
	if out.is_empty():
		out = ProjectSettings.globalize_path("user://game_screen_review")
	if DirAccess.make_dir_recursive_absolute(out) != OK:
		push_error("ALCHUL GAME SCREEN FAIL: cannot create output")
		quit(1)
		return
	root.size = Vector2i(1280, 720)
	var packed: Resource = load("res://scenes/main.tscn")
	if not (packed is PackedScene):
		push_error("ALCHUL GAME SCREEN FAIL: cannot load main")
		quit(1)
		return
	var scene: Node = (packed as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	var chapter: Node = scene.get_node_or_null("BraidedReachChapter")
	if chapter == null:
		push_error("ALCHUL GAME SCREEN FAIL: missing UI")
		quit(1)
		return
	# Ensure title screenshot comes from fresh notes, independent of CI save.
	chapter._start_new()
	chapter._show_title()
	if not await _capture(out.path_join(NAMES[0] + ".png")):
		push_error("ALCHUL GAME SCREEN FAIL: title")
		quit(1)
		return
	chapter._continue()
	if not await _capture(out.path_join(NAMES[1] + ".png")):
		push_error("ALCHUL GAME SCREEN FAIL: expedition")
		quit(1)
		return
	chapter.on_site_interaction(chapter._get_site("bank"))
	if not await _capture(out.path_join(NAMES[2] + ".png")):
		push_error("ALCHUL GAME SCREEN FAIL: river account")
		quit(1)
		return
	chapter._show_survey("bank")
	if not await _capture(out.path_join(NAMES[3] + ".png")):
		push_error("ALCHUL GAME SCREEN FAIL: interactive paired-control panel")
		quit(1)
		return
	chapter._show_journal()
	if not await _capture(out.path_join(NAMES[4] + ".png")):
		push_error("ALCHUL GAME SCREEN FAIL: journal")
		quit(1)
		return
	chapter._resume()
	for id in ["nursery", "harvest", "witness"]:
		chapter.on_site_interaction(chapter._get_site(id))
		chapter._resume()
	chapter.on_site_interaction(chapter._get_site("bank"))
	if not chapter.is_complete():
		push_error("ALCHUL GAME SCREEN FAIL: ending not actually reached")
		quit(1)
		return
	if not await _capture(out.path_join(NAMES[5] + ".png")):
		push_error("ALCHUL GAME SCREEN FAIL: ending")
		quit(1)
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(chapter.SAVE_PATH))
	print("ALCHUL GAME SIX REAL NATIVE UI CAPTURES PASS")
	scene.queue_free()
	quit(0)
