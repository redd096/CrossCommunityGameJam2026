extends Node
class_name EnemyManager

@export var spawner: MapNode
@export var spawnable_troop: TroopResource
@export var spawn_interval: float = 2.0

var spawn_timer : float

func _process(delta: float) -> void:
	# increase spawn timer
	spawn_timer += delta;

	# when completed, spawn troop
	if (spawn_timer > spawn_interval) :
		spawn_timer = 0
		_spawn_troop()


func _spawn_troop() :
	# instantiate troop and initialize it
	var spawned_troop: OrphanUnit = spawnable_troop.troop_prefab.instantiate() as OrphanUnit
	add_child(spawned_troop)
	spawned_troop.setup(spawner)
