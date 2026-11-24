extends RefCounted
## Original concept-guided mesh construction. Static visual prototypes, not anatomy approval.
const BARK = Color("58432b")
const WOOD = Color("9a7143")
const REED = Color("b5a26a")
const STONE = Color("777b67")
const CLAY = Color("a45f36")
const LEAF = Color("587a35")
const DARK_LEAF = Color("274d35")
const WATER = Color("497e83")
const CREAM = Color("d2bca0")
const RUST = Color("a3532e")
const SLATE = Color("434c52")
const SKIN = Color("8c7961")
var mats: Dictionary = {}

func material(tint: Color, rough: float = 0.84) -> StandardMaterial3D:
    var key: String = str(tint) + str(rough)
    if not mats.has(key):
        var m := StandardMaterial3D.new()
        m.albedo_color = tint
        m.roughness = rough
        mats[key] = m
    return mats[key]

func node(parent: Node3D, id: String, p: Vector3 = Vector3.ZERO) -> Node3D:
    var n := Node3D.new()
    n.name = id
    parent.add_child(n, true)
    n.position = p
    return n

func mesh(parent: Node3D, id: String, shape: Mesh, p: Vector3, tint: Color, rough: float = 0.84) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = id
    n.mesh = shape
    n.material_override = material(tint, rough)
    parent.add_child(n, true)
    n.position = p
    return n

