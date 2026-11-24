extends "res://scripts/surface_zenith_assets.gd"
## Pass 02: original procedural surface maps, continuous lofts and layered contour plumage.
const MAP_SIZE: int = 512
var maps: Dictionary = {}

func _family(tint: Color) -> String:
    if tint == SKIN or (tint.r > 0.47 and tint.r < 0.64 and tint.g > 0.36 and tint.g < 0.55 and tint.b > 0.27 and tint.b < 0.48):
        return "skin"
    if tint.g > tint.r*1.12 and tint.g > tint.b*1.12:
        return "leaf"
    if tint == BARK or tint == WOOD:
        return "wood"
    if tint == REED:
        return "fiber"
    if tint == CLAY:
        return "clay"
    if absf(tint.r-tint.g)<0.07 and absf(tint.g-tint.b)<0.13 and tint.r>0.36:
        return "stone"
    return "plumage"

func _surface_maps(family: String) -> Dictionary:
    if maps.has(family):
        return maps[family]
    var color := Image.create(MAP_SIZE,MAP_SIZE,false,Image.FORMAT_RGB8)
    var height := Image.create(MAP_SIZE,MAP_SIZE,false,Image.FORMAT_RGB8)
    var noise := FastNoiseLite.new()
    noise.seed = 70000000 + ["skin","leaf","wood","fiber","clay","stone","plumage"].find(family)*17
    noise.frequency = 0.064
    noise.fractal_octaves = 3
    for y in range(MAP_SIZE):
        for x in range(MAP_SIZE):
            var u: float = float(x)/MAP_SIZE
            var v: float = float(y)/MAP_SIZE
            var n: float = noise.get_noise_2d(x,y)
            var grain: float = 0.0
            match family:
                "skin":
                    var row: float = floor(v*42.0)
                    var cell: Vector2 = Vector2(fposmod(u*50.0+fmod(row,2.0)*0.5,1.0)-0.5,fposmod(v*42.0,1.0)-0.5)
                    grain = 1.0-smoothstep(0.30,0.48,cell.length())
                "wood":
                    grain = 0.5+0.5*sin(TAU*(u*32.0+0.5*sin(v*TAU*2.0)+n*0.50))
                "fiber":
                    grain = 0.5+0.25*sin(TAU*u*48.0)+0.25*sin(TAU*v*38.0)
                "leaf":
                    grain = 0.5+0.3*sin(TAU*(v*23.0+absf(u-0.5)*7.0))
                    grain += 0.2*(1.0-smoothstep(0.004,0.022,absf(u-0.5)))
                "plumage":
                    grain = 0.5+0.25*sin(TAU*(u*44.0+v*3.0))+0.15*sin(TAU*v*18.0)
                "stone":
                    grain = 0.5+n*0.48+0.11*sin(TAU*(u*8.0+v*6.0+n))
                _:
                    grain = 0.5+0.23*n+0.15*sin(TAU*v*35.0)
            var h: float = clampf(0.38+grain*0.34+n*0.19,0.0,1.0)
            var a: float = clampf(0.78+grain*0.18+n*0.14,0.43,1.0)
            color.set_pixel(x,y,Color(a,a,a))
            height.set_pixel(x,y,Color(h,h,h))
    # Explicit central differences, independent of deprecated Image convenience methods.
    var normal := Image.create(MAP_SIZE,MAP_SIZE,false,Image.FORMAT_RGB8)
    for y in range(MAP_SIZE):
        for x in range(MAP_SIZE):
            var dx: float = height.get_pixel(posmod(x+1,MAP_SIZE),y).r-height.get_pixel(posmod(x-1,MAP_SIZE),y).r
            var dy: float = height.get_pixel(x,posmod(y+1,MAP_SIZE)).r-height.get_pixel(x,posmod(y-1,MAP_SIZE)).r
            var v3: Vector3 = Vector3(-dx*2.5,-dy*2.5,1.0).normalized()
            normal.set_pixel(x,y,Color(v3.x*0.5+0.5,v3.y*0.5+0.5,v3.z*0.5+0.5))
    color.generate_mipmaps()
    normal.generate_mipmaps()
    maps[family] = {"albedo":ImageTexture.create_from_image(color),"normal":ImageTexture.create_from_image(normal),"albedo_image":color,"normal_image":normal}
    return maps[family]

