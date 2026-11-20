extends CharacterBody3D
class_name OrphanUnit


@export var path : Path3D
@export var lookahead : float
@export var speed : float


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
	
	DebugDraw.draw_arrow_ray(position, velocity, 8.0, 0.5, Color.YELLOW)
	var target_basis = Basis.looking_at(velocity)
	basis = basis.slerp(target_basis, 0.5)


func _physics_process(delta : float) -> void:
	var direction := MovementUtilities.get_path_direction(path, lookahead, global_position)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	move_and_slide()
