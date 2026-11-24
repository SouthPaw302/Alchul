extends "res://scripts/surface_zenith_city.gd"
const FidelityKit = preload("res://scripts/surface_zenith_fidelity_assets.gd")
var river_material: ShaderMaterial
var wave_time: float = 0.0
var visible_t16: bool = false
var study_rig: Node3D
var study_overlay: Label
var actor_motion: Array[Node3D] = []
var actor_origins: Array[Vector3] = []

func _ready() -> void:
    kit = FidelityKit.new()
    super._ready()
    _detail_environment()
    _water()
    _add_rig_study()
    set_view(0)

func _detail_environment() -> void:
    var terrain: Node3D = get_node("TerrainAndWater")
    var rng := RandomNumberGenerator.new()
    rng.seed = 701002
    for i in range(95):
        var s: float = -1.0 if i%2==0 else 1.0
        var x: float = s*rng.randf_range(4.6,16.0)
        var z: float = rng.randf_range(-23.5,23.5)
        var stone: MeshInstance3D = kit.oval(terrain,"WeatheredPaving",Vector3(x,0.022,z),
            Vector3(rng.randf_range(0.22,0.59),0.035,rng.randf_range(0.20,0.46)),Kit.STONE.lightened(rng.randf_range(0.03,0.15)))
        stone.rotation.y = rng.randf_range(0,TAU)
    for i in range(22):
        var s: float = -1.0 if i%2==0 else 1.0
        var p := Vector3(s*rng.randf_range(15.8,20.2),1.03,rng.randf_range(-23.0,23.0))
        kit.oval(terrain,"Understory",p+Vector3(0,0.12,0),Vector3(0.65,0.23,0.54),Kit.DARK_LEAF)
    for i in range(14):
        var z: float = -22.0+float(i)*3.4
        for s in [-1.0,1.0]:
            var x: float = s*3.25
            kit.oval(terrain,"WetShoreStone",Vector3(x,-0.16,z),Vector3(0.36,0.20,0.58),Kit.STONE.darkened(0.17),0.48)
    for child in get_children():
        if child is Node3D and (str(child.name).contains("Adult_ConceptStatic") or str(child.name).contains("adult")):
            actor_motion.append(child)
            actor_origins.append(child.position)
    for node_value in get_children():
        if node_value is WorldEnvironment:
            node_value.environment.ambient_light_energy = 0.63
            node_value.environment.fog_density = 0.005
        if node_value is DirectionalLight3D:
            node_value.light_energy = 1.65
            node_value.directional_shadow_max_distance = 65.0
    var fill := OmniLight3D.new()
    fill.position = Vector3(2,4,4)
    fill.light_color = Color("d8e6ed")
    fill.light_energy = 0.38
    fill.omni_range = 11.0
    add_child(fill)

func _water() -> void:
    var water_node: MeshInstance3D = get_node("TerrainAndWater/RiverSurface")
    river_material = ShaderMaterial.new()
    var shader := Shader.new()
    shader.code = """
shader_type spatial;
render_mode cull_disabled;
uniform float wave_clock = 0.0;
varying vec3 world_pos;
void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}
void fragment() {
    float a = sin(world_pos.z*4.0 + world_pos.x*2.7-wave_clock*1.7);
    float b = sin(world_pos.x*7.1-world_pos.z*1.9+wave_clock*1.2);
    float c = sin(world_pos.z*12.0+world_pos.x*3.5-wave_clock*2.8);
    float ripple = a*0.46+b*0.28+c*0.13;
    ALBEDO = mix(vec3(0.075,0.22,0.22),vec3(0.38,0.65,0.62),smoothstep(-0.8,0.85,ripple));
    NORMAL_MAP = vec3(0.5+a*0.13,0.5+b*0.15,1.0);
    ROUGHNESS = 0.22+0.16*abs(ripple);
    SPECULAR = 0.72;
}
"""
    river_material.shader = shader
    water_node.material_override = river_material

func _add_rig_study() -> void:
    # Separate genuine T16 skeleton demonstration. Static new meshes are not falsely skinned.
    var lab_scene: PackedScene = load("res://scenes/m11_t16_evolutionary_lab.tscn")
    study_rig = lab_scene.instantiate()
    study_rig.name = "T16_SeparateWeightedAnimationStudy"
    add_child(study_rig)
    for id in ["MatchedT07Camera","ResearchAmbient","AnatomyKey","SharedFloorReference","SkeletalStudyHud","EvolutionaryMorphologyBanner"]:
        var n: Node = study_rig.get_node_or_null(id)
        if n is Camera3D:
            n.current = false
        if n is CanvasLayer:
            n.visible = false
        if n is Node3D:
            n.visible = false
    study_rig.set_evolutionary_focus("E2")
    study_rig.set_lod(0)
    study_rig.set_clip("communicate")
    var rig_actor: Node3D = study_rig.get_node("T07_E2")
    rig_actor.position = Vector3(0,0.15,0)
    study_rig.visible = false
    camera.current = true
    var layer := CanvasLayer.new()
    add_child(layer)
    study_overlay = Label.new()
    study_overlay.position = Vector2(20,679)
    study_overlay.add_theme_font_size_override("font_size",15)
    study_overlay.text = "A: separate T16 weighted animation study / Left-Right: ten static fidelity views"
    layer.add_child(study_overlay)

func toggle_rig() -> void:
    if study_rig == null:
        return
    visible_t16 = not visible_t16
    study_rig.visible = visible_t16
    if not actor_motion.is_empty():
        # Only the portrait model is hidden by this toggle, not the town.
        actor_motion[0].visible = not visible_t16
    if visible_t16:
        super.set_view(0)
        title.text = "ALCHUL / T16 43-BONE WEIGHTED RIG — SEPARATE STUDY"
    else:
        set_view(0)

func set_view(i: int) -> void:
    super.set_view(i)
    title.text = title.text.replace("SURFACE ZENITH","SURFACE ZENITH / PASS 02")

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_A:
        toggle_rig()
    else:
        if visible_t16 and event is InputEventKey and event.pressed and event.keycode in [KEY_LEFT,KEY_RIGHT]:
            toggle_rig()
        super._unhandled_key_input(event)

func _process(delta: float) -> void:
    wave_time += delta
    if river_material != null:
        river_material.set_shader_parameter("wave_clock",wave_time)
    # Tiny whole-body idle weight shifts only; not articulated character animation.
    for i in range(actor_motion.size()):
        if is_instance_valid(actor_motion[i]):
            actor_motion[i].position.y = actor_origins[i].y+0.007*sin(wave_time*1.4+float(i))
