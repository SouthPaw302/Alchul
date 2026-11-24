extends "res://scripts/t21_living_systems_scene.gd"

## ALCHUL T21.2 — a separate, responsive 3D process terrace.
## Deliberately inherits the verified T21.1 eight-watch state machine unchanged.
## Process models: visible water, adjustable relief, filtration, cultures, thermal
## nursery, venting, bracing, stored supplies and ongoing tool/carrier movements.
## This is a functional theatrical exhibit of indigenous technologies, not a
## fluid solver, clinical incubation simulator, historical reconstruction, or
## approved character/body model.

const TERRACE_STATUS: String = "FICTIONAL_MATURE_SURFACE_PROCESS_VISUALIZATION_NOT_CALIBRATED"
const WATER: Color = Color(0.20, 0.63, 0.76)
const REED: Color = Color(0.51, 0.67, 0.35)
const ROOT: Color = Color(0.44, 0.32, 0.21)
const CLAY: Color = Color(0.43, 0.40, 0.31)
const CULTURE: Color = Color(0.52, 0.75, 0.42)
const WARM: Color = Color(0.98, 0.56, 0.25)
const FILTERED: Color = Color(0.40, 0.80, 0.82)
const PALE: Color = Color(0.81, 0.79, 0.61)

var terrace: Node3D
var process_nodes: Dictionary = {}
var water_drops: Array[MeshInstance3D] = []
var gas_bubbles: Array[MeshInstance3D] = []
var heat_stones: Array[MeshInstance3D] = []
var culture_vats: Array[MeshInstance3D] = []
var route_posts: Array[MeshInstance3D] = []
var labor_frame: Node3D
var screen_filter: Node3D
var relief_water: MeshInstance3D
var brace_support: Node3D
var vent_lid: Node3D
var nursery_canopy: Node3D
var process_clock: float = 0.0
var visible_process_count: int = 0


func _ready() -> void:
    super._ready()
    _build_living_processes()
    # Keep the existing first-party M2 geometry. The separate explanatory
    # terrace is on its near river margin, not claimed to be original M2 mesh.
    camera.position = source_center + Vector3(
        source_span * 0.47, source_span * 0.44, source_span * 0.72)
    camera.look_at(source_center + Vector3(
        0.0, source_span * 0.045, source_span * 0.19))
    camera.make_current()
    _update_hud()


func _glowing(tint: Color, power: float) -> StandardMaterial3D:
    var m: StandardMaterial3D = _surface(tint)
    m.emission_enabled = true
    m.emission = tint
    m.emission_energy_multiplier = power
    return m


func _sphere(parent: Node3D, name: String, at: Vector3,
        radius: float, tint: Color, stretch: Vector3 = Vector3.ONE) -> MeshInstance3D:
    var shape := SphereMesh.new()
    shape.radius = radius
    shape.height = radius * 2.0
    shape.radial_segments = 12
    shape.rings = 6
    var part := MeshInstance3D.new()
    part.name = name
    part.mesh = shape
    part.position = at
    part.scale = stretch
    part.material_override = _surface(tint)
    parent.add_child(part)
    return part


func _cylinder(parent: Node3D, name: String, at: Vector3, radius: float,
        length: float, tint: Color) -> MeshInstance3D:
    var shape := CylinderMesh.new()
    shape.top_radius = radius
    shape.bottom_radius = radius
    shape.height = length
    shape.radial_segments = 10
    var part := MeshInstance3D.new()
    part.name = name
    part.mesh = shape
    part.position = at
    part.material_override = _surface(tint)
    parent.add_child(part)
    return part


func _timber(parent: Node3D, name: String, a: Vector3, b: Vector3,
        radius: float, tint: Color = ROOT) -> MeshInstance3D:
    var delta: Vector3 = b - a
    var part: MeshInstance3D = _cylinder(parent, name, (a + b) * 0.5,
        radius, delta.length(), tint)
    if delta.length() > 0.0001:
        part.quaternion = Quaternion(Vector3.UP, delta.normalized())
    return part


