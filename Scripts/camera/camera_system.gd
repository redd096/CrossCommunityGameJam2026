extends Node3D
class_name CameraSystem

@export var camera: Camera3D
@export var camera_target: PhysicsBody3D
@export var camera_offset: Vector3
@export var enable_move: bool
@export var enable_rotation: bool
@export var invert_rotation: bool
@export var enable_mouse_pan: bool
@export var enable_zoom: bool
@export var camera_move_speed: float
@export var rotation_speed: float
@export var drag_pan_speed: float
@export var zoom_speed: float
@export var zoom_min_dist: float
@export var zoom_max_dist: float
var velocity: Vector3 = Vector3.ZERO
var zoom: float = 0.0
var mouse_relative_pos: Vector2


func _ready() -> void:
	camera.position = camera_offset
	camera.look_at(camera_target.global_position)


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		mouse_relative_pos = event.screen_relative


func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	if (enable_move):
		velocity.z = Input.get_axis("camera_up", "camera_down")
		velocity.x = Input.get_axis("camera_left", "camera_right")
	
	if (enable_rotation):
		var direction: float = Input.get_axis("camera_rotate_left", "camera_rotate_right")
		if (invert_rotation):
			direction *= -1.0
		camera_target.rotate_y(rotation_speed * direction * delta)
	
	if (enable_mouse_pan):
		if (Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE)):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			velocity.x = -mouse_relative_pos.x * drag_pan_speed
			velocity.z = -mouse_relative_pos.y * drag_pan_speed
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if (enable_zoom):
		var zoom_dir: float = Input.get_axis("camera_zoom_in", "camera_zoom_out")
		
		if (zoom_dir != 0.0):
			var diff: Vector3 = (camera.global_position - camera_target.global_position).normalized()
			var next_position: Vector3 = camera.global_position + (zoom_dir) * (diff * delta * zoom_speed)
			var dist: float = (next_position - camera_target.global_position).length()
			if (dist < zoom_max_dist and dist > zoom_min_dist):
				camera.global_position = next_position
	
	var move_dir = camera_target.global_transform.basis.z * velocity.z + camera_target.global_transform.basis.x * velocity.x
	camera_target.move_and_collide(move_dir * camera_move_speed * delta)
