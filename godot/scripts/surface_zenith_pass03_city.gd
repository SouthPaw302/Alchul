extends "res://scripts/surface_zenith_fidelity_city.gd"
const Binder = preload("res://scripts/surface_zenith_pass03_skin.gd")
var living_actors: Array[Node3D] = []
var binding_reports: Array = []
var terrain_mesh: MeshInstance3D
var motion_time: float = 0.0

func _ready() -> void:
    super._ready()
    _natural_terrain()
    _forest_edges()
    _bind_residents()
    set_view(0)
    study_overlay.text = "Pass 03: weighted residents / A: original T16 study / Left-Right: cameras"

func _natural_terrain() -> void:
    var root_node: Node3D = get_node("TerrainAndWater")
    var ground: Node3D = root_node.get_node("Ground")
    ground.visible = false
    var noise := FastNoiseLite.new()
    noise.seed = 700030
    noise.frequency = 0.057
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    st.set_smooth_group(0)
    var n: int = 96
    for z in range(n):
        for x in range(n):
            var p: Array = []
            for d in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,1)]:
                var xx: float = -48.0+float(x+d.x)
                var zz: float = -48.0+float(z+d.y)
                var edge: float = smoothstep(18.0,37.0,absf(xx))
                var outside: float = maxf(edge,smoothstep(25.0,44.0,absf(zz)))
                var y: float = -0.48+outside*(2.5+noise.get_noise_2d(xx,zz)*4.5)+noise.get_noise_2d(xx*2.0,zz*2.0)*0.14
                if absf(xx)<4.0:
                    y = -0.67
                p.append(Vector3(xx,y,zz))
            for i in [0,1,2,0,2,3]:
                var v: Vector3 = p[i]
                st.set_uv(Vector2(v.x,v.z)*0.13)
                st.add_vertex(v)
    st.index()
    st.generate_normals()
    st.generate_tangents()
    terrain_mesh = kit.mesh(root_node,"ContinuousIrregularLandscape",st.commit(),Vector3.ZERO,Kit.LEAF.darkened(0.12))
    # Keep the inhabited terrace foundations but soften their visible borders.
    for side in [-1.0,1.0]:
        for i in range(40):
            var z: float = -24.0+float(i)*1.2
            var x: float = side*(17.0+0.7*sin(z*0.34))
            kit.oval(root_node,"IrregularTerraceEdge",Vector3(x,0.03,z),Vector3(0.86,0.38+0.13*cos(z),0.83),Kit.STONE.darkened(0.10+float(i%4)*0.03))
    for i in range(12):
        var z: float = -22.0+float(i)*4.0
        for s in [-1.0,1.0]:
            var p := Vector3(s*3.28,-0.05,z)
            kit.oval(root_node,"WetBankBoulder",p,Vector3(0.49,0.28,0.81),Kit.STONE.darkened(0.13),0.55)

func _forest_edges() -> void:
    var forest := kit.node(self,"MatureForestStudy")
    var rng := RandomNumberGenerator.new()
    rng.seed = 703003
    for i in range(32):
        var side: float = -1.0 if i%2==0 else 1.0
        var p := Vector3(side*rng.randf_range(21.5,40),0.4,rng.randf_range(-40,35))
        var h: float = rng.randf_range(7.0,13.0)
        var crown: Vector3 = p+Vector3(rng.randf_range(-0.8,0.8),h,rng.randf_range(-0.8,0.8))
        kit.curve(forest,"TaperedConifer",[p,p.lerp(crown,0.25)+Vector3(0.2,0,0),p.lerp(crown,0.7),crown],0.48,0.09,Kit.BARK)
        for j in range(5):
            var t: float = 0.45+float(j)*0.11
            var center: Vector3 = p.lerp(crown,t)
            for k in range(3):
                var a: float = TAU*float(k)/3.0+float(j)*0.7
                var radius: float = (1.0-t)*4.0
                var tip: Vector3 = center+Vector3(cos(a)*radius,0.45,sin(a)*radius)
                kit.limb(forest,"Branch",center,tip,0.085,0.025,Kit.WOOD)
                kit.oval(forest,"NeedleCrown",tip,Vector3(radius*0.7,0.65,radius*0.7),Kit.DARK_LEAF.lightened(float(j%3)*0.045))
    for child in get_children():
        if child is WorldEnvironment:
            child.environment.fog_density = 0.010
            child.environment.fog_light_color = Color("c5d6c4")
        if child is DirectionalLight3D:
            child.rotation_degrees = Vector3(-35,-46,0)
            child.light_color = Color("ffddb0")
            child.light_energy = 1.55

