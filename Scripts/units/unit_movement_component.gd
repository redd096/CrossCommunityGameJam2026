extends Node
class_name UnitMovementComponent

## The character component used to move along path. [br]
## This uses avoidance_agent to avoid the other units

@export var avoidance_agent: NavigationAgent3D ## units avoid each other (RVO avoidance, no navmesh needed)
@export var speed: float = 5.0
@export var lookahead: float = 1.5 ## calculate next point by currentPositionOnPath + lookahead
@export var turn_speed : float = 0.75

# avoidance priority: a waiting unit moves aside for the others, a stopped unit (e.g. attacking) doesn't move for anyone
const WAITING_PRIORITY: float = 0.3
const MOVING_PRIORITY: float = 0.5
const STOPPED_PRIORITY: float = 1.0

enum EMovementState { WAITING, MOVING, STOPPED }

var _unit: CharacterBody3D ## the unit to move when avoidance_agent returns the safe velocity
var movement_state: EMovementState


func _ready() -> void:
	# register to events
	avoidance_agent.velocity_computed.connect(_on_velocity_computed)
	# set default values
	avoidance_agent.avoidance_priority = STOPPED_PRIORITY


## Move unit along path. Call it every physics frame [br]
## move_forward: true if move along path, false if move in reverse [br]
## side_offset: lane to keep along the path (negative = left, positive = right, 0 = center) [br]
## Return true when the unit reached the end of its lane
func move(unit: CharacterBody3D, path: Path3D, move_forward: bool, side_offset: float = 0.0) -> bool:
	_unit = unit
	avoidance_agent.avoidance_priority = MOVING_PRIORITY
	movement_state = EMovementState.MOVING

	# move along path by lookahead
	var lookahead_value: float = lookahead if move_forward else -lookahead
	var direction := MovementUtilities.get_path_direction(path, unit.global_position, lookahead_value, side_offset)
	unit.velocity.x = direction.x * speed
	unit.velocity.z = direction.z * speed

	# send the desired velocity to avoidance_agent, the movement happens in _on_velocity_computed
	NavigationServer3D.agent_set_velocity(avoidance_agent.get_rid(), unit.velocity)

	# no direction means we reached the end of our lane
	return direction == Vector3.ZERO


## Wait on this place. The unit moves aside when other units need to pass
func wait(unit: CharacterBody3D) -> void:
	_unit = unit
	avoidance_agent.avoidance_priority = WAITING_PRIORITY
	movement_state = EMovementState.WAITING

	# tell avoidance_agent we want to stay still
	unit.velocity = Vector3.ZERO
	NavigationServer3D.agent_set_velocity(avoidance_agent.get_rid(), Vector3.ZERO)


## Stop movement. The unit becomes an obstacle for the other units
func stop(unit: CharacterBody3D) -> void:
	_unit = null
	avoidance_agent.avoidance_priority = STOPPED_PRIORITY
	movement_state = EMovementState.STOPPED

	# tell avoidance_agent we want to stay still
	unit.velocity = Vector3.ZERO
	NavigationServer3D.agent_set_velocity(avoidance_agent.get_rid(), Vector3.ZERO)


## Return distance to start or end path [br]
## move_forward: true, return length to end of the path; false, return length to the start
func get_to_end_distance(unit: CharacterBody3D, path: Path3D, move_forward: bool) -> float:
	# distance to start or end path
	var path_pos: Vector3 = MovementUtilities.get_path_end_position(path) if move_forward else MovementUtilities.get_path_start_position(path)
	var to_end: Vector3 = path_pos - unit.global_position
	to_end.y = 0.0 # ignore y
	return to_end.length()


## Called by the NavigationAgent3D in the same physics frame, with the desired velocity adjusted to avoid the other agents
func _on_velocity_computed(safe_velocity: Vector3) -> void:
	# stopped (or never moved): nothing to do
	if _unit == null:
		return

	# avoidance works only on the ground plane (XZ), keep Y as it is
	_unit.velocity.x = safe_velocity.x
	_unit.velocity.z = safe_velocity.z

	# rotate towards velocity (ignore y) - but don't rotate while waiting to avoid rotate also attack area
	var flat_velocity := Vector3(_unit.velocity.x, 0.0, _unit.velocity.z)
	if movement_state != EMovementState.WAITING and flat_velocity.length() > 0.01:
		var target_basis = Basis.looking_at(flat_velocity)
		_unit.basis = _unit.basis.slerp(target_basis, turn_speed)

	_unit.move_and_slide()
