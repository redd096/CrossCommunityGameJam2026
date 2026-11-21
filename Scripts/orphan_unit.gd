extends CharacterBody3D
class_name OrphanUnit

@export var path : Path3D
@export var lookahead : float
@export var speed : float
@export var turn_speed : float
@export var targeting_sphere : MeshInstance3D
@export_flags_3d_physics var enemy_layer: int = 1<<(3-1) # default enemy layer is 3, to get its value in bit we do 1<<(layer-1)

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


func _find_target() -> Node3D:
	return FightUtilities.find_target(self, targeting_sphere.mesh.radius, enemy_layer)


func _input(event: InputEvent) -> void:
	pass
	

func _physics_process(delta : float) -> void:
	if (velocity.length() > 0) :
		state = CharacterState.FOLLOW_TARGET
	else :
		state = CharacterState.IDLE
	
	DebugDraw.draw_arrow_ray(position, velocity.normalized() * 2.0, 8.0, 0.5, Color.YELLOW)

	var target = _find_target()
	if (target != null) :
		DebugDraw.draw_sphere(position, targeting_sphere.mesh.radius, Color(1, 0, 0, .25))
	else :
		DebugDraw.draw_sphere(position, targeting_sphere.mesh.radius, Color(0, 1, 0, .25))
	
	if (target != null) :
		# rotate towards target
		var target_basis = Basis.looking_at(target.global_position)
		basis = basis.slerp(target_basis, turn_speed)
		velocity = Vector3.ZERO
		state = CharacterState.IDLE
	else :
		var direction := MovementUtilities.get_path_direction(path, global_position, lookahead)
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		
		# rotate towards velocity
		if (velocity.length() > 0) :
			var target_basis = Basis.looking_at(velocity)
			basis = basis.slerp(target_basis, turn_speed)
		
	move_and_slide()