func _inscription(parent: Node3D, title: String, at: Vector3, tint: Color) -> Label3D:
    var caption := Label3D.new()
    caption.text = title
    caption.font_size = 26
    caption.pixel_size = 0.008
    caption.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    caption.modulate = tint
    caption.position = at
    parent.add_child(caption)
    return caption


func _site(name: String, center: Vector3, color: Color) -> Node3D:
    var station := Node3D.new()
    station.name = name + "_DemonstrationNotOriginalAsset"
    station.position = center
    terrace.add_child(station)
    _box(station, "RaisedSedimentAndCultivatedRootPad", Vector3.ZERO,
        Vector3(3.25, 0.16, 3.55), color)
    for i in range(6):
        var w: float = float(i) / 5.0
        _timber(station, "EdgeRoot_%02d" % i,
            Vector3(-1.5, 0.15, -1.55 + w * 3.1),
            Vector3(1.5, 0.15, -1.40 + w * 2.8),
            0.025, ROOT)
    process_nodes[name] = station
    visible_process_count += 1
    return station


func _build_living_processes() -> void:
    terrace = Node3D.new()
    terrace.name = "T21P2_VisibleProcessTerrace_OriginalM2Preserved"
    terrace.position = source_center + Vector3(
        0.0, source_span * 0.10, source_span * 0.27)
    terrace.scale = Vector3.ONE * clampf(source_span * 0.040, 0.72, 4.0)
    add_child(terrace)

    _bank()
    _culture_ground()
    _nursery()
    _workshop()
    _transit()
    _exchange_reeds()


func _bank() -> void:
    var site: Node3D = _site("bank", Vector3(-5.25, 0.0, -0.15),
        Color(0.27, 0.36, 0.31))
    _inscription(site, "01  /  READ THE BANK", Vector3(0, 2.55, -1.58), PALE)
    _box(site, "ActiveSideChannel", Vector3(0, 0.17, -0.28),
        Vector3(3.02, 0.10, 0.79), WATER)
    for i in range(7):
        _timber(site, "RaisedLivingBank_%02d" % i,
            Vector3(-1.43 + float(i) * 0.45, 0.14, 0.35),
            Vector3(-1.15 + float(i) * 0.45, 0.65, 1.25), 0.075, ROOT)
    _timber(site, "ListeningStaveA", Vector3(-0.85, 0.24, -0.65),
        Vector3(-0.74, 1.40, -0.85), 0.050, PALE)
    _timber(site, "ListeningStaveB", Vector3(-0.18, 0.24, -0.65),
        Vector3(-0.08, 1.20, -0.85), 0.050, PALE)
    brace_support = Node3D.new()
    brace_support.name = "PhysicalSeamBrace_NotTelekinesis"
    site.add_child(brace_support)
    _timber(brace_support, "LongBrace", Vector3(0.26,0.28,1.2),
        Vector3(0.83,1.6,1.00), 0.11, PALE)
    _timber(brace_support, "CrossWedge", Vector3(0.45,0.57,0.80),
        Vector3(1.2,0.57,0.45), 0.10, ROOT)
    brace_support.visible = false

    relief_water = _box(site, "SacrificialReliefChannel", Vector3(0.75,0.20,0.77),
        Vector3(0.56,0.045,1.25), Color(0.17,0.31,0.33))
    for i in range(9):
        var particle: MeshInstance3D = _sphere(site, "RiverFlux_%02d" % i,
            Vector3.ZERO, 0.062, FILTERED)
        particle.material_override = _glowing(FILTERED, 0.30)
        water_drops.append(particle)
    _inscription(site, "STAKE  /  SEAM  /  DIVERSION",
        Vector3(0, 0.50, 1.46), Color(0.85,0.90,0.79))


