extends Node3D
class_name AlchulObserver

## Editor-side visitor viewpoint. This is explicitly NOT a species-correct eye position.
## This camera moves over a matching terrain-height function without physics/collision promises.

const WALK_SPEED: float = 6.0
const FAST_FACTOR: float = 2.0
const POINTER_SENSITIVITY: float = 0.003

var terrain_height: Callable
var yaw: float = 0.0
var pitch: float = -0.11
var camera: Camera3D

func _ready() -> void:
	camera = Camera3D.new()
	camera.name = "VisitorCamera"
	camera.current = true
	camera.fov = 67.0
	camera.near = 0.08
	camera.far = 260.0
	camera.position = Vector3(0.0, 1.75, 0.0)
	camera.rotation.x = pitch
	add_child(camera)
	position = Vector3(0.0, _sample_height(0.0, 15.0), 15.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * POINTER_SENSITIVITY
		pitch = clampf(pitch - event.relative.y * POINTER_SENSITIVITY, -1.25, 1.05)
		rotation.y = yaw
		camera.rotation.x = pitch
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta: float) -> void:
	var rightward: float = 0.0
	var forward: float = 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		forward += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		forward -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		rightward += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		rightward -= 1.0

	var direction := Vector3(rightward, 0.0, -forward)
	if direction.length_squared() > 0.0:
		direction = direction.normalized().rotated(Vector3.UP, yaw)
		var speed := WALK_SPEED
		if Input.is_key_pressed(KEY_SHIFT):
			speed *= FAST_FACTOR
		position += direction * speed * delta

	position.x = clampf(position.x, -56.0, 56.0)
	position.z = clampf(position.z, -56.0, 56.0)
	position.y = lerpf(position.y, _sample_height(position.x, position.z), minf(1.0, delta * 10.0))

func _sample_height(x: float, z: float) -> float:
	if terrain_height.is_valid():
		return float(terrain_height.call(x, z))
	return 0.0