func material(tint: Color, rough: float = 0.84) -> StandardMaterial3D:
    var key: String = str(tint)+str(rough)
    if not mats.has(key):
        var m := StandardMaterial3D.new()
        m.albedo_color = tint
        m.roughness = rough
        # Leave small gloss eyes and claws untextured.
        if rough >= 0.6 and tint.v > 0.19:
            var t: Dictionary = _surface_maps(_family(tint))
            m.albedo_texture = t["albedo"]
            m.normal_enabled = true
            m.normal_texture = t["normal"]
            m.normal_scale = 0.65
        m.cull_mode = BaseMaterial3D.CULL_DISABLED
        mats[key] = m
    return mats[key]

func oval(parent: Node3D, id: String, p: Vector3, s: Vector3, tint: Color, rough: float = 0.84) -> MeshInstance3D:
    var m := SphereMesh.new()
    m.radius = 1.0
    m.height = 2.0
    m.radial_segments = 32
    m.rings = 16
    var n := mesh(parent,id,m,p,tint,rough)
    n.scale = s
    return n

func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, ua: Vector2, ub: Vector2, uc: Vector2) -> void:
    st.set_uv(ua)
    st.add_vertex(a)
    st.set_uv(ub)
    st.add_vertex(b)
    st.set_uv(uc)
    st.add_vertex(c)

func loft(parent: Node3D, id: String, points: Array, radii: Array, tint: Color, segments: int = 24) -> MeshInstance3D:
    # Circular/elliptical continuous sweeps through control sections. Local frames follow tangent.
    var rings: Array = []
    var last: int = points.size()-1
    for i in range(points.size()):
        var tangent: Vector3 = (points[mini(i+1,last)]-points[maxi(i-1,0)]).normalized()
        var across: Vector3 = tangent.cross(Vector3.FORWARD).normalized()
        if across.length_squared()<0.01:
            across = tangent.cross(Vector3.UP).normalized()
        var second: Vector3 = tangent.cross(across).normalized()
        var radius: Vector2 = radii[i]
        var ring: Array = []
        for j in range(segments+1):
            var a: float = TAU*float(j)/segments
            ring.append(points[i]+across*cos(a)*radius.x+second*sin(a)*radius.y)
        rings.append(ring)
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    st.set_smooth_group(0)
    for i in range(last):
        for j in range(segments):
            var a: Vector2 = Vector2(float(j)/segments,float(i)/last)
            var b: Vector2 = Vector2(float(j+1)/segments,float(i)/last)
            var c: Vector2 = Vector2(float(j+1)/segments,float(i+1)/last)
            var d: Vector2 = Vector2(float(j)/segments,float(i+1)/last)
            _tri(st,rings[i][j],rings[i+1][j],rings[i+1][j+1],a,d,c)
            _tri(st,rings[i][j],rings[i+1][j+1],rings[i][j+1],a,c,b)
    st.index()
    st.generate_normals()
    st.generate_tangents()
    return mesh(parent,id,st.commit(),Vector3.ZERO,tint)

func curve(parent: Node3D, id: String, points: Array, ra: float, rb: float, tint: Color) -> void:
    var smooth: Array = []
    var radii: Array = []
    var n: int = points.size()-1
    for i in range(n):
        var p0: Vector3 = points[maxi(0,i-1)]
        var p1: Vector3 = points[i]
        var p2: Vector3 = points[i+1]
        var p3: Vector3 = points[mini(n,i+2)]
        for j in range(4):
            var t: float = float(j)/4.0
            smooth.append(p1.cubic_interpolate(p2,p0,p3,t))
            var rad: float = lerpf(ra,rb,(float(i)+t)/n)
            radii.append(Vector2(rad,rad))
    smooth.append(points[n])
    radii.append(Vector2(rb,rb))
    loft(parent,id,smooth,radii,tint,16)