func _culture_ground() -> void:
    var site: Node3D = _site("culture", Vector3(-1.75,0.0,-0.15),
        Color(0.31,0.40,0.29))
    _inscription(site, "02  /  KEEP THE CULTURES",
        Vector3(0,2.55,-1.58), PALE)

    for i in range(4):
        var x: float = -0.87 + float(i % 2) * 1.70
        var z: float = -0.76 + float(i / 2) * 1.57
        _cylinder(site, "LivingCultureVessel_%02d" % i,
            Vector3(x,0.39,z),0.48,0.60,ROOT)
        var surface: MeshInstance3D = _cylinder(site, "CulturedBiomass_%02d" % i,
            Vector3(x,0.73,z),0.39,0.07,CULTURE)
        culture_vats.append(surface)
        for j in range(5):
            var angle: float = float(j) * TAU / 5.0
            _timber(site, "VesselReed_%02d_%02d" % [i,j],
                Vector3(x + cos(angle)*0.42,0.18,z+sin(angle)*0.42),
                Vector3(x + cos(angle)*0.42,0.65,z+sin(angle)*0.42),
                0.035,PALE)

    screen_filter = Node3D.new()
    screen_filter.name = "ReplaceableReedFilter_Intake"
    site.add_child(screen_filter)
    for i in range(12):
        var x: float = -1.26 + float(i)*0.23
        _timber(screen_filter,"ScreenReed_%02d" % i,
            Vector3(x,0.16,-1.28),Vector3(x,1.19,-1.28),0.045,REED)
    screen_filter.visible = false
    _box(site,"CultureDrawChannel",Vector3(0,0.20,-1.39),
        Vector3(2.75,0.05,0.17),Color(0.27,0.58,0.59))
    _inscription(site,"FILTERED WATER  /  PRESERVED FOOD",
        Vector3(0,0.60,1.47),Color(0.85,0.90,0.79))


func _nursery() -> void:
    var site: Node3D = _site("nursery", Vector3(1.75,0.0,-0.15),
        Color(0.38,0.35,0.26))
    _inscription(site,"03  /  PROTECT THE YOUNG",
        Vector3(0,2.55,-1.58),PALE)
    nursery_canopy = Node3D.new()
    nursery_canopy.name = "ControlledDraftRootCanopy"
    site.add_child(nursery_canopy)
    for i in range(9):
        var x: float = -1.35 + float(i)*0.3375
        _timber(nursery_canopy,"RoofRib_%02d" % i,
            Vector3(x,0.16,-1.10),Vector3(x*0.75,2.1,0.13),
            0.070,ROOT)
        _timber(nursery_canopy,"RoofReturn_%02d" % i,
            Vector3(x*0.75,2.1,0.13),Vector3(x,0.18,1.05),
            0.070,ROOT)
    for i in range(3):
        var xx: float = -0.78 + float(i)*0.78
        _box(site,"WarmIncubationBed_%02d" % i,
            Vector3(xx,0.42,0.0),Vector3(0.68,0.19,0.70),ROOT)
        var egg: MeshInstance3D = _sphere(site,"ProtectedExternalEgg_%02d" % i,
            Vector3(xx,0.76,0.0),0.25,PALE,Vector3(0.8,1.27,0.83))
        egg.material_override = _surface(PALE)
    for i in range(6):
        var x: float = -1.22 + float(i) * 0.49
        var stone: MeshInstance3D = _box(site,"ThermalReserveStone_%02d" % i,
            Vector3(x,0.24,-1.36),Vector3(0.37,0.22,0.30),WARM)
        heat_stones.append(stone)
    for i in range(7):
        var post: MeshInstance3D = _box(site,"CheckedEvacuationRoute_%02d" % i,
            Vector3(-1.36 + float(i)*0.45,0.23,1.40),
            Vector3(0.32,0.04,0.20),Color(0.38,0.43,0.37))
        route_posts.append(post)
    _inscription(site,"GENTLE HEAT  /  CLEAR RETURN",
        Vector3(0,0.51,1.64),Color(0.85,0.90,0.79))


