extends Control

## 2D annotated field map for the self-contained desktop chapter.
## This draws no invented historical architecture; pins match worldbook positions.
var sites: Array = []
var visited: Dictionary = {}
var observer: Node3D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(230, 190)
	set_process(true)

func _world_to_map(x: float, z: float) -> Vector2:
	var margin: float = 11.0
	var scale_x: float = (size.x - margin * 2.0) / 120.0
	var scale_z: float = (size.y - margin * 2.0) / 120.0
	return Vector2(margin + (x + 60.0) * scale_x, margin + (z + 60.0) * scale_z)

func _process(_delta: float) -> void:
	if visible and observer != null:
		queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.075, 0.12, 0.13, 0.88), true)
	for grid in range(1, 4):
		var t: float = float(grid) / 4.0
		draw_line(Vector2(size.x * t, 0.0), Vector2(size.x * t, size.y), Color(0.2, 0.3, 0.31, 0.24), 1.0)
		draw_line(Vector2(0.0, size.y * t), Vector2(size.x, size.y * t), Color(0.2, 0.3, 0.31, 0.24), 1.0)
	var river: PackedVector2Array = PackedVector2Array()
	for i in range(80):
		var x: float = -60.0 + 120.0 * float(i) / 79.0
		var z: float = -13.0 + sin(x * 0.065) * 4.5
		river.append(_world_to_map(x, z))
	draw_polyline(river, Color(0.25, 0.63, 0.65, 0.86), 3.0, true)
	for item in sites:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var position_data: Array = item.get("position", [])
		if position_data.size() != 2:
			continue
		var pin: Vector2 = _world_to_map(float(position_data[0]), float(position_data[1]))
		var done: bool = visited.has(str(item.get("id", "")))
		draw_circle(pin, 6.5, Color(0.08, 0.12, 0.12))
		draw_circle(pin, 4.0, Color(0.35, 0.75, 0.63) if done else Color(0.95, 0.70, 0.35))
	if observer != null:
		var current: Vector2 = _world_to_map(observer.position.x, observer.position.z)
		draw_circle(current, 8.0, Color(0.8, 0.95, 0.96, 0.28))
		draw_circle(current, 4.2, Color(0.96, 0.99, 0.99))
		var heading: float = float(observer.rotation.y)
		var forward: Vector2 = Vector2(-sin(heading), -cos(heading))
		draw_line(current, current + forward * 12.0, Color(0.96, 0.99, 0.99), 2.0)
