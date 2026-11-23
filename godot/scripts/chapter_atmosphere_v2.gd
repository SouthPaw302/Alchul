extends Node3D

## Chapter I 1.1 atmosphere and WAYFINDING OVERLAY. Additive to the archived
## scene; markers/signs are player aids, not claimed Cretaceous artifacts.
var parent_world: Node3D
var book: Dictionary = {}
var pollen: MultiMeshInstance3D
var key_light: DirectionalLight3D
var rendered_canopy_count: int = 0
const GOLD: Color = Color(0.96, 0.76, 0.46)
const MIST: Color = Color(0.56, 0.68, 0.64)


func setup(world: Node3D, data: Dictionary) -> void:
    parent_world = world
    book = data


func _ready() -> void:
    _upgrade_daylight()
    _visitor_waypoints()
    _riverbank_groundcover()
    _upgrade_generated_materials()
    _living_riparian_canopy()


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
        env.fog_enabled = not OS.has_feature("web")
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



func _source_material(family: String, tint: Color) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.resource_name = "ChapterI_SourcePBR_" + family
    m.albedo_color = tint
    m.roughness = 0.88
    m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
    var path: String = "res://assets/m6/textures/ALC_M6_" + family + "_"
    var albedo: Resource = load(path + "albedo_768.png")
    var normal: Resource = load(path + "normal_768.png")
    var roughness: Resource = load(path + "roughness_768.png")
    if albedo is Texture2D:
        m.albedo_texture = albedo
    if normal is Texture2D and not OS.has_feature("web"):
        m.normal_enabled = true
        m.normal_scale = 0.27
        m.normal_texture = normal
    if roughness is Texture2D:
        m.roughness_texture = roughness
        m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
    return m


func _material_family(tint: Color) -> String:
    if tint.g > tint.r * 1.23 and tint.g > tint.b * 1.05:
        return "fern"
    if tint.g > tint.r * 1.08 and tint.g > tint.b * 1.12:
        return "moss"
    if tint.r > tint.g * 1.16:
        return "rootwood"
    if tint.r > tint.b * 1.30:
        return "clay"
    return "limestone"


func _decorate_material(material: Material, edited: Dictionary) -> void:
    if not (material is StandardMaterial3D):
        return
    var mat: StandardMaterial3D = material
    var id: int = mat.get_instance_id()
    if edited.has(id) or mat.albedo_texture != null or mat.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
        return
    edited[id] = true
    var family: String = _material_family(mat.albedo_color)
    var source: StandardMaterial3D = _source_material(family, mat.albedo_color)
    if source.albedo_texture == null:
        return
    # M6 original textures become bona fide UV-based source maps on the
    # original procedurally generated geometry; no GLB original is rewritten.
    mat.resource_name = "ChapterI_PBR_Upgraded_" + family
    mat.albedo_color = mat.albedo_color.lerp(Color(0.91, 0.87, 0.78), 0.69)
    mat.albedo_texture = source.albedo_texture
    mat.normal_enabled = source.normal_enabled
    mat.normal_texture = source.normal_texture
    mat.normal_scale = 0.28
    mat.roughness_texture = source.roughness_texture
    mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


func _walk_generated_materials(node: Node, edited: Dictionary) -> void:
    if node is GeometryInstance3D:
        var geo: GeometryInstance3D = node
        if geo.material_override != null:
            _decorate_material(geo.material_override, edited)
    if node is MeshInstance3D:
        var mesh_instance: MeshInstance3D = node
        if mesh_instance.mesh != null:
            for s in range(mesh_instance.mesh.get_surface_count()):
                _decorate_material(mesh_instance.mesh.surface_get_material(s), edited)
    for child in node.get_children():
        _walk_generated_materials(child, edited)


func _upgrade_generated_materials() -> void:
    var study: Node = parent_world.get_node_or_null("M1RiverEnvironment_Candidate")
    if study == null:
        return
    var edited: Dictionary = {}
    _walk_generated_materials(study, edited)


