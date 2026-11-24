extends RefCounted
## Transfer the Pass 02 visible geometry into a real weighted T16 E2 skeleton.
## Rest registration is a provisional art-space transform, not a validated anatomy.
const REGISTRY = "res://data/m11_t16_evolved_candidate_bones.json"
const BASE = "res://data/m11_t07_skeletal_reference.json"
var anchors: Array[Vector3] = []
var names: Array[String] = []
var parents: Array[int] = []
var rest_scale: float = 0.78
var rest_offset := Vector3(-0.42,-0.30,0)

func setup(skeleton: Skeleton3D) -> void:
    anchors.clear()
    names.clear()
    parents.clear()
    for i in range(skeleton.get_bone_count()):
        names.append(skeleton.get_bone_name(i))
        parents.append(skeleton.get_bone_parent(i))
        anchors.append(skeleton.get_bone_global_rest(i).origin*rest_scale+rest_offset)

func _segment_distance(p: Vector3, i: int) -> float:
    var a: Vector3 = anchors[i]
    var b: Vector3 = anchors[parents[i]] if parents[i]>=0 else a
    var d: Vector3 = b-a
    var t: float = clampf((p-a).dot(d)/maxf(d.length_squared(),0.000001),0.0,1.0)
    return p.distance_squared_to(a+d*t)

func weights(p: Vector3, part: String) -> Dictionary:
    var candidates: Array = []
    var tag: String = part.to_lower()
    var side: String = "_R" if p.z>0 else "_L"
    for i in range(names.size()):
        var n: String = names[i]
        var allow: bool = true
        if "eye" in tag or "pupil" in tag or "nostril" in tag or "cran" in tag or "rostrum" in tag or "supraorbital" in tag:
            allow = n=="skull"
        elif "mandible" in tag:
            allow = n=="mandible"
        elif "manual" in tag or "forearm" in tag or "forelimb" in tag:
            allow = n.ends_with(side) and (n.begins_with("manual") or n.begins_with("carpus") or n.begins_with("antebrachium") or n.begins_with("humerus"))
        elif "pedal" in tag or "hock" in tag or "metatarsus" in tag or "shin" in tag or "thigh" in tag:
            allow = n.ends_with(side) and (n.begins_with("pedal") or n.begins_with("metatarsus") or n.begins_with("tibia") or n.begins_with("femur"))
        elif "tail" in tag or (("feather" in tag) and p.x < -0.82):
            allow = n.begins_with("caudal") or n=="pelvis"
        elif "neck" in tag:
            allow = n.begins_with("neck") or n=="thorax" or n=="skull"
        elif "torso" in tag:
            allow = n in ["pelvis","spine","thorax","neck_01"]
        if allow:
            candidates.append([_segment_distance(p,i),i])
    if candidates.is_empty():
        candidates.append([0.0,0])
    candidates.sort_custom(func(a,b): return a[0]<b[0])
    var ids := PackedInt32Array([0,0,0,0])
    var ws := PackedFloat32Array([0,0,0,0])
    var total: float = 0.0
    for j in range(mini(4,candidates.size())):
        ids[j] = candidates[j][1]
        ws[j] = 1.0/pow(0.025+float(candidates[j][0]),2.0)
        total += ws[j]
    for j in range(4):
        ws[j] /= total
    return {"bones":ids,"weights":ws}

func bind_meshes(source: Node3D, actor: Node3D, skeleton: Skeleton3D) -> Dictionary:
    setup(skeleton)
    var groups: Dictionary = {}
    # Batch by material so the rig uses a small set of genuine skinned surfaces.
    for n in source.find_children("*","MeshInstance3D",true,false):
        var m: MeshInstance3D = n
        var transform: Transform3D = Transform3D.IDENTITY
        var cur: Node3D = m
        while cur != source:
            transform = cur.transform*transform
            cur = cur.get_parent() as Node3D
        for si in range(m.mesh.get_surface_count()):
            var mat: Material = m.material_override if m.material_override!=null else m.mesh.surface_get_material(si)
            var key: int = mat.get_instance_id() if mat!=null else 0
            if not groups.has(key):
                groups[key] = {"mat":mat,"v":PackedVector3Array(),"n":PackedVector3Array(),"uv":PackedVector2Array(),"b":PackedInt32Array(),"w":PackedFloat32Array(),"ix":PackedInt32Array()}
            var g: Dictionary = groups[key]
            var a: Array = m.mesh.surface_get_arrays(si)
            var offset: int = g["v"].size()
            var vert: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
            var normals: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
            var uvs: PackedVector2Array = a[Mesh.ARRAY_TEX_UV] if a[Mesh.ARRAY_TEX_UV]!=null else PackedVector2Array()
            for i in range(vert.size()):
                var p: Vector3 = transform*vert[i]
                var w: Dictionary = weights(p,str(m.name))
                g["v"].append((p-rest_offset)/rest_scale)
                g["n"].append((transform.basis.inverse().transposed()*normals[i]).normalized())
                g["uv"].append(uvs[i] if i<uvs.size() else Vector2.ZERO)
                g["b"].append_array(w["bones"])
                g["w"].append_array(w["weights"])
            var ix: Variant = a[Mesh.ARRAY_INDEX]
            if ix!=null and ix.size()>0:
                for i in ix:
                    g["ix"].append(offset+i)
            else:
                for i in range(vert.size()):
                    g["ix"].append(offset+i)
    var output := ArrayMesh.new()
    var vertices: int = 0
    var tris: int = 0
    for g in groups.values():
        var a: Array = []
        a.resize(Mesh.ARRAY_MAX)
        a[Mesh.ARRAY_VERTEX]=g["v"]
        a[Mesh.ARRAY_NORMAL]=g["n"]
        a[Mesh.ARRAY_TEX_UV]=g["uv"]
        a[Mesh.ARRAY_BONES]=g["b"]
        a[Mesh.ARRAY_WEIGHTS]=g["w"]
        a[Mesh.ARRAY_INDEX]=g["ix"]
        output.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,a)
        output.surface_set_material(output.get_surface_count()-1,g["mat"])
        vertices += g["v"].size()
        tris += int(g["ix"].size()/3)
    var shell := MeshInstance3D.new()
    shell.name = "Pass03_WeightedConceptShell"
    shell.mesh = output
    shell.skin = skeleton.create_skin_from_rest_transforms()
    shell.skeleton = NodePath("../ResearchSkeleton3D")
    actor.add_child(shell)
    return {"mesh":shell,"vertices":vertices,"triangles":tris,"surfaces":output.get_surface_count(),"bones":skeleton.get_bone_count()}