func _workshop() -> void:
    var site: Node3D = _site("workshop",Vector3(5.25,0.0,-0.15),
        Color(0.39,0.35,0.29))
    _inscription(site,"04  /  WORK THE SEAM",
        Vector3(0,2.55,-1.58),PALE)
    _box(site,"FracturedMineralWorkBed",Vector3(0,0.30,-0.10),
        Vector3(2.30,0.26,1.40),CLAY)
    for i in range(5):
        _timber(site,"DemonstrationCrack_%02d" % i,
            Vector3(-0.92+float(i)*0.36,0.45,-0.55),
            Vector3(-0.75+float(i)*0.41,0.45,0.42),0.014,
            Color(0.18,0.19,0.17))
    for i in range(4):
        _timber(site,"WorkedTimberTool_%02d" % i,
            Vector3(-0.82+float(i)*0.52,0.60,-0.15),
            Vector3(-0.88+float(i)*0.52,1.25,0.12),0.055,PALE)
    _cylinder(site,"CoveredVentShaft",Vector3(1.05,0.95,-0.70),
        0.24,1.6,ROOT)
    vent_lid = Node3D.new()
    vent_lid.name = "OpenedDraftOutlet"
    vent_lid.position = Vector3(1.05,1.78,-0.70)
    site.add_child(vent_lid)
    _box(vent_lid,"StoneFlueCap",Vector3.ZERO,
        Vector3(0.63,0.10,0.55),PALE)
    for i in range(7):
        var bubble: MeshInstance3D = _sphere(site,"ChamberAirTrail_%02d" % i,
            Vector3.ZERO,0.065,Color(0.73,0.80,0.61))
        bubble.material_override = _glowing(Color(0.74,0.80,0.62),0.18)
        gas_bubbles.append(bubble)
    _inscription(site,"WEDGE  /  LOAD  /  VENT",
        Vector3(0,0.52,1.46),Color(0.85,0.90,0.79))


func _transit() -> void:
    var board := Node3D.new()
    board.name = "MaintainedTransportNotBodyModel"
    terrace.add_child(board)
    # A removable low frame shows carried material; we intentionally do not
    # pretend its abstract motion certifies humanoid or saurian anatomy.
    _timber(board,"LongRouteRootA",
        Vector3(-3.90,0.16,2.03),Vector3(3.90,0.16,2.03),0.083,ROOT)
    _timber(board,"LongRouteRootB",
        Vector3(-3.90,0.16,2.61),Vector3(3.90,0.16,2.61),0.083,ROOT)
    for i in range(14):
        var x: float = -3.70 + float(i)*0.57
        _timber(board,"FootingCrosspiece_%02d" % i,
            Vector3(x,0.19,1.98),Vector3(x+0.08,0.19,2.62),0.043,REED)
    labor_frame = Node3D.new()
    labor_frame.name = "SharedMaterialTransportActivityMarker_NotCreature"
    board.add_child(labor_frame)
    _timber(labor_frame,"CarrierRailA",
        Vector3(-0.43,0,0),Vector3(0.43,0,0),0.060,PALE)
    _timber(labor_frame,"CarrierRailB",
        Vector3(-0.43,0,0.32),Vector3(0.43,0,0.32),0.060,PALE)
    _box(labor_frame,"CarriedFoodOrWarmMaterial",
        Vector3(0,0.15,0.17),Vector3(0.49,0.27,0.27),CULTURE)
    visible_process_count += 1


func _exchange_reeds() -> void:
    var node := Node3D.new()
    node.name = "CommunicationThroughResonanceAndMaintainedMarkers"
    terrace.add_child(node)
    for i in range(5):
        var x: float = -4.5 + float(i)*2.2
        _timber(node,"NonHumanSharedSignalMarker_%02d" % i,
            Vector3(x,0.14,-2.02),Vector3(x,1.27,-2.02),
            0.035,PALE)
        _sphere(node,"Resonator_%02d" % i,
            Vector3(x,1.25,-2.02),0.12,Color(0.78,0.58,0.32))
    visible_process_count += 1


func _update_hud() -> void:
    super._update_hud()
    if title_text != null:
        title_text.text = "ALCHUL  /  T21.2  —  A WORKING DAY AT THE BRAIDED REACH  |  WATCH %d / 8" % turn
    if provenance_text != null:
        provenance_text.text = "Visible native craft and ecological processes • original M2 behind an interpretive terrace • no approved species bodies"
    _refresh_processes()