func feather(parent: Node3D, p: Vector3, tip: Vector3, width: float, tint: Color) -> void:
    var axis: Vector3 = tip-p
    var facing: Vector3 = Vector3.UP
    if "Adult" in str(parent.name) and absf(p.z)>0.10:
        facing = Vector3(0,0,signf(p.z))
    var across: Vector3 = axis.cross(facing).normalized()*width
    if across.length()<0.001:
        across = Vector3.RIGHT*width
    var rows: Array = []
    for i in range(7):
        var t: float = float(i)/6.0
        var w: float = maxf(0.008,pow(sin(PI*t),0.75))
        var center: Vector3 = p+axis*t+facing*(sin(PI*t)*width*0.32)
        rows.append([center-across*w,center+facing*width*0.19*w,center+across*w])
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    st.set_smooth_group(0)
    for i in range(6):
        for j in range(2):
            var a := Vector2(float(j)*0.5,float(i)/6.0)
            var b := Vector2(float(j+1)*0.5,float(i)/6.0)
            var c := Vector2(float(j+1)*0.5,float(i+1)/6.0)
            var d := Vector2(float(j)*0.5,float(i+1)/6.0)
            _tri(st,rows[i][j],rows[i+1][j],rows[i+1][j+1],a,d,c)
            _tri(st,rows[i][j],rows[i+1][j+1],rows[i][j+1],a,c,b)
    st.index()
    st.generate_normals()
    st.generate_tangents()
    mesh(parent,"ContourFeather",st.commit(),Vector3.ZERO,tint)

func actor(parent: Node3D, accent: Color = RUST) -> Node3D:
    var n: Node3D = super.actor(parent,accent)
    for name_value in ["Thorax","Pelvis","VentralPlumage","Neck","Cranium","ShortRostrum"]:
        var old: Node = n.get_node_or_null(name_value)
        if old != null:
            old.free()
    loft(n,"ContinuousTorso",[Vector3(-0.76,1.25,0),Vector3(-0.48,1.28,0),Vector3(-0.10,1.32,0),Vector3(0.24,1.37,0),Vector3(0.52,1.44,0),Vector3(0.65,1.55,0)],
        [Vector2(0.09,0.09),Vector2(0.37,0.31),Vector2(0.43,0.37),Vector2(0.37,0.34),Vector2(0.24,0.24),Vector2(0.12,0.13)],SLATE,32)
    loft(n,"ContinuousNeck",[Vector3(0.34,1.36,0),Vector3(0.57,1.55,0),Vector3(0.73,1.78,0),Vector3(0.86,1.99,0),Vector3(0.98,2.11,0)],
        [Vector2(0.26,0.24),Vector2(0.24,0.22),Vector2(0.20,0.18),Vector2(0.16,0.16),Vector2(0.13,0.14)],CREAM,32)
    loft(n,"ContinuousCraniumAndRostrum",[Vector3(0.72,2.15,0),Vector3(0.92,2.18,0),Vector3(1.10,2.18,0),Vector3(1.28,2.09,0),Vector3(1.46,2.07,0),Vector3(1.55,2.06,0)],
        [Vector2(0.06,0.07),Vector2(0.25,0.21),Vector2(0.24,0.23),Vector2(0.15,0.17),Vector2(0.105,0.125),Vector2(0.015,0.035)],SKIN,32)
    for s in [-1.0,1.0]:
        oval(n,"ThighMuscle",Vector3(-0.30,1.04,s*0.24),Vector3(0.32,0.33,0.20),accent.darkened(0.13))
        oval(n,"HockTransition",Vector3(-0.44,0.36,s*0.33),Vector3(0.092,0.11,0.085),SKIN)
        oval(n,"ShoulderMantle",Vector3(0.35,1.42,s*0.29),Vector3(0.22,0.22,0.15),SLATE)
        oval(n,"SupraorbitalRidge",Vector3(1.085,2.30,s*0.205),Vector3(0.135,0.032,0.049),SLATE)
        oval(n,"EyeCatchlight",Vector3(1.135,2.24,s*0.266),Vector3(0.013,0.014,0.008),Color("f2e6bf"),0.2)
        for i in range(14):
            for j in range(5):
                var x: float = -0.56+float(i)*0.078
                var angle: float = 0.10+float(j)*0.28
                var p := Vector3(x,1.30+sin(angle)*0.35,s*cos(angle)*0.32)
                feather(n,p,p+Vector3(-0.20,-0.07,s*0.09),0.044,accent if (i+j)%4==0 else CREAM.darkened(0.15) if j==0 else SLATE.lightened(float(j)*0.045))
        for i in range(9):
            var p := Vector3(0.53+float(i)*0.045,1.56+float(i)*0.063,s*(0.17-float(i)*0.004))
            feather(n,p,p+Vector3(-0.10,-0.17,s*0.055),0.038,CREAM if i%3 else accent)
    return n

