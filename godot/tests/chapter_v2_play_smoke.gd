extends SceneTree

## Chapter I 1.1 interactive and visual smoke, fully offline native Godot.
## Proves a new playable feature rather than only static website changes.
func _initialize() -> void:
    call_deferred("_run")


func _fail(reason: String) -> void:
    push_error("ALCHUL CHAPTER V2 FAIL: " + reason)
    quit(1)


func _run() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    if packed == null:
        _fail("main scene missing")
        return
    var world: Node = packed.instantiate()
    root.add_child(world)
    await process_frame
    var game: Node = world.get_node_or_null("BraidedReachChapter")
    var atmosphere: Node = world.get_node_or_null("ChapterI_VisitorAtmosphere_And_Navigation_NotCanon")
    if game == null or atmosphere == null:
        _fail("v2 interface / atmosphere absent")
        return
    var summary: Dictionary = atmosphere.visual_summary()
    if summary.get("visitor_waypoints", 0) != 4 or summary.get("instanced_reeds", 0) != 360:
        _fail("new world wayfinding or environment missing")
        return
    if bool(summary.get("scientific_vegetation_id", true)):
        _fail("fictional vegetation claimed real evidence")
        return
    if world.get_node("WorkingBodyStudy_NotCanonical").visible:
        _fail("noncanonical primitive body still presented in actual game")
        return
    if game.state != "title":
        _fail("new title did not launch")
        return
    var reticle: Node = game.get_node_or_null("GameScreen/ExplorationReticle")
    if reticle == null:
        _fail("new first-person reticle not created")
        return
    game._start_new()
    if not game.is_playing() or game.asset_atlas.selected != 0:
        _fail("chapter does not start in coherent integrated game world")
        return
    if game.stage_card.visible:
        _fail("original media laboratory should not cover playable viewport")
        return
    var instrument_source: Script = load("res://scripts/chapter_signal_instrument.gd")
    if instrument_source == null:
        _fail("paired control source missing")
        return
    var instrument: VBoxContainer = instrument_source.new()
    if instrument.configure("invented_city"):
        _fail("unsourced historical site accepted")
        return
    if not instrument.configure("bank"):
        _fail("known bank site rejected")
        return
    var test: Dictionary = instrument.validation_summary()
    if bool(test.get("contact_testimony_as_evidence", true)) or bool(test.get("has_fictional_units", true)):
        _fail("instrument implied magical proof or fake physical units")
        return
    if float(test.get("peak", 0.0)) <= float(test.get("off_target", 1.0)):
        _fail("comparison has no tuneable signal")
        return
    instrument.free()
    for id in ["bank", "nursery", "harvest", "witness"]:
        var site: Dictionary = game._get_site(id)
        game.on_site_interaction(site)
        if game.state != "entry":
            _fail("site report not opened for " + id)
            return
        game._show_survey(id)
        if game.state != "survey":
            _fail("instrument did not open " + id)
            return
        var active: Node = game.get_node_or_null("GameModalBackdrop") # modal is under GameScreen
        var probe: Node = game.modal_column.get_node_or_null("StationSurvey")
        if probe == null:
            _fail("instrument missing from modal for " + id)
            return
        var target: float = float(probe.PROFILES[id]["center"])
        probe._on_tune(target)
        if not bool(probe._capture()):
            _fail("player cannot record tuned reference " + id)
            return
        if not game.surveyed.has(id):
            _fail("paired survey not persisted " + id)
            return
        if probe._capture():
            _fail("duplicate study accepted")
            return
        game._resume()
    if game.get_recorded_count() != 4 or game.surveyed.size() != 4:
        _fail("four site and four comparison completion failed")
        return
    game._load()
    if game.surveyed.size() != 4:
        _fail("paired studies not restored in backward-compatible local save")
        return
    game.on_site_interaction(game._get_site("bank"))
    if not game.is_complete():
        _fail("return-to-bank finale missing")
        return
    game._start_new()
    if game.surveyed.size() != 0:
        _fail("new expedition carried previous survey evidence")
        return
    DirAccess.remove_absolute(ProjectSettings.globalize_path(game.SAVE_PATH))
    print("ALCHUL CHAPTER V2 PASS — cinematic game stage, compact UI, four visible guides, repeatable paired-control minigame, save/replay")
    world.queue_free()
    quit(0)