func box(parent: Node3D, id: String, p: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
    var m := BoxMesh.new()
    m.size = size
    return mesh(parent,id,m,p,tint)

func oval(parent: Node3D, id: String, p: Vector3, s: Vector3, tint: Color, rough: float = 0.84) -> MeshInstance3D:
    var m := SphereMesh.new()
    m.radius = 1.0
    m.height = 2.0
    m.radial_segments = 16
    m.rings = 8
    var n := mesh(parent,id,m,p,tint,rough)
    n.scale = s
    return n

func limb(parent: Node3D, id: String, a: Vector3, b: Vector3, ra: float, rb: float, tint: Color) -> MeshInstance3D:
    var delta: Vector3 = b-a
    var m := CylinderMesh.new()
    m.bottom_radius = ra
    m.top_radius = rb
    m.height = maxf(delta.length(),0.001)
    m.radial_segments = 10
    var n := mesh(parent,id,m,(a+b)*0.5,tint)
    n.basis = Basis(Quaternion(Vector3.UP,delta.normalized()))
    return n

func curve(parent: Node3D, id: String, points: Array, ra: float, rb: float, tint: Color) -> void:
    for i in range(points.size()-1):
        var a: float = float(i)/float(points.size()-1)
        var b: float = float(i+1)/float(points.size()-1)
        limb(parent,id,points[i],points[i+1],lerpf(ra,rb,a),lerpf(ra,rb,b),tint)

func feather(parent: Node3D, p: Vector3, tip: Vector3, width: float, tint: Color) -> void:
    var axis: Vector3 = tip-p
    var across: Vector3 = axis.cross(Vector3.UP).normalized()*width
    if across.length() < 0.001:
        across = Vector3.RIGHT*width
    var center: Vector3 = p+axis*0.42
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for v in [p,center+across,tip,p,tip,center-across,tip,center+across,p,center-across,tip,p]:
        st.add_vertex(v)
    st.generate_normals()
    mesh(parent,"FeatherBlade",st.commit(),Vector3.ZERO,tint)

func actor(parent: Node3D, accent: Color = RUST) -> Node3D:
    var n := node(parent,"Adult_ConceptStatic")
    # +X is anterior; supported by flexed digitigrade legs, not a human torso.
    oval(n,"Thorax",Vector3(0.06,1.29,0),Vector3(0.68,0.40,0.34),SLATE)
    oval(n,"Pelvis",Vector3(-0.41,1.24,0),Vector3(0.43,0.40,0.34),accent.darkened(0.25))
    oval(n,"VentralPlumage",Vector3(0.24,1.15,0),Vector3(0.49,0.27,0.30),CREAM)
    curve(n,"Neck",[Vector3(0.40,1.40,0),Vector3(0.69,1.75,0),Vector3(0.86,2.06,0)],0.24,0.16,CREAM)
    oval(n,"Cranium",Vector3(1.03,2.17,0),Vector3(0.34,0.25,0.23),SKIN)
    oval(n,"ShortRostrum",Vector3(1.28,2.08,0),Vector3(0.29,0.13,0.17),SKIN.lightened(0.14))
    oval(n,"Mandible",Vector3(1.22,1.995,0),Vector3(0.27,0.065,0.15),SKIN.darkened(0.24))
    for sign_value in [-1.0,1.0]:
        var s: float = sign_value
        oval(n,"EyeRim",Vector3(1.08,2.21,s*0.205),Vector3(0.123,0.105,0.045),SLATE)
        oval(n,"AmberIris",Vector3(1.10,2.21,s*0.243),Vector3(0.073,0.073,0.022),Color("cc912d"),0.35)
        oval(n,"Pupil",Vector3(1.12,2.21,s*0.258),Vector3(0.031,0.052,0.012),Color("171815"),0.2)
        oval(n,"Nostril",Vector3(1.45,2.11,s*0.12),Vector3(0.045,0.025,0.015),SLATE)
        var hip := Vector3(-0.41,1.20,s*0.23)
        var knee := Vector3(-0.06,0.78,s*0.30)
        var hock := Vector3(-0.44,0.36,s*0.33)
        var foot := Vector3(-0.18,0.09,s*0.34)
        limb(n,"Thigh",hip,knee,0.23,0.14,accent.darkened(0.2))
        limb(n,"Shin",knee,hock,0.13,0.075,SKIN)
        limb(n,"Metatarsus",hock,foot,0.076,0.064,SKIN)
        for j in range(3):
            var d: float = float(j-1)*0.095
            var toe := foot+Vector3(0.28,0,d)
            limb(n,"PedalDigit",foot,toe,0.052,0.032,SKIN)
            limb(n,"PedalClaw",toe,toe+Vector3(0.075,-0.02,0),0.034,0.003,SLATE)
        var shoulder := Vector3(0.35,1.46,s*0.31)
        var elbow := Vector3(0.57,1.13,s*0.40)
        var wrist := Vector3(0.93,1.08,s*0.40)
        limb(n,"UpperForelimb",shoulder,elbow,0.125,0.085,SLATE)
        limb(n,"Forearm",elbow,wrist,0.09,0.055,SKIN)
        oval(n,"ManualBase",wrist,Vector3(0.105,0.055,0.07),SKIN)
        for j in range(3):
            var d: float = float(j-1)*0.056
            var knuckle := wrist+Vector3(0.10,-0.04,d)
            var tip := knuckle+Vector3(0.07,-0.07,0)
            limb(n,"ManualDigit",wrist+Vector3(0,0,d),knuckle,0.028,0.021,SKIN)
            limb(n,"ManualDigit",knuckle,tip,0.021,0.011,SKIN)
            limb(n,"ManualClaw",tip,tip+Vector3(-0.01,-0.04,0),0.012,0.002,SLATE)
        for i in range(10):
            for j in range(4):
                var x: float = -0.54+float(i)*0.104
                var y: float = 1.34+float(j)*0.09
                var p := Vector3(x,y,s*(0.29-float(j)*0.038))
                feather(n,p,p+Vector3(-0.24,-0.05,s*0.035),0.051,accent if (i+j)%3 == 0 else SLATE.lightened(float(j)*0.055))
        for j in range(8):
            var p := shoulder.lerp(elbow,float(j)/8.0)
            feather(n,p,p+Vector3(-0.16,-0.24,s*0.06),0.043,CREAM if j%3==0 else accent)
    var tail: Array = [Vector3(-0.63,1.25,0),Vector3(-1.11,1.27,0),Vector3(-1.62,1.34,0),Vector3(-2.15,1.43,0),Vector3(-2.55,1.52,0)]
    curve(n,"CounterbalanceTail",tail,0.24,0.025,SLATE)
    for i in range(22):
        var t: float = float(i)/22.0
        var p := Vector3(-0.73-1.72*t,1.38+0.18*t,0)
        for s in [-1.0,1.0]:
            feather(n,p+Vector3(0,0,s*0.08),p+Vector3(-0.29,0.015,s*0.15),0.044,accent if i%4==0 else CREAM if i%5==0 else SLATE)
    for i in range(10):
        var p := Vector3(0.80+float(i)*0.043,2.36-absf(float(i)-5.0)*0.009,0)
        feather(n,p,p+Vector3(-0.32,0.15,0.015),0.052,accent if i%2==0 else SLATE)
    return n

func vessel(parent: Node3D, id: String = "CultureVessel") -> Node3D:
    var n := node(parent,id)
    var profile: Array = [[0.0,0.28],[0.12,0.38],[0.33,0.53],[0.65,0.53],[0.88,0.42],[0.95,0.36]]
    for i in range(profile.size()-1):
        var a: Array = profile[i]
        var b: Array = profile[i+1]
        limb(n,"ClayProfile",Vector3(0,a[0],0),Vector3(0,b[0],0),a[1],b[1],CLAY)
    var tor := TorusMesh.new()
    tor.inner_radius = 0.32
    tor.outer_radius = 0.43
    mesh(n,"Rim",tor,Vector3(0,0.96,0),REED)
    var liquid := CylinderMesh.new()
    liquid.top_radius = 0.33
    liquid.bottom_radius = 0.33
    liquid.height = 0.02
    mesh(n,"CultureSurface",liquid,Vector3(0,0.965,0),Color("b68944"),0.3)
    for j in range(12):
        var a: float = TAU*float(j)/12.0
        limb(n,"WovenVertical",Vector3(cos(a)*0.33,0.08,sin(a)*0.33),Vector3(cos(a)*0.44,0.88,sin(a)*0.44),0.015,0.015,REED)
    return n

func hall(parent: Node3D) -> Node3D:
    var n := node(parent,"LivingRootHall")
    box(n,"StonePlatform",Vector3(0,-0.18,0),Vector3(9.0,0.36,6.4),STONE)
    for z in [-2.6,-1.3,0.0,1.3,2.6]:
        var points: Array = []
        for i in range(17):
            var a: float = PI*float(i)/16.0
            points.append(Vector3(cos(a)*4.0,sin(a)*3.7+0.1,z))
        curve(n,"RootRib",points,0.17,0.13,WOOD)
        for s in [-1.0,1.0]:
            limb(n,"RootButtress",Vector3(s*4.2,0,z+0.45),Vector3(s*3.7,1.1,z),0.22,0.10,BARK)
    for i in range(18):
        var a: float = PI*float(i)/17.0
        var x: float = cos(a)*4.0
        var y: float = sin(a)*3.7+0.1
        limb(n,"CanopyWeft",Vector3(x,y,-2.7),Vector3(x,y,2.7),0.06,0.06,REED)
        if i%2==0:
            for j in range(9):
                var z: float = -2.5+float(j)*0.62
                oval(n,"CanopyFoliage",Vector3(x,y+0.10,z),Vector3(0.43,0.19,0.53),LEAF.darkened(float(j%3)*0.10))
    return n

func bridge(parent: Node3D) -> Node3D:
    var n := node(parent,"RootBridge")
    for i in range(21):
        var x: float = -4.0+float(i)*0.4
        var y: float = 0.1+0.7*cos(x*PI/8.0)
        box(n,"DeckSlat",Vector3(x,y,0),Vector3(0.37,0.12,1.8),WOOD.lightened(float(i%3)*0.045))
        if i%3==0:
            for s in [-1.0,1.0]:
                limb(n,"RailPost",Vector3(x,y,s*0.9),Vector3(x,y+0.85,s*0.9),0.065,0.05,BARK)
    for s in [-1.0,1.0]:
        var path: Array = []
        for i in range(21):
            var x: float = -4.0+float(i)*0.4
            path.append(Vector3(x,0.95+0.7*cos(x*PI/8.0),s*0.9))
        curve(n,"RootRail",path,0.07,0.07,REED)
    return n

func nursery(parent: Node3D) -> Node3D:
    var n := node(parent,"NurseryNest")
    oval(n,"WovenNest",Vector3(0,0.18,0),Vector3(1.02,0.24,0.77),REED)
    for i in range(24):
        var a: float = TAU*float(i)/24.0
        limb(n,"NestWeave",Vector3(cos(a)*0.81,0.22,sin(a)*0.59),Vector3(cos(a+0.6)*0.98,0.43,sin(a+0.6)*0.73),0.035,0.035,WOOD)
    for p in [Vector3(-0.38,0.42,0.05),Vector3(0.35,0.43,-0.05),Vector3(0,0.43,0.35)]:
        oval(n,"Egg_ExternalStageConcept",p,Vector3(0.23,0.32,0.22),CREAM)
    return n

func workbench(parent: Node3D) -> Node3D:
    var n := node(parent,"MaterialWorkstation")
    box(n,"StoneTable",Vector3(0,0.67,0),Vector3(2.4,0.22,1.05),STONE)
    for x in [-0.82,0.82]:
        box(n,"Support",Vector3(x,0.32,0),Vector3(0.4,0.64,0.82),BARK)
    for i in range(6):
        var p := Vector3(-0.88+float(i)*0.29,0.84,-0.18)
        oval(n,"WorkedStone",p,Vector3(0.12,0.06,0.18),CREAM.darkened(float(i)*0.065))
        limb(n,"BoneTool",p+Vector3(0,0,0.30),p+Vector3(0.15,0,0.45),0.027,0.009,WOOD)
    return n

func plant(parent: Node3D) -> Node3D:
    var n := node(parent,"CycadFernCluster")
    for j in range(3):
        var origin := Vector3(float(j-1)*0.54,0,0)
        limb(n,"Stem",origin,origin+Vector3(0,0.46,0),0.12,0.08,BARK)
        for i in range(8):
            var a: float = TAU*float(i)/8.0+float(j)
            var p := origin+Vector3(0,0.43,0)
            var tip := p+Vector3(cos(a)*0.70,0.28,sin(a)*0.70)
            feather(n,p,tip,0.15,LEAF if i%2==0 else DARK_LEAF)
            limb(n,"LeafRachis",p,tip,0.015,0.005,REED)
    return n

func bank(parent: Node3D) -> Node3D:
    var n := node(parent,"RiverRetainingBank")
    for row in range(3):
        for i in range(8):
            var x: float = -3.1+float(i)*0.88+float(row%2)*0.14
            box(n,"RetainingStone",Vector3(x,0.15+float(row)*0.30,0),Vector3(0.84,0.29,0.75),STONE.darkened(float((i+row)%4)*0.07))
    for i in range(5):
        var x: float = -3.4+float(i)*1.7
        limb(n,"BracingTimber",Vector3(x,0,-0.68),Vector3(x,1.15,0.26),0.11,0.10,WOOD)
    limb(n,"CrossMember",Vector3(-3.6,0.92,0.35),Vector3(3.6,0.92,0.35),0.09,0.09,BARK)
    return n

func catalog(parent: Node3D) -> Dictionary:
    var items: Dictionary = {}
    items["adult"] = actor(parent)
    items["adult_slate"] = actor(parent,Color("55777c"))
    items["juvenile"] = actor(parent,Color("b18452"))
    items["hall"] = hall(parent)
    items["bridge"] = bridge(parent)
    items["culture_vessel"] = vessel(parent)
    items["nursery"] = nursery(parent)
    items["workbench"] = workbench(parent)
    items["plant"] = plant(parent)
    items["bank"] = bank(parent)
    return items