func hall(parent: Node3D) -> Node3D:
    var n: Node3D = super.hall(parent)
    # Grown diagonal lattice, root buttress detail and suspended fiber screens.
    for z in [-2.55,-1.25,0.05,1.35]:
        for s in [-1.0,1.0]:
            for j in range(3):
                var y: float = 0.65+float(j)*0.80
                curve(n,"DiagonalLivingLattice",[Vector3(s*(4.1-y*0.29),y,z),Vector3(s*(3.9-y*0.30),y+0.35,z+0.65),Vector3(s*(3.7-y*0.35),y+0.75,z+1.25)],0.047,0.028,WOOD)
    for s in [-1.0,1.0]:
        for i in range(14):
            var z: float = -2.6+float(i)*0.4
            curve(n,"HangingFiber",[Vector3(s*3.4,2.20,z),Vector3(s*3.32,1.95,z+0.10),Vector3(s*3.45,1.57,z+0.02)],0.026,0.009,REED)
    return n

func plant(parent: Node3D) -> Node3D:
    var n := node(parent,"FernAndCycadDetailed")
    for j in range(3):
        var origin := Vector3(float(j-1)*0.54,0,0)
        limb(n,"Stem",origin,origin+Vector3(0,0.46,0),0.10,0.07,BARK)
        for i in range(7):
            var a: float = TAU*float(i)/7.0+float(j)
            var direction := Vector3(cos(a),0,sin(a))
            var side := Vector3(-sin(a),0,cos(a))
            var p := origin+Vector3(0,0.43,0)
            var tip := p+direction*0.80+Vector3(0,0.16,0)
            curve(n,"CurvedRachis",[p,p+direction*0.42+Vector3(0,0.30,0),tip],0.016,0.003,REED)
            for k in range(5):
                var t: float = (float(k)+1.0)/6.0
                var base: Vector3 = p+direction*(0.80*t)+Vector3(0,sin(t*PI)*0.22+t*0.16,0)
                for s in [-1.0,1.0]:
                    var target: Vector3 = base+side*s*(0.20*(1.0-t*0.75))+direction*0.15+Vector3(0,0.03,0)
                    feather(n,base,target,0.038,LEAF if k%2==0 else DARK_LEAF.lightened(0.15))
    return n

func bank(parent: Node3D) -> Node3D:
    var n: Node3D = super.bank(parent)
    for old in n.get_children():
        if str(old.name).begins_with("RetainingStone"):
            old.rotation.y = sin(old.position.x*4.0+old.position.y)*0.09
            old.rotation.z = cos(old.position.x*3.0)*0.045
    for i in range(17):
        var x: float = -3.4+float(i)*0.42
        oval(n,"MossMat",Vector3(x,0.94,0.15),Vector3(0.24,0.055,0.26),DARK_LEAF.lightened(float(i%3)*0.08))
    return n

func export_maps(dir: String) -> bool:
    if DirAccess.make_dir_recursive_absolute(dir) != OK:
        return false
    for family in ["skin","leaf","wood","fiber","clay","stone","plumage"]:
        var t: Dictionary = _surface_maps(family)
        if t["albedo_image"].save_png(dir.path_join(family+"_albedo.png")) != OK:
            return false
        if t["normal_image"].save_png(dir.path_join(family+"_normal.png")) != OK:
            return false
    return true