func _bind_residents() -> void:
    # Reuse real T16 E2 skeletal topology, each independent actor gets its own motion phase.
    var source: Node3D = assets["adult"]
    var template: Node3D = study_rig.get_node("T07_E2")
    var placements: Array = [
        [Vector3(0,0.15,0),0.15,"rest"],
        [Vector3(7,0,-2),-0.6,"grip"],
        [Vector3(4,0,10.7),0.0,"grip"],
        [Vector3(-5.2,0,-12.2),-PI/2,"grip"],
        [Vector3(-13.7,0,-2),0.0,"communicate"]
    ]
    var prototype: Node3D = template.duplicate() as Node3D
    prototype.name = "Pass03_ResidentPrototype"
    add_child(prototype)
    prototype.position = Vector3.ZERO
    prototype.rotation = Vector3.ZERO
    prototype.scale = Vector3.ONE
    var sk: Skeleton3D = prototype.get_node("ResearchSkeleton3D")
    for i in range(sk.get_bone_count()):
        sk.set_bone_pose_rotation(i,Quaternion.IDENTITY)
        sk.set_bone_pose_position(i,sk.get_bone_rest(i).origin)
    sk.force_update_all_bone_transforms()
    for child in prototype.get_children():
        if child is Node3D and child!=sk:
            child.visible = false
    for child in sk.get_children():
        if child is Node3D:
            child.visible = false
    var binder = Binder.new()
    var report: Dictionary = binder.bind_meshes(source,prototype,sk)
    binding_reports.append(report)
    for i in range(placements.size()):
        var row: Array = placements[i]
        var pos: Vector3 = row[0]
        for old in actor_motion:
            if old.position.distance_to(pos)<0.08:
                old.visible = false
        var resident: Node3D = prototype if i==0 else prototype.duplicate() as Node3D
        if i!=0:
            add_child(resident,true)
        resident.name = "WeightedResident_%02d" % i
        resident.visible = true
        resident.scale = Vector3.ONE*binder.rest_scale
        resident.rotation.y = row[1]
        resident.position = pos+Basis(Vector3.UP,float(row[1]))*binder.rest_offset
        resident.set_meta("task",row[2])
        living_actors.append(resident)
    camera.current = true

func set_view(i: int) -> void:
    super.set_view(i)
    title.text = title.text.replace("PASS 02","PASS 03")

func toggle_rig() -> void:
    super.toggle_rig()
    if not living_actors.is_empty():
        living_actors[0].visible = not visible_t16
    if not actor_motion.is_empty():
        actor_motion[0].visible = false

func _process(delta: float) -> void:
    super._process(delta)
    motion_time += delta
    for i in range(living_actors.size()):
        var actor: Node3D = living_actors[i]
        var sk: Skeleton3D = actor.get_node("ResearchSkeleton3D")
        var phase: float = sin(motion_time*1.3+float(i)*0.91)
        var task: String = actor.get_meta("task")
        var neck: int = sk.find_bone("neck_01")
        sk.set_bone_pose_rotation(neck,Quaternion(Vector3.FORWARD,phase*0.075))
        var tail: int = sk.find_bone("caudal_01")
        sk.set_bone_pose_rotation(tail,Quaternion(Vector3.UP,phase*0.08))
        if task=="grip":
            for side in ["L","R"]:
                var arm: int = sk.find_bone("antebrachium_"+side)
                sk.set_bone_pose_rotation(arm,Quaternion(Vector3.FORWARD,-0.12+phase*0.08))
        if task=="communicate":
            var jaw: int = sk.find_bone("mandible")
            sk.set_bone_pose_rotation(jaw,Quaternion(Vector3.FORWARD,-0.06+phase*0.04))
        sk.force_update_all_bone_transforms()
