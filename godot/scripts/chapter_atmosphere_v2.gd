extends Node3D

## Chapter I 1.1 atmosphere and WAYFINDING OVERLAY. Additive to the archived
## scene; markers/signs are player aids, not claimed Cretaceous artifacts.
var parent_world: Node3D
var book: Dictionary = {}
var pollen: MultiMeshInstance3D
var key_light: DirectionalLight3D
const GOLD: Color = Color(0.96, 0.76, 0.46)
const MIST: Color = Color(0.56, 0.68, 0.64)


func setup(world: Node3D, data: Dictionary) -> void:
    parent_world = world
    book = data


func _ready() -> void:
    _upgrade_daylight()
    _visitor_waypoints()
    _riverbank_groundcover()


func _upgrade_daylight() -> void:
    var world_env: WorldEnvironment = parent_world.get_node_or_null("LocalEnvironment")
    if world_env != null:
        var env: Environment = world_env.environment
        var sky_material := ProceduralSkyMaterial.new()
        sky_material.sky_top_color = Color(0.22, 0.38, 0.47)
        sky_material.sky_horizon_color = Color(0.72, 0.67, 0.53)
        sky_material.ground_bottom_color = Color(0.20, 0.31, 0.28)
        sky_material.ground_horizon_color = Color(0.60, 0.59, 0.49)
        sky_material.use_debanding = true
        var sky := Sky.new()
        sky.sky_material = sky_material
        env.sky = sky
        env.background_mode = Environment.BG_SKY
        env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
        env.ambient_light_color = Color(0.72, 0.76, 0.69)
        env.ambient_light_energy = 0.76
        # Godot Compatibility renderer may omit volumetric fog; this falls
        # back to the native sky and landscape without a black screen.
        env.fog_enabled = true
        env.fog_density = 0.005
        env.fog_light_color = MIST
    key_light = parent_world.get_node_or_null("IllustrativeDaylight")
    if key_light != null:
        key_light.rotation_degrees = Vector3(-41, 31, 0)
        key_light.light_color = Color(1.0, 0.89, 0.75)
        key_light.light_energy = 1.20


func _visitor_waypoints() -> void:
    var markers: Dictionary = {
        "bank":{"num":"01", "hint":"RIVER   /   MATERIAL STRESS"},
        "nursery":{"num":"02", "hint":"NURSERY   /   AIR AND CARE"},
        "harvest":{"num":"03", "hint":"HARVEST   /   FERMENTATION"},
        "witness":{"num":"04", "hint":"WITNESS   /   COMPARISON"}
    }
    var bronze := StandardMaterial3D.new()
    bronze.albedo_color = Color(0.67, 0.53, 0.35)
    bronze.roughness = 0.80
    bronze.metallic = 0.07
    var pale := StandardMaterial3D.new()
    pale.albedo_color = Color(0.56, 0.63, 0.54)
    pale.roughness = 0.92
    for item in book.get("sites", []):
        if not (item is Dictionary):
            continue
        var key: String = str(item.get("id", ""))
        if not markers.has(key):
            continue
        var coords: Array = item.get("position", [])
        if coords.size() != 2:
            continue
        var x: float = float(coords[0])
        var z: float = float(coords[1])
        var h: float = parent_world.terrain_height(x, z)
        var guide := Node3D.new()
        guide.name = "VisitorNavigation_" + key
        guide.position = Vector3(x, h, z)
        add_child(guide)
        var base := MeshInstance3D.new()
        base.name = "GuideCircle_NotHistoricalArtifact"
        var disc := CylinderMesh.new()
        disc.top_radius = 2.75
        disc.bottom_radius = 2.75
        disc.height = 0.026
        disc.radial_segments = 64
        base.mesh = disc
        base.material_override = pale
        base.position.y = 0.035
        guide.add_child(base)
        var inset := MeshInstance3D.new()
        var bronze_disc := CylinderMesh.new()
        bronze_disc.top_radius = 2.55
        bronze_disc.bottom_radius = 2.55
        bronze_disc.height = 0.029
        bronze_disc.radial_segments = 64
        inset.mesh = bronze_disc
        inset.material_override = bronze
        inset.position.y = 0.055
        guide.add_child(inset)
        var inner := MeshInstance3D.new()
        var center := CylinderMesh.new()
        center.top_radius = 2.43
        center.bottom_radius = 2.43
        center.height = 0.032
        center.radial_segments = 64
        inner.mesh = center
        inner.material_override = pale
        inner.position.y = 0.073
        guide.add_child(inner)
        # No depth test is intentional: the expedition overlay is a screen aid,
        # not a fossil-labeled or fictional resident-built sign.
        var label := Label3D.new()
        label.name = "NavigationLabel"
        label.text = str(markers[key]["num"]) + "  /  " + str(markers[key]["hint"])
        label.font_size = 48
        label.pixel_size = 0.004
        label.modulate = GOLD
        label.outline_modulate = Color(0.035, 0.055, 0.065, 0.95)
        label.outline_size = 14
        label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        label.no_depth_test = true
        label.position = Vector3(0, 3.2, 0)
        guide.add_child(label)


func _riverbank_groundcover() -> void:
    # 360 instanced reed/seed-head forms rather than hundreds of scene nodes.
    # Botanically illustrative: no claim to specific Maastrichtian taxa.
    var rng := RandomNumberGenerator.new()
    rng.seed = 102773
    var stem := CylinderMesh.new()
    stem.height = 1.0
    stem.top_radius = 0.020
    stem.bottom_radius = 0.055
    stem.radial_segments = 5
    var instances := MultiMesh.new()
    instances.transform_format = MultiMesh.TRANSFORM_3D
    instances.mesh = stem
    instances.instance_count = 360
    for i in range(instances.instance_count):
        var x: float = rng.randf_range(-53.0, 53.0)
        var z: float = parent_world.river_center(x)
        z += (-1.0 if i % 2 == 0 else 1.0) * rng.randf_range(5.8, 12.7)
        var y: float = parent_world.terrain_height(x, z)
        var height: float = rng.randf_range(0.48, 1.66)
        var basis := Basis().rotated(Vector3.UP, rng.randf_range(0.0, TAU))
        basis = basis.scaled(Vector3(1.0, height, 1.0))
        instances.set_instance_transform(i, Transform3D(basis, Vector3(x, y + height * 0.5, z)))
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.39, 0.46, 0.28)
    mat.roughness = 0.96
    var group := MultiMeshInstance3D.new()
    group.name = "AdditionalIllustrativeRiverReeds"
    group.multimesh = instances
    group.material_override = mat
    add_child(group)


func visual_summary() -> Dictionary:
    var count: int = 0
    for child in get_children():
        if child.name.begins_with("VisitorNavigation_"):
            count += 1
    return {"visitor_waypoints":count, "instanced_reeds":360,
        "scientific_vegetation_id":false, "alchul_body_visible":false,
        "original_media_replaced":false, "gameplay_scopes":["surface-era", "not_present_day"]}