func _refresh_processes() -> void:
    if terrace == null or config.is_empty():
        return
    var relieved: bool = int(uses.get("relief",0)) > 0
    var screened: bool = int(uses.get("screen",0)) > 0
    var braced: bool = int(uses.get("brace",0)) > 0
    var vented: bool = int(uses.get("vent",0)) > 0
    var warmed: bool = int(uses.get("warm",0)) > 0
    var stored: bool = int(uses.get("store",0)) > 0
    brace_support.visible = braced
    screen_filter.visible = screened
    relief_water.material_override = _glowing(WATER,0.6) if relieved else _surface(Color(0.17,0.31,0.33))
    relief_water.scale.y = 1.0 if relieved else 0.35
    vent_lid.rotation_degrees.z = 34.0 if vented else 0.0
    vent_lid.position.y = 1.90 if vented else 1.78
    for i in range(culture_vats.size()):
        var vat: MeshInstance3D = culture_vats[i]
        var spoiled: bool = relieved and i > 1 and not stored
        vat.material_override = _surface(Color(0.42,0.30,0.21)) if spoiled else (
            _glowing(CULTURE,0.30) if stored else _surface(CULTURE))
    for stone in heat_stones:
        var strength: float = clampf(float(state.get("nursery",50))/100.0,0.0,1.0)
        stone.material_override = _glowing(WARM.lerp(Color(0.28,0.29,0.30),1.0-strength),
            0.15+strength*0.75) if warmed else _surface(WARM.lerp(CLAY,0.75))
    for post in route_posts:
        post.material_override = _glowing(Color(0.42,0.85,0.66),0.50) if (
            bool(state.get("route_safe",false))) else _surface(Color(0.38,0.43,0.37))
    _animate_material_flows()


func _animate_material_flows() -> void:
    if terrace == null or config.is_empty():
        return
    var bank: Node3D = process_nodes["bank"]
    for i in range(water_drops.size()):
        var point: MeshInstance3D = water_drops[i]
        var fraction: float = fposmod(
            process_clock*0.22*(0.5+float(state.get("pressure",0.0))/80.0)
            +float(i)/float(water_drops.size()), 1.0)
        point.position = Vector3(-1.40 + fraction*2.85,0.31,-0.29
            +sin(fraction*TAU)*0.11)
        point.scale = Vector3.ONE * (0.65+float(state.get("pressure",0.0))/140.0)
        if point.get_parent() != bank:
            push_error("T21.2 water particle left its physical channel")
    for i in range(gas_bubbles.size()):
        var bubble: MeshInstance3D = gas_bubbles[i]
        var rise: float = fposmod(process_clock*(0.45 if int(uses.get("vent",0))>0 else 0.16)
            +float(i)*0.18,1.0)
        bubble.position = Vector3(1.05 + sin(rise*4.0+float(i))*0.12,
            1.80+rise*1.18,-0.70+cos(rise*4.0)*0.12)
        bubble.visible = int(uses.get("vent",0))>0 or float(state.get("gas",0))>24.0
        bubble.scale = Vector3.ONE * (0.42+rise*1.25)
    if labor_frame != null:
        labor_frame.position = Vector3(sin(process_clock*0.32)*2.9,0.42,2.15)


func _process(delta: float) -> void:
    process_clock += minf(delta,0.15)
    _animate_material_flows()


func living_process_report() -> Dictionary:
    return {
        "status":TERRACE_STATUS,
        "historical_era":"mature_surface_pre_long_descent",
        "original_m2_loaded":original_mesh_count>0,
        "uses_existing_eight_watch_system":turn<=int(config.get("max_watches",0)),
        "process_sites":process_nodes.size(),
        "process_groups":visible_process_count,
        "river_particles":water_drops.size(),
        "vessel_count":culture_vats.size(),
        "vent_particles":gas_bubbles.size(),
        "nursery_thermal_stones":heat_stones.size(),
        "route_markers":route_posts.size(),
        "relief_visible":int(uses.get("relief",0))>0,
        "filter_installed":int(uses.get("screen",0))>0,
        "brace_installed":int(uses.get("brace",0))>0,
        "vent_open":int(uses.get("vent",0))>0,
        "stored_material_saved":int(uses.get("store",0))>0,
        "checked_route_lit":bool(state.get("route_safe",false)),
        "anatomically_approved_characters":false,
        "activity_carrier_is_not_an_actor":true,
        "true_hydraulic_solver":false,
        "influence_is_an_engineering_cause":false,
        "public_chapter_modified":false
    }
