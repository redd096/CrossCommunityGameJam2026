extends Node
class_name UnitRagdollComponent

## [codeblock lang=text]
## How to create ragdoll:
## - select Skeleton3D in the unit
## - on topbar appear a "Skeleton3D" button, click it
## - then click Create Physical Skeleton
## - it will create a PhysicalBoneSimulator3D, and for every bone a PhysicalBone3D and a CollisionShape3D
## - edit them as you like
## - then call setup() or unflag PhysicalBoneSimulator3D.Active (to disable joint and collision in Play)
## [/codeblock]


@export var ragdoll: PhysicalBoneSimulator3D


## On start, disable ragdoll
func setup() -> void:
	stop_ragdoll()


## Start ragdoll (enable PhysicalBoneSimulator3D and every joint and collision in it) [br]
## and disable every collider and animation passed as parameter (e.g. disable the player collider and starts its ragdoll instead)
func start_ragdoll(colliders: Array[CollisionShape3D] = [], animations: Array[AnimationTree] = []) -> void:
	# disable elements
	for c: CollisionShape3D in colliders:
		c.disabled = true
	for a: AnimationTree in animations:
		a.active = false
	
	# and start ragdoll
	ragdoll.active = true						# enable joints colliders
	ragdoll.physical_bones_start_simulation()	# start physics simulation


## Stop ragdoll (disable PhysicalBoneSimulator3D and every joint and collision in it) [br]
## and enable every collider and animation passed as parameter (e.g. re-enable player collider and stop its ragdoll)
func stop_ragdoll(colliders: Array[CollisionShape3D] = [], animations: Array[AnimationTree] = []) -> void:
	# stop ragdoll
	ragdoll.physical_bones_stop_simulation()	# stop physics simulation
	ragdoll.active = false						# disable joints colliders

	# and re-enable elements
	for c: CollisionShape3D in colliders:
		c.disabled = false
	for a: AnimationTree in animations:
		a.active = true