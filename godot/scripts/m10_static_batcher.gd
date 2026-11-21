extends RefCounted

## ALCHUL M10 controlled CPU-side static mesh merging.
## This operates ONLY on explicitly selected noncanonical procedural modules.
## It bakes each original MeshInstance3D's full local Transform3D into its vertices,
## rather than using the previously rejected M8 MultiMesh beam transform shortcut.
## Source GLBs, materials, collision meshes and default scene hierarchy stay intact.
##
## Geometry is grouped by material and surface attribute format. No UVs are invented.
## The target should have direct mesh children and no animated meshes or collision nodes.

static func _triangles(mesh: Mesh) -> int:
	var total: int = 0
	for surface_index in range(mesh.get_surface_count()):
		var arrays: Array = mesh.surface_get_arrays(surface_index)
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		total += (indices.size() if indices.size() > 0 else vertices.size()) / 3
	return total

static func batch_direct_static_meshes(target: Node3D, chunk_size: float = 0.0) -> Dictionary:
	var groups: Dictionary = {}
	var eligible: Array[MeshInstance3D] = []
	var original_triangles: int = 0
	var untouched: int = 0
	for node in target.get_children():
		if not (node is MeshInstance3D):
			continue
		var item := node as MeshInstance3D
		var mesh: Mesh = item.mesh
		var material: Material = item.material_override
		if mesh == null or material == null or mesh.get_surface_count() != 1:
			untouched += 1
			continue
		# Preserve source alpha draw order; do not combine transparent water planes.
		if material is BaseMaterial3D and (material as BaseMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
			untouched += 1
			continue
		if not (mesh is PrimitiveMesh):
			untouched += 1
			continue
		# Do not batch any skinned, shadow-only, or collision-bearing objects.
		if item.skin != null or item.get_child_count() != 0:
			untouched += 1
			continue
		# PrimitiveMesh does not expose ArrayMesh's surface_get_format method.
		# Inspect its real surface arrays to keep dissimilar formats isolated.
		var source_arrays: Array = mesh.surface_get_arrays(0)
		var format_flags: int = 0
		for attribute in [Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_COLOR, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_TEX_UV2]:
			if source_arrays[attribute] != null and source_arrays[attribute].size() > 0:
				format_flags |= 1 << attribute
		var signature: String = str(material.get_instance_id()) + ":" + str(format_flags)
		# Optional spatial buckets retain broad-area tree culling instead of
		# combining everything into a single enormous always-visible mesh.
		if chunk_size > 0.0:
			signature += ":" + str(floori(item.position.x / chunk_size))
			signature += ":" + str(floori(item.position.z / chunk_size))
		if not groups.has(signature):
			var tool := SurfaceTool.new()
			tool.begin(Mesh.PRIMITIVE_TRIANGLES)
			groups[signature] = {
				"tool": tool,
				"material": material,
				"count": 0
			}
		var group: Dictionary = groups[signature]
		var st: SurfaceTool = group["tool"]
		st.append_from(mesh, 0, item.transform)
		group["count"] = int(group["count"]) + 1
		original_triangles += _triangles(mesh)
		eligible.append(item)
	# Leave the originals alone if the optimization has nothing worth reducing.
	if eligible.size() < 10 or groups.size() >= eligible.size():
		return {"applied": false, "original_nodes": eligible.size(),
			"merged_nodes": 0, "triangles_before": original_triangles,
			"triangles_after": original_triangles, "untouched": untouched}
	var combined_meshes: Array[MeshInstance3D] = []
	var baked_triangles: int = 0
	for key in groups.keys():
		var group: Dictionary = groups[key]
		var st: SurfaceTool = group["tool"]
		var combined: ArrayMesh = st.commit()
		if combined == null or combined.get_surface_count() != 1:
			push_error("M10 STATIC BATCH: a combined material group failed")
			return {"applied": false, "error": "surface_tool_commit_failed"}
		baked_triangles += _triangles(combined)
		var merged := MeshInstance3D.new()
		merged.name = "M10_BakedStatic_" + str(combined_meshes.size())
		merged.mesh = combined
		merged.material_override = group["material"]
		combined_meshes.append(merged)
	if baked_triangles != original_triangles:
		push_error("M10 STATIC BATCH: triangle conservation failed, leaving source unchanged")
		return {"applied": false, "error": "triangle_mismatch", "before": original_triangles,
			"after": baked_triangles}
	# All-or-nothing change after successful mesh construction; preserve original
	# resources for verification and keep all source assets immutable.
	for item in eligible:
		target.remove_child(item)
		item.queue_free()
	for item in combined_meshes:
		target.add_child(item)
	return {
		"applied": true,
		"original_nodes": eligible.size(),
		"merged_nodes": combined_meshes.size(),
		"triangles_before": original_triangles,
		"triangles_after": baked_triangles,
		"untouched": untouched,
		"method": "SurfaceTool.append_from + exact local transforms by material",
		"spatial_chunk_m": chunk_size
	}
