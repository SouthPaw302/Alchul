extends Node3D
const Kit = preload("res://scripts/surface_zenith_assets.gd")
var kit = Kit.new()
var assets: Dictionary = {}
var camera: Camera3D
var title: Label
var current_view: int = 0
var placed: int = 0
var imported: int = 0
var source_assets: Node3D
var views: Array = [
    ["01_adult","Individual / mature adult",Vector3(4.2,2.6,5.3),Vector3(0,1.25,0)],
    ["02_city","The Braided Reach / city panorama",Vector3(31,25,39),Vector3(0,1,-3)],
    ["03_river","Riverbank / cooperative engineering",Vector3(13,4.5,9),Vector3(9,0.8,-2)],
    ["04_nursery","Nursery / external development",Vector3(-13,3.1,8),Vector3(-10,0.8,4)],
    ["05_culture","Culture grounds / fermentation",Vector3(5,3.9,15),Vector3(3,1,9)],
    ["06_craft","Workshop / material knowledge",Vector3(-6,3.2,-9),Vector3(-3,1,-13)],
    ["07_bridge","Living roots / shared routes",Vector3(12,5.5,-12),Vector3(0,0.8,-4)],
    ["08_learning","Daily life / intergenerational learning",Vector3(-18,3.7,1),Vector3(-12,1,-2)],
    ["09_gardens","Cultivation / river terraces",Vector3(19,7,21),Vector3(11,1,11)],
    ["10_hall","Civic architecture / living hall",Vector3(0,7,-26),Vector3(0,2,-16)]
]

func _ready() -> void:
    source_assets = Node3D.new()
    source_assets.name = "AssetTemplates"
    # Exported GLBs can be supplied with ALCHUL_ZENITH_GLB_DIR; use actual round-trips for CI.
    var dir: String = OS.get_environment("ALCHUL_ZENITH_GLB_DIR")
    if dir.is_empty():
        assets = kit.catalog(source_assets)
    else:
        for id in ["adult","adult_slate","juvenile","hall","bridge","culture_vessel","nursery","workbench","plant","bank"]:
            var doc := GLTFDocument.new()
            var state := GLTFState.new()
            if doc.append_from_file(dir.path_join(id+".glb"),state) != OK:
                push_error("Missing exported GLB "+id)
                continue
            var scene: Node = doc.generate_scene(state)
            if scene is Node3D:
                source_assets.add_child(scene)
                assets[id] = scene
                imported += 1
    _environment()
    _world()
    _overlay()
    set_view(0)

func _exit_tree() -> void:
    if is_instance_valid(source_assets):
        source_assets.free()

func instance(id: String, p: Vector3, s: float = 1.0, yaw: float = 0.0) -> Node3D:
    if not assets.has(id):
        return null
    var copy: Node3D = assets[id].duplicate() as Node3D
    add_child(copy,true)
    copy.position = p
    copy.scale = Vector3.ONE*s
    copy.rotation.y = yaw
    placed += 1
    return copy

func _environment() -> void:
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("b9d1ce")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("e5dac2")
    env.ambient_light_energy = 0.55
    env.fog_enabled = true
    env.fog_light_color = Color("c6d9d5")
    env.fog_density = 0.008
    var we := WorldEnvironment.new()
    we.environment = env
    add_child(we)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-43,-34,0)
    sun.light_color = Color("ffe3b4")
    sun.light_energy = 1.35
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 90
    add_child(sun)
    camera = Camera3D.new()
    camera.fov = 48
    camera.far = 180
    add_child(camera)
    camera.current = true

