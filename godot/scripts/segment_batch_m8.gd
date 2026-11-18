extends Node3D

## M8 browser optimization: group many variable-length stone/root/timber
## beams into one shared cylinder MultiMesh per material.
## Geometry positions and visual colors remain unchanged conceptually.
## This is a *draw-call reduction*, not approved high-fidelity LOD.

var groups: Dictionary = {}
const CYLINDER_RADIUS: float = 1.0

func add_rod(a: Vector3, b: Vector3, radius: float, material: Material) -> void:
	var offset: Vector3 = b - a
	if offset.length_squared() < 0.000001:
		return
	var key: int = material.get_instance_id()
	if not groups.has(key):
		groups[key] = {"material": material, "instances": []}
	var records: Array = groups[key]["instances"]
	var orientation := Basis(Quaternion(Vector3.UP, offset.normalized()))
	var scaled := orientation.scaled(Vector3(radius, offset.length(), radius))
	records.append(Transform3D(scaled, (a + b) * 0.5))

func flush() -> void:
	for key in groups.keys():
		var record: Dictionary = groups[key]
		var transforms: Array = record["instances"]
		if transforms.is_empty():
			continue
		var shape := CylinderMesh.new()
		shape.height = 1.0
		shape.bottom_radius = CYLINDER_RADIUS
		shape.top_radius = 0.86
		shape.radial_segments = 7
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = shape
		multimesh.instance_count = transforms.size()
		for i in range(transforms.size()):
			multimesh.set_instance_transform(i, transforms[i])
		var node := MultiMeshInstance3D.new()
		node.name = "BatchedRootStoneBeams_%s" % str(key)
		node.multimesh = multimesh
		node.material_override = record["material"]
		add_child(node)
	groups.clear()
