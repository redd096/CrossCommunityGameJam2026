extends CharacterBody3D
class_name OrphanUnit


@export var path : Path3D
@export var lookahead : float
@export var speed : float
@export var turn_speed : float

enum CharacterState
{
	IDLE,
	FOLLOW_TARGET,
	ATTACK_TARGET,
	HIT,
	DEAD
}

var state : CharacterState

func check_collisions() -> void :
	pass

func set_path(newpath : Path3D) -> void:
	path = newpath
	

func _input(event: InputEvent) -> void:
	pass
	

func _process(delta : float) -> void :	
	if (velocity.length() > 0) :
		state = CharacterState.FOLLOW_TARGET
	else :
		state = CharacterState.IDLE
	
	DebugDraw.draw_arrow_ray(position, velocity, 8.0, 0.5, Color.YELLOW)
	if (velocity.length() > 0) :
		var target_basis = Basis.looking_at(velocity)
		basis = basis.slerp(target_basis, turn_speed)


func _physics_process(delta : float) -> void:
	var direction := MovementUtilities.get_path_direction(path, global_position, lookahead)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
