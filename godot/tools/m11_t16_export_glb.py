#!/usr/bin/env python3
"""T16 deterministic GLB 2.0 export from the same evolutionary bone graphs as Godot.

Exports 3 TRUE glTF skins with 43 joints and weighted UV mesh surfaces.
Soft-volume BoneAttachment3D art overlays and Godot procedural animations
are not portable and remain in the native research scene. Pure stdlib.
"""
from __future__ import annotations
import argparse
import json
import math
import struct
from pathlib import Path
from m11_t16_evolutionary_models import ROOT, REFERENCE, PROFILES, read, build, radius

PALETTE = {
    "E1": [(0.43,.49,.33),(.48,.51,.37),(.35,.35,.30)],
    "E2": [(0.30,.49,.49),(.36,.57,.55),(.34,.34,.31)],
    "E3": [(0.56,.44,.35),(.58,.49,.39),(.38,.33,.29)]
}
REGION_SURFACE={"manual":2,"pedal":2,"cranial":0,"axial":0,"caudal":1,"forelimb":1,"hindlimb":0}


def vecsub(a,b):return tuple(a[i]-b[i] for i in range(3))
def dot(a,b):return sum(a[i]*b[i] for i in range(3))
def cross(a,b):return (a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0])
def norm(v):
    d=math.sqrt(dot(v,v))
    return tuple(q/d for q in v) if d>1e-12 else (1.,0.,0.)
def lerp(a,b,t):return tuple(a[i]*(1-t)+b[i]*t for i in range(len(a)))


def build_geometry(bones:list[dict], integument:float)->list[dict]:
    lookup={b["name"]:b for b in bones}
    indices={b["name"]:i for i,b in enumerate(bones)}
    groups=[{"POSITION":[],"NORMAL":[],"TEXCOORD_0":[],"JOINTS_0":[],"WEIGHTS_0":[],"indices":[]} for _ in range(3)]
    for bone in bones:
        parent=bone["parent"]
        if parent is None:continue
        a=lookup[parent]["anchor"]; b=bone["anchor"]
        direction=norm(vecsub(b,a))
        u=cross(direction,(0.,1.,0.))
        if dot(u,u)<.002:u=cross(direction,(1.,0.,0.))
        u=norm(u);v=norm(cross(direction,u))
        name=bone["name"]; cat=REGION_SURFACE[bone["region"]]
        if name.startswith("manual_") or name.startswith("pedal_") or name=="mandible":cat=2
        elif name.startswith("caudal_") or name.startswith("scapula") or bone["region"]=="forelimb":cat=1
        else:cat=0
        group=groups[cat]
        initial=len(group["POSITION"])
        rad=radius(name)*(1.0 if cat==2 else integument)
        sides=10
        for ring in range(3):
            t=ring/2.0;center=lerp(a,b,t)
            child_weight=(.0625,.5,.9375)[ring]
            for j in range(sides+1):
                angle=math.tau*j/sides
                normal=tuple(u[i]*math.cos(angle)+v[i]*math.sin(angle) for i in range(3))
                pos=tuple(center[i]+normal[i]*rad*(1.07-.22*t) for i in range(3))
                group["POSITION"].append(pos)
                group["NORMAL"].append(normal)
                group["TEXCOORD_0"].append((j/sides,t))
                group["JOINTS_0"].append((indices[parent],indices[name],0,0))
                group["WEIGHTS_0"].append((1-child_weight,child_weight,0.,0.))
        for ring in range(2):
            for j in range(sides):
                i=initial+ring*(sides+1)+j
                group["indices"].extend((i,i+sides+1,i+1,i+1,i+sides+1,i+sides+2))
    return groups


class Writer:
    def __init__(self):
        self.binary=bytearray()
        self.views=[]
        self.accessors=[]
    def pack(self,fmt:str,values:list[tuple]|list[int],target:int|None=None)->int:
        flat=[]
        if fmt=="I":
            flat=list(values)
        else:
            for value in values:flat.extend(value)
        while len(self.binary)%4:self.binary.append(0)
        start=len(self.binary)
        raw=struct.pack("<"+fmt*len(flat),*flat)
        self.binary.extend(raw)
        view={"buffer":0,"byteOffset":start,"byteLength":len(raw)}
        if target is not None:view["target"]=target
        self.views.append(view)
        return len(self.views)-1
    def accessor(self,view:int,count:int,component:int,kind:str,minimum=None,maximum=None)->int:
        a={"bufferView":view,"componentType":component,"count":count,"type":kind}
        if minimum is not None:a["min"]=minimum
        if maximum is not None:a["max"]=maximum
        self.accessors.append(a)
        return len(self.accessors)-1


