extends CharacterBody3D
## Test script:
## - move with normal CharacterBody3D but follow Path3D direction
## - use side_offset to keep your "lane"
## - use avoidance_agent to avoid other bodies on the path
## - stop when reach end or gave up because there are other units in front of you
## - try again to move after few seconds, maybe now the units in front of you are moving away

@export var path: Path3D
@export var speed: float = 4.0
@export var lookahead: float = 1.5 ## calculate next point by currentPositionOnPath + lookahead
@export var side_offset: float = 0.0 ## distance from the path center (negative = left, positive = right, 0 = center)
@export var avoidance_agent: NavigationAgent3D ## units avoid each other (RVO avoidance, no navmesh needed)
@export_group("Give up")
@export var give_up_time: float = 1.0 ## seconds without getting closer to the path end, before giving up
@export var min_progress: float = 0.2 ## how much closer we must get to the path end, to reset give_up_time
@export var retry_time: float = 3.0 ## seconds to stay ARRIVED because gave up, before try moving again

#region state machine

enum State
{
	MOVE,		## follow the path, avoiding the other units
	ARRIVED,	## reached the path end, or gave up because we can't get closer (there are other units on the path end)
}

var state: State = State.MOVE

# avoidance priority: if an agent reached the end path, it doesn't move for other units
const MOVING_PRIORITY: float = 0.5
const ARRIVED_PRIORITY: float = 1.0

# MOVE vars
var _give_up_timer: float = 0.0	## if timers reach end, give up to movement
var _best_distance: float = INF ## check if there is a progress to the end of the path, else give up

# ARRIVED vars
var _retry_timer: float = 0.0 ## maybe an ally died, or moved, and there is a free spot now

#endregion


func _ready() -> void:
	# register to events
	if avoidance_agent:
		avoidance_agent.velocity_computed.connect(_on_velocity_computed)

	# set start state
	_set_state(State.MOVE)


# copy-paste from CharacterBody3D code in godot
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	match state:
		State.MOVE:
			# increase "give up timer"
			_give_up_timer += delta

			# distance to end path (ignore y)
			var to_end: Vector3 = MovementUtilities.get_path_end_position(path) - global_position
			to_end.y = 0.0
			var distance: float = to_end.length()

			# if we moved near the end path, reset "give up timer"
			if distance < _best_distance - min_progress:
				_best_distance = distance
				_give_up_timer = 0.0
			# else, if "give up timer" is completed, stop moving
			elif _give_up_timer > give_up_time:
				_set_state(State.ARRIVED)

			# calculate direction to move along the path
			var direction: Vector3 = MovementUtilities.get_path_direction(path, global_position, lookahead, side_offset)

			# and velocity
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

			# no direction means we reached the end of our lane
			if direction == Vector3.ZERO:
				_set_state(State.ARRIVED)

		State.ARRIVED:
			# increase "retry timer"
			_retry_timer += delta

			# if "retry timer" is completed, try again to move to the end path
			if _retry_timer > retry_time:
				_set_state(State.MOVE)
			
			# velocity in this state is always 0
			velocity.x = 0.0
			velocity.z = 0.0

	# send the desired velocity to avoidance_agent (every frame, also when still), the movement happens in _on_velocity_computed
	NavigationServer3D.agent_set_velocity(avoidance_agent.get_rid(), velocity)


## Called by the NavigationAgent3D in the same physics frame, with the desired velocity adjusted to avoid the other agents
func _on_velocity_computed(safe_velocity: Vector3) -> void:
	# if arrived, don't move. Now this unit is an obstacle for the others
	if state == State.ARRIVED:
		safe_velocity = Vector3.ZERO
	# avoidance works only on the ground plane (XZ), ignore gravity (Y)
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	move_and_slide()


func _set_state(new_state: State) -> void:
	# set state
	state = new_state

	# set avoidance priority if moving or arrived
	avoidance_agent.avoidance_priority = MOVING_PRIORITY if state == State.MOVE else ARRIVED_PRIORITY

	# reset vars
	_give_up_timer = 0.0
	_best_distance = INF
	_retry_timer = 0.0
