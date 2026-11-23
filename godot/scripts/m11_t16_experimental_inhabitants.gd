extends Node3D

## T16: opt-in engineering integration, NEVER an approved playable NPC.
## In the chapter the source scene is OFF unless ALCHUL_T16_EXPERIMENTAL=1
## in a local Godot process. Default public Web export renders no inhabitants.
const EVOLVED_SCENE: PackedScene = preload("res://scenes/m11_t16_evolutionary_lab.tscn")
const T14_DATA: String = "res://data/m11_t14_anatomy_review.json"
const STAGES: Dictionary = {
    "M2":"res://assets/m2/ALC_M2_RIVER_STATION_v001.glb",
    "M3":"res://assets/m3/ALC_M3_NURSERY_CIRCULATION_v001.glb",
    "M4":"res://assets/m4/ALC_M4_HARVEST_PRECINCT_v001.glb",
    "M5":"res://assets/m5/ALC_M5_CONNECTIVE_SETTLEMENT_v001.glb"
}
@export var embedded_in_chapter: bool = false
@export var experiment_enabled: bool = false

var rig_lab: Node3D
var stage: Node3D
var report: Label
var current_source: String = ""
var enabled: bool = false
var disabled_reason: String = "NOT_APPROVED_AND_NOT_OPTED_IN"
var lod: int = 1
var real_source_loaded: bool = false
var source_mesh_nodes: int = 0
var actor_count: int = 0
var boot_elapsed_ms: int = 0


func _ready() -> void:
    var review: Variant = JSON.parse_string(FileAccess.get_file_as_string(T14_DATA))
    if not (review is Dictionary) or review.get("current_decision") != null or review.get("status") != "DECISION_PENDING_NOT_CANON":
        push_error("T16 review does not match explicit pending status; fail closed")
        disabled_reason = "REVIEW_CONTRACT_INVALID"
        return
    # Only a separate local opt-in; flags cannot override scientific approval.
    var requested: bool = experiment_enabled or (embedded_in_chapter and OS.get_environment("ALCHUL_T16_EXPERIMENTAL") == "1")
    if not requested:
        return
    if embedded_in_chapter and OS.has_feature("web"):
        disabled_reason = "WEB_EXPERIMENT_DISABLED"
        return
    enable_experimental_stage()


func enable_experimental_stage() -> bool:
    if enabled:
        return true
    if embedded_in_chapter and OS.has_feature("web"):
        return false
    var review: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(T14_DATA))
    if review.get("current_decision") != null or review.get("status") != "DECISION_PENDING_NOT_CANON":
        return false
    var began: int = Time.get_ticks_msec()
    if not embedded_in_chapter:
        _research_environment()
        if not select_source("M2"):
            return false
    rig_lab = EVOLVED_SCENE.instantiate()
    rig_lab.name = "EvolutionaryWeightedRig_NotCanon"
    add_child(rig_lab)
    # Remove all references used by the stand-alone bone lab. Only real
    # T13 Skeleton3D, weighted ArrayMesh and child actors remain visible.
    for node_name in ["MatchedT07Camera", "ResearchAmbient", "AnatomyKey", "SharedFloorReference",
        "SkeletalStudyHud"]:
        var unwanted: Node = rig_lab.get_node_or_null(node_name)
        if unwanted == null:
            continue
        if unwanted is Camera3D:
            (unwanted as Camera3D).current = false
        if unwanted is CanvasLayer:
            (unwanted as CanvasLayer).visible = false
        if unwanted is Node3D:
            (unwanted as Node3D).visible = false
    for key in ["E1","E2","E3"]:
        var root_actor: Node3D = rig_lab.get_node_or_null("T07_" + key)
        if root_actor == null:
            push_error("T16 no actual T16 evolved model " + key)
            return false
        var label: Label3D = root_actor.get_node_or_null("HypothesisLabel")
        if label != null:
            label.visible = false
        var skeleton: Skeleton3D = root_actor.get_node("ResearchSkeleton3D")
        var weighted: MeshInstance3D = root_actor.get_node("SkinnedShell_LOD0")
        if skeleton.get_bone_count() != 43 or weighted.skin == null:
            push_error("T16 no valid 43-bone weighted skin")
            return false
    actor_count = 3
    rig_lab.set_clip("rest")
    rig_lab.set_lod(lod)
    enabled = true
    disabled_reason = ""
    if embedded_in_chapter:
        place_at_chapter_sites()
    else:
        _place_at_source()
    boot_elapsed_ms = Time.get_ticks_msec() - began
    _update_report()
    return true


func _research_environment() -> void:
    var ambient := WorldEnvironment.new()
    ambient.name = "T16SceneAmbient"
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.19, 0.24, 0.25)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.88, 0.89, 0.81)
    ambient.environment = env
    add_child(ambient)
    var sun := DirectionalLight3D.new()
    sun.name = "T16StudyLight"
    sun.rotation_degrees = Vector3(-48, 26, 0)
    add_child(sun)
    var cam := Camera3D.new()
    cam.name = "T16StudyCamera"
    cam.fov = 53.0
    cam.current = true
    add_child(cam)
    var layer := CanvasLayer.new()
    layer.name = "T16ResearchBanner"
    add_child(layer)
    report = Label.new()
    report.position = Vector2(18, 16)
    report.add_theme_font_size_override("font_size", 16)
    report.add_theme_color_override("font_color", Color(0.98, 0.91, 0.67))
    layer.add_child(report)