def skin_glb(candidate:dict,destination:Path)->dict:
    bones=candidate["bones"];keys={b["name"]:i for i,b in enumerate(bones)}
    integument=float(candidate["params"]["integument_volume"])
    geometry=build_geometry(bones,integument)
    writer=Writer()
    nodes=[]
    for b in bones:
        parent=b["parent"]
        origin=b["anchor"]
        local=origin if parent is None else vecsub(origin,bones[keys[parent]]["anchor"])
        nodes.append({"name":b["name"],"translation":list(local)})
    for idx,b in enumerate(bones):
        if b["parent"] is not None:
            nodes[keys[b["parent"]]].setdefault("children",[]).append(idx)
    roots=[keys["pelvis"]]
    mesh_defs=[]
    for surface_idx,surface in enumerate(geometry):
        v=surface["POSITION"]
        if not v:raise ValueError("empty skinned surface")
        attrib={}
        for key,fmt,component,kind in (
            ("POSITION","f",5126,"VEC3"),("NORMAL","f",5126,"VEC3"),
            ("TEXCOORD_0","f",5126,"VEC2"),("JOINTS_0","H",5123,"VEC4"),
            ("WEIGHTS_0","f",5126,"VEC4")
        ):
            idx=writer.pack(fmt,surface[key],34962)
            minimum=maximum=None
            if key=="POSITION":
                minimum=[min(row[i] for row in v) for i in range(3)]
                maximum=[max(row[i] for row in v) for i in range(3)]
            attrib[key]=writer.accessor(idx,len(v),component,kind,minimum,maximum)
        index_view=writer.pack("I",surface["indices"],34963)
        index_acc=writer.accessor(index_view,len(surface["indices"]),5125,"SCALAR")
        mesh_defs.append({"name":f"evolved_{candidate['id']}_surface_{surface_idx}",
                          "primitives":[{"attributes":attrib,"indices":index_acc,"material":surface_idx}]})
        mesh_node=len(nodes)
        nodes.append({"name":f"WeightedSkin_Surface{surface_idx}","mesh":surface_idx,"skin":0})
        roots.append(mesh_node)
    # Inverse bind matrices for translation-only T07 reference skeleton,
    # column-major glTF 4x4 float matrices. No invented rotations.
    ibm=[]
    for bone in bones:
        x,y,z=bone["anchor"]
        ibm.append((1.,0.,0.,0.,0.,1.,0.,0.,0.,0.,1.,0.,-x,-y,-z,1.))
    mview=writer.pack("f",ibm)
    matrix_accessor=writer.accessor(mview,len(bones),5126,"MAT4")
    colors=PALETTE[candidate["id"]]
    mats=[{"name":name,"pbrMetallicRoughness":{
        "baseColorFactor":[*colors[i],1.],"metallicFactor":0.,
        "roughnessFactor":.87},"doubleSided":True}
        for i,name in enumerate(("soft_volume_study","filament_surface_study","keratin_surface_study"))]
    gltf={
        "asset":{"version":"2.0","generator":"ALCHUL T16 constrained morphometrics / Python standard library"},
        "scene":0,"scenes":[{"nodes":roots}],
        "nodes":nodes,"meshes":mesh_defs,
        "skins":[{"joints":list(range(len(bones))),"skeleton":keys["pelvis"],"inverseBindMatrices":matrix_accessor}],
        "materials":mats,
        "buffers":[{"byteLength":len(writer.binary)}],
        "bufferViews":writer.views,
        "accessors":writer.accessors
    }
    assert len(gltf["skins"][0]["joints"])==43
    json_data=json.dumps(gltf,separators=(",",":"),allow_nan=False).encode("utf-8")
    json_data+=b" "*((-len(json_data))%4)
    binary=bytes(writer.binary);binary+=b"\x00"*((-len(binary))%4)
    length=12+8+len(json_data)+8+len(binary)
    destination.write_bytes(struct.pack("<4sII",b"glTF",2,length)+
            struct.pack("<I4s",len(json_data),b"JSON")+json_data+
            struct.pack("<I4s",len(binary),b"BIN\x00")+binary)
    return {"file":destination.name,"bytes":destination.stat().st_size,
            "joint_count":43,"weighted_material_surfaces":3,
            "vertex_count":sum(len(s["POSITION"]) for s in geometry),
            "face_count":sum(len(s["indices"])//3 for s in geometry),
            "contains_true_skin":True,"baked_animation_tracks":False,
            "scientific_canon":False}


def inspect_glb(path:Path)->dict:
    data=path.read_bytes()
    magic,version,length=struct.unpack_from("<4sII",data,0)
    if magic!=b"glTF" or version!=2 or length!=len(data):
        raise ValueError("invalid GLB header")
    n,kind=struct.unpack_from("<I4s",data,12)
    if kind!=b"JSON":raise ValueError("missing glTF JSON chunk")
    obj=json.loads(data[20:20+n])
    if len(obj.get("skins",[]))!=1 or len(obj["skins"][0]["joints"])!=43:
        raise ValueError("missing 43-joint portable skin")
    for mesh in obj.get("meshes",[]):
        for prim in mesh["primitives"]:
            if not {"JOINTS_0","WEIGHTS_0","POSITION","NORMAL","TEXCOORD_0"}.issubset(prim["attributes"]):
                raise ValueError("missing skinned vertex attributes")
    if "animations" in obj:raise ValueError("do not fabricate baked animation")
    return {"valid":True,"joints":43,"skins":len(obj["skins"]),"meshes":len(obj["meshes"])}


def main()->int:
    parser=argparse.ArgumentParser()
    parser.add_argument("--out",type=Path,default=ROOT/"../m11-t16-evolved-glb")
    args=parser.parse_args()
    args.out.mkdir(parents=True,exist_ok=True)
    source=build(read(REFERENCE),read(PROFILES))
    outputs=[]
    for candidate in source["candidates"]:
        path=args.out/f"ALCHUL_T16_{candidate['id']}_evolutionary_hypothesis.glb"
        stats=skin_glb(candidate,path)
        stats.update(inspect_glb(path))
        outputs.append(stats)
    manifest={"files":outputs,"status":"three real glTF2 skin-weighted editable rig hypotheses",
        "source":"T07 43 bone graph and bounded T16 functional profiles",
        "fossil_species":False,"creator_approved":False,"metric_scale":False,
        "Godot_procedural_animation_baked_into_GLTF":False,
        "visual_soft_tissue_overlays_exported":False}
    (args.out/"model_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
    print("ALCHUL T16 THREE MANUAL PORTABLE RIGGED GLB PASS",[(x["file"],x["bytes"]) for x in outputs])
    return 0
if __name__=="__main__":raise SystemExit(main())
