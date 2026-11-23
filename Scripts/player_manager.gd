class_name PlayerManager extends Node
## Player manager: manage mana, selected spawn and so on


@export var start_selected_spawner: MapNode
@export var spawnable_troop: TroopResource
@export var timer : float
@export var spawn_interval : float


func _process(delta: float) -> void:
	timer += delta;
	if (timer > spawn_interval) :
		timer = 0
		_spawn_troop()


func _spawn_troop() :
	var spawned_troop: OrphanUnit = spawnable_troop.troop_prefab.instantiate() as OrphanUnit
	add_child(spawned_troop)
	spawned_troop.setup(start_selected_spawner)
	pass
