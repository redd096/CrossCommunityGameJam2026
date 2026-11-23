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
	# instantiate troops and initialize them, one formation slot per unit
	var offsets: Array[Vector2] = MovementUtilities.get_formation_offsets(spawnable_troop.formation_size, spawnable_troop.formation_spacing, spawnable_troop.formation_max_columns)
	for slot: Vector2 in offsets:
		var spawned_troop: MovableOrphanUnit = spawnable_troop.troop_prefab.instantiate() as MovableOrphanUnit
		add_child(spawned_troop)
		spawned_troop.setup_movable_unit(spawner, slot)
