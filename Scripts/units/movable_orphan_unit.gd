extends OrphanUnit
class_name MovableOrphanUnit

## Base class for a movable unit, used by Player and Enemy

@export var spawn_height: float = 1.0 ## fix spawn height, to avoid see unit half in the ground
@export var ragdoll: UnitRagdollComponent


## Called when an enemy attacks this unit
func receive_attack(_attacker_faction: UnitUtilities.ECharacterFaction, damage: float, from_position: Vector3) -> void:
	# already killed by another attack
	if current_hp <= 0.0:
		return

	current_hp = maxf(current_hp - damage, 0.0)

	# dead
	if current_hp <= 0.0:
		is_alive = false
		# stop the states
		state_machine.set_state(null)
		# remove from the node/path list
		state_machine.set_new_node_and_path(null, null)
		# destroy with ragdoll animation
		if ragdoll:
			var direction: Vector3 = global_position - from_position
			ragdoll.death_animation(direction)
		else:
			queue_free()