func _world() -> void:
    var terrain := kit.node(self,"TerrainAndWater")
    kit.box(terrain,"Ground",Vector3(0,-0.77,0),Vector3(85,0.5,85),Color("687d44"))
    # A distinct river ribbon at x=0; land terraces on both sides.
    kit.box(terrain,"RiverSurface",Vector3(0,-0.23,0),Vector3(6.8,0.06,77),Kit.WATER)
    for x in [-10.5,10.5]:
        kit.box(terrain,"MainTerrace",Vector3(x,-0.20,0),Vector3(14,0.4,50),Color("9c967b"))
        kit.box(terrain,"UpperTerrace",Vector3(x*1.72,0.38,-1),Vector3(5,1.05,40),Kit.STONE)
        kit.box(terrain,"UpperGardens",Vector3(x*1.72,0.94,-1),Vector3(5,0.13,40),Kit.LEAF.darkened(0.22))
    for z in range(-22,24,8):
        instance("bank",Vector3(3.8,-0.22,z),1.0,PI/2)
        instance("bank",Vector3(-3.8,-0.22,z),1.0,-PI/2)
    for z in [-14.0,-4.0,12.0]:
        instance("bridge",Vector3(0,0.1,z),1.0,0)
    for p in [Vector3(-11,0,-15),Vector3(10,0,-15),Vector3(-10,0,7),Vector3(11,0,13),Vector3(-11,0,-3)]:
        instance("hall",p,1.0,0)
    instance("hall",Vector3(0,0,-19),1.55,0)
    # The portrait platform is a separate observation garden beside the central bridge.
    kit.box(terrain,"PortraitStone",Vector3(0,-0.03,0),Vector3(4.8,0.35,4.5),Kit.STONE)
    instance("adult",Vector3(0,0.15,0),1.0,0.15)
    # River crew, care court, culture stations, craft tables and learning circle.
    for p in [Vector3(7,0,-2),Vector3(10,0,-3),Vector3(12,0,-1)]:
        instance("adult_slate",p,0.94,-0.6)
    instance("nursery",Vector3(-10,0,4))
    instance("nursery",Vector3(-12,0,5.4),0.9)
    instance("adult_slate",Vector3(-11.7,0,3.3),1.0,-0.3)
    instance("juvenile",Vector3(-9,0,4.7),0.53,PI)
    instance("juvenile",Vector3(-8.2,0,5.6),0.48,2.2)
    for i in range(5):
        instance("culture_vessel",Vector3(4.2+float(i%2)*1.5,0,8.3+float(i/2)*1.3),0.85+float(i%3)*0.12)
    instance("adult",Vector3(4,0,10.7),1.0,0)
    instance("adult_slate",Vector3(7,0,9.5),0.9,PI)
    instance("juvenile",Vector3(6.2,0,11.4),0.6,-2.5)
    for x in [-5.0,-8.0]:
        instance("workbench",Vector3(x,0,-13))
    instance("adult",Vector3(-5.2,0,-12.2),0.95,-PI/2)
    instance("adult_slate",Vector3(-7.9,0,-12.0),0.93,-PI/2)
    instance("workbench",Vector3(-12,0,-2))
    instance("adult_slate",Vector3(-13.7,0,-2),1.08,0)
    for i in range(3):
        instance("juvenile",Vector3(-10.2-float(i)*0.6,0,-0.5+float(i)*0.5),0.58,-2.1)
    for i in range(12):
        var x: float = 8+float(i%4)*1.35
        var z: float = 10+float(i/4)*1.45
        kit.box(terrain,"RaisedGrowingBed",Vector3(x,0.10,z),Vector3(1.18,0.20,1.23),Kit.BARK)
        instance("plant",Vector3(x,0.22,z),0.70,float(i))
    for i in range(6):
        instance("adult_slate" if i%2==0 else "adult",Vector3(-4.4+float(i)*1.75,0,-17.3),0.85,PI/2)
    var rng := RandomNumberGenerator.new()
    rng.seed = 70000000
    for i in range(42):
        var s: float = -1.0 if i%2==0 else 1.0
        var p := Vector3(s*rng.randf_range(15.8,23.5),1.03,rng.randf_range(-24,24))
        instance("plant",p,rng.randf_range(0.8,1.45),rng.randf_range(0,TAU))
    for i in range(25):
        var s: float = -1.0 if i%2==0 else 1.0
        var p := Vector3(s*rng.randf_range(22,38),-0.5,rng.randf_range(-34,34))
        var height: float = rng.randf_range(5,10)
        kit.limb(terrain,"ConiferTrunk",p,p+Vector3(0,height,0),0.42,0.16,Kit.BARK)
        for j in range(4):
            var h: float = height*(0.55+float(j)*0.13)
            var radius: float = 2.25-float(j)*0.42
            kit.oval(terrain,"Canopy",p+Vector3(0,h,0),Vector3(radius,1.2,radius),Kit.DARK_LEAF.lightened(float(j)*0.045))

func _overlay() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var bg := ColorRect.new()
    bg.position = Vector2(0,0)
    bg.size = Vector2(1280,70)
    bg.color = Color(0.03,0.06,0.055,0.88)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(bg)
    title = Label.new()
    title.position = Vector2(20,9)
    title.add_theme_font_size_override("font_size",22)
    layer.add_child(title)
    var note := Label.new()
    note.position = Vector2(20,40)
    note.text = "70 Ma / fictional mature-surface study / static concept-derived mesh proxies / Left-Right: camera"
    note.add_theme_font_size_override("font_size",15)
    layer.add_child(note)

func set_view(i: int) -> void:
    current_view = posmod(i,views.size())
    var v: Array = views[current_view]
    camera.position = v[2]
    camera.look_at(v[3],Vector3.UP)
    title.text = "ALCHUL / SURFACE ZENITH     " + str(v[1])

func _unhandled_key_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_RIGHT:
            set_view(current_view+1)
        elif event.keycode == KEY_LEFT:
            set_view(current_view-1)