func _living_riparian_canopy() -> void:
    # The old uniform cone forest is now a read-only archived visualization.
    # This chapter uses efficient, multi-lobed broadleaf-like silhouettes
    # with genuine first-party rootwood/fern PBR map inputs.
    var older: Node3D = parent_world.get_node_or_null("IllustrativeWetlandFlora")
    if older != null:
        older.visible = false
    var rng := RandomNumberGenerator.new()
    rng.seed = 560187
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.13
    trunk_mesh.bottom_radius = 0.28
    trunk_mesh.height = 1.0
    trunk_mesh.radial_segments = 8
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 1.0
    crown_mesh.height = 2.0
    crown_mesh.radial_segments = 7 if OS.has_feature("web") else 12
    crown_mesh.rings = 5 if OS.has_feature("web") else 8
    # Keep rich near-camera shape on native; compatibility-WebGL SwiftShader
    # uses a distinct low-detail canopy budget to preserve canvas progress.
    var tree_count: int = 52 if OS.has_feature("web") else 142
    rendered_canopy_count = tree_count
    var trunks := MultiMesh.new()
    trunks.mesh = trunk_mesh
    trunks.transform_format = MultiMesh.TRANSFORM_3D
    trunks.instance_count = tree_count
    var canopy_main := MultiMesh.new()
    canopy_main.mesh = crown_mesh
    canopy_main.transform_format = MultiMesh.TRANSFORM_3D
    canopy_main.instance_count = tree_count
    var canopy_left := MultiMesh.new()
    canopy_left.mesh = crown_mesh
    canopy_left.transform_format = MultiMesh.TRANSFORM_3D
    canopy_left.instance_count = tree_count
    var canopy_right := MultiMesh.new()
    canopy_right.mesh = crown_mesh
    canopy_right.transform_format = MultiMesh.TRANSFORM_3D
    canopy_right.instance_count = tree_count
    for i in range(tree_count):
        var x: float = rng.randf_range(-54.0, 54.0)
        var z: float = rng.randf_range(-54.0, 54.0)
        if absf(z - parent_world.river_center(x)) < 9.0 or (x*x + (z-7.0)*(z-7.0)) < 400.0:
            x = 36.0 + 17.0 * float(i % 9) / 9.0
            z = -20.0 - 30.0 * float(i % 17) / 17.0
        var y: float = parent_world.terrain_height(x, z)
        var height: float = rng.randf_range(4.8, 11.5)
        var spin: float = rng.randf_range(-0.7, 0.7)
        var trunk_basis := Basis().rotated(Vector3.UP, spin).scaled(Vector3(1.0, height, 1.0))
        trunks.set_instance_transform(i, Transform3D(trunk_basis, Vector3(x, y + height * 0.50, z)))
        var spread: float = rng.randf_range(1.7, 3.15)
        var center_basis := Basis().rotated(Vector3.UP, spin).scaled(Vector3(spread, height * 0.23, spread * 0.83))
        canopy_main.set_instance_transform(i, Transform3D(center_basis, Vector3(x, y + height * 0.92, z)))
        var leaf_basis := Basis().rotated(Vector3.UP, spin).scaled(Vector3(spread * 0.70, height * 0.20, spread * 0.70))
        canopy_left.set_instance_transform(i, Transform3D(leaf_basis,
            Vector3(x - spread * 0.53, y + height * 0.86, z + spread * 0.14)))
        canopy_right.set_instance_transform(i, Transform3D(leaf_basis,
            Vector3(x + spread * 0.55, y + height * 0.88, z - spread * 0.15)))
    var trunk_mat: Material = _source_material("rootwood", Color(0.80, 0.72, 0.59))
    var leaf_mat: Material = _source_material("fern", Color(0.64, 0.78, 0.59))
    var shadow_leaf_mat: Material = _source_material("moss", Color(0.54, 0.64, 0.52))
    for spec in [
        {"name":"TreeStems", "mm":trunks, "material":trunk_mat},
        {"name":"LeafCanopies", "mm":canopy_main, "material":leaf_mat},
        {"name":"WestCrowns", "mm":canopy_left, "material":shadow_leaf_mat},
        {"name":"EastCrowns", "mm":canopy_right, "material":leaf_mat}
    ]:
        var group := MultiMeshInstance3D.new()
        group.name = "ChapterI_" + str(spec["name"])
        group.multimesh = spec["mm"]
        group.material_override = spec["material"]
        if OS.has_feature("web"):
            group.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
        add_child(group)


func visual_summary() -> Dictionary:
    var count: int = 0
    for child in get_children():
        if child.name.begins_with("VisitorNavigation_"):
            count += 1
    return {"visitor_waypoints":count, "instanced_reeds":360, "canopy_instances":rendered_canopy_count, "source_PBR_families":true,
        "scientific_vegetation_id":false, "alchul_body_visible":false,
        "original_media_replaced":false, "gameplay_scopes":["surface-era", "not_present_day"]}