func select_source(key: String) -> bool:
    if embedded_in_chapter or not STAGES.has(key):
        return false
    var packed: Resource = load(STAGES[key])
    if not (packed is PackedScene):
        return false
    var candidate: Node = (packed as PackedScene).instantiate()
    if not (candidate is Node3D):
        candidate.free()
        return false
    if stage != null:
        stage.queue_free()
    stage = candidate as Node3D
    stage.name = "ActualFirstPartyGLB_" + key
    add_child(stage)
    source_mesh_nodes = 0
    var color_mat := StandardMaterial3D.new()
    color_mat.vertex_color_use_as_albedo = true
    color_mat.roughness = 0.85
    var aabb: AABB = AABB()
    var found: bool = false
    for node in stage.find_children("*", "MeshInstance3D", true, false):
        var mesh: MeshInstance3D = node as MeshInstance3D
        if mesh.mesh == null:
            continue
        source_mesh_nodes += 1
        mesh.material_override = color_mat
        var bounds: AABB = mesh.mesh.get_aabb()
        var start: Vector3 = bounds.position
        var stop: Vector3 = bounds.end
        for x in [start.x,stop.x]:
            for y in [start.y,stop.y]:
                for z in [start.z,stop.z]:
                    var point: Vector3 = mesh.global_transform * Vector3(x,y,z)
                    if not found:
                        aabb = AABB(point, Vector3.ZERO)
                        found = true
                    else:
                        aabb = aabb.expand(point)
    if not found:
        return false
    current_source = key
    real_source_loaded = true
    var span: float = maxf(aabb.size.length(), 7.0)
    var center: Vector3 = aabb.get_center()
    var cam: Camera3D = get_node("T16StudyCamera")
    cam.position = center + Vector3(span * 0.65, span * 0.48, span * 0.84)
    cam.far = maxf(1000, span * 4)
    cam.look_at(center)
    if rig_lab != null:
        _place_at_source()
    _update_report()
    return true


func _place_at_source() -> void:
    if rig_lab == null:
        return
    var placements: Dictionary = {"E1":Vector3(-5.5,0.5,-2.0),
        "E2":Vector3(0.0,0.5,-2.0), "E3":Vector3(5.5,0.5,-2.0)}
    for key in ["E1","E2","E3"]:
        var actor: Node3D = rig_lab.get_node("T07_" + key)
        actor.position = placements[key]
        actor.scale = Vector3.ONE * 0.85


func place_at_chapter_sites() -> bool:
    if not embedded_in_chapter or rig_lab == null:
        return false
    var world: Node = get_parent()
    if world == null or not world.has_method("terrain_height"):
        return false
    var placements: Dictionary = {"E1":Vector2(8.0,0.0), "E2":Vector2(-10.0,7.0),
        "E3":Vector2(-5.0,-2.0)}
    for key in ["E1","E2","E3"]:
        var root_actor: Node3D = rig_lab.get_node("T07_" + key)
        var p: Vector2 = placements[key]
        root_actor.position = Vector3(p.x + 3.0, float(world.call("terrain_height", p.x+3.0,p.y+2.0)), p.y + 2.0)
        root_actor.scale = Vector3.ONE * 0.75 # Illustration scale; not meters.
    return true


func set_motion(name: String) -> bool:
    if not enabled:
        return false
    return bool(rig_lab.set_clip(name))


func set_quality(index: int) -> bool:
    if index not in [0,1]:
        return false
    lod = index
    if enabled:
        return bool(rig_lab.set_lod(index))
    return true


func disable_experiment() -> void:
    if rig_lab != null:
        rig_lab.queue_free()
        rig_lab = null
    enabled = false
    actor_count = 0
    disabled_reason = "RESEARCH_DISABLED"
    _update_report()


func _update_report() -> void:
    if report != null:
        report.text = "T16 | 3 EVOLUTIONARY SKINNED E1/E2/E3 MODELS, NOT APPROVED  /  %s  /  %d MESH NODES\n" % [current_source, source_mesh_nodes] +             "1-4 source GLB  |  5-9 poses  |  L LOD  |  X disable  |  NO METRIC/EVOLUTIONARY CERTAINTY"


func integration_summary() -> Dictionary:
    return {"experiment_enabled":enabled, "disabled_reason":disabled_reason,
        "embedded_in_chapter":embedded_in_chapter,
        "source_original_glb":real_source_loaded, "source_key":current_source,
        "source_meshes":source_mesh_nodes, "actor_count":actor_count,
        "actual_43_bone_skinned":enabled and actor_count == 3,
        "lod":lod, "setup_ms_diagnostic_only":boot_elapsed_ms,
        "production_frame_budget_verified":false,
        "player_accessible_default":false,
        "creator_approved":false, "canon_promoted":false,
        "present_day_species_model":false, "experimental_stage_only":true}


func _unhandled_key_input(event: InputEvent) -> void:
    if embedded_in_chapter or not enabled or not(event is InputEventKey) or not event.pressed or event.echo:
        return
    match event.keycode:
        KEY_1, KEY_2, KEY_3, KEY_4:
            select_source(["M2","M3","M4","M5"][event.keycode - KEY_1])
        KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
            set_motion(["walk","turn","grip","rest","communicate"][event.keycode - KEY_5])
        KEY_L:
            set_quality(1 - lod)
        KEY_X:
            disable_experiment()
