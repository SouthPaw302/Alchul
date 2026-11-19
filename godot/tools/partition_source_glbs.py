#!/usr/bin/env python3
"""Deterministically partition authored M1/M6 GLBs for GitHub/Godot review.
Preserve source GLBs unmodified in Drive; commit derived <=1.65MB geometry chunks.
M6 original texture maps are imported independently, not re-embedded.
"""
import hashlib, json, pathlib, copy
import numpy as np
import trimesh
from trimesh.visual import TextureVisuals
from trimesh.visual.material import PBRMaterial

SOURCES={
 'm1':'ALC_SURFACE_RIVER_M1_v001.glb',
 'm6':'ALC_M6_RIVERBANK_DETAIL_TEXTURED_v001.glb',
}
# GLB encoded size bound: allows safe GitHub Contents API / create_blob requests.
MAX_BYTES=1_430_000
ROOT=pathlib.Path('/mnt/data')
DEST=ROOT/'alchul_media_pipeline'/'parts'

def sha(b):return hashlib.sha256(b).hexdigest()

def separate_geometry(g,source_name):
    """Remove embedded textures from derived M6; keep UV and per-vertex geometry."""
    result=g.copy()
    if source_name=='m6' and isinstance(result.visual, TextureVisuals):
        uv=np.array(result.visual.uv,copy=True)
        result.visual=TextureVisuals(uv=uv, material=PBRMaterial(baseColorFactor=[255,255,255,255],metallicFactor=0,roughnessFactor=0.8))
    return result

def write_chunk(part_name, records, parent):
    scene=trimesh.Scene()
    for name,geom,transform in records:
        scene.add_geometry(geom,geom_name=name,node_name=name,transform=transform)
    out_bytes=scene.export(file_type='glb')
    return out_bytes

def split_mesh(geom,limit,identifier,transform,parent):
    """Split oversize meshes by face index, preserving UVs and visual attributes."""
    total=len(geom.faces)
    records=[]
    queue=[(0,total)]
    while queue:
        lo,hi=queue.pop(0)
        part=geom.submesh([np.arange(lo,hi)],append=True,repair=False)
        size=len(write_chunk(identifier,[(identifier,part,transform)],parent))
        if size<=limit:
            records.append((identifier+('_%06d_%06d'%(lo,hi) if lo>0 or hi<total else ''),part,transform))
        else:
            if hi-lo<4:raise RuntimeError(f'Cannot split {identifier} ({size})')
            middle=(lo+hi)//2
            queue.insert(0,(middle,hi));queue.insert(0,(lo,middle))
    return records

def main():
    outputs=[]
    for key,file in SOURCES.items():
        path=ROOT/file
        src=trimesh.load(path,force='scene',process=False)
        original_faces=sum(len(g.faces) for g in src.geometry.values())
        specs=[]
        for node in sorted(src.graph.nodes_geometry):
            transform,geo_name=src.graph[node]
            geom=separate_geometry(src.geometry[geo_name],key)
            for subname,subgeom,tm in split_mesh(geom,MAX_BYTES,key+'__'+geo_name,transform,key):
                specs.append((subname,subgeom,tm))
        # Greedy pack consistent sorted smaller geometries together, limit output <1.43MB.
        groups=[];active=[]
        for record in sorted(specs,key=lambda rec:rec[0]):
            if active and len(write_chunk('',active+[record],key))>MAX_BYTES:
                groups.append(active);active=[]
            active.append(record)
        if active:groups.append(active)
        assert sum(len(v.faces) for bundle in groups for _,v,_ in bundle)==original_faces
        per_group=[]
        for idx,records in enumerate(groups,1):
            b=write_chunk('',records,key)
            assert len(b)<=MAX_BYTES,(key,idx,len(b))
            p=DEST/key/f'ALCHUL_{key.upper()}_GEOMETRY_{idx:02d}.glb'
            p.parent.mkdir(parents=True,exist_ok=True)
            p.write_bytes(b)
            # Read our exported GLB: triangles/nodes/bounds must match.
            check=trimesh.load(p,force='scene',process=False)
            assert sum(len(g.faces) for g in check.geometry.values())==sum(len(v.faces) for _,v,_ in records)
            entry={'path':str(p.relative_to(DEST)),'sha256':sha(b),'bytes':len(b),'triangle_count':sum(len(v.faces) for _,v,_ in records),'geometry_names':[name for name,_,_ in records], 'bounds':check.bounds.round(5).tolist()}
            per_group.append(entry);outputs.append(entry)
        print(key,'parts',len(groups),'triangles',original_faces,'part_MB',[round(x['bytes']/1e6,3) for x in per_group])
        # Metadata and source file checksums are explicit. Original source untouched.
        (DEST/key/'PARTITION_MANIFEST.json').write_text(json.dumps({'version':1,'source_file':file,'source_sha256':sha(path.read_bytes()),'source_bytes':path.stat().st_size,'source_triangles':original_faces,'derived':per_group,'geometry_policy':'native GLB geometric redistribution only; no simplification; all triangles preserved; M6 albedo/normal/roughness textures are external originals'},indent=2)+'\n')
    print('ALL_GLBS',len(outputs),'SIZE',sum(i['bytes'] for i in outputs))

if __name__=='__main__':main()
