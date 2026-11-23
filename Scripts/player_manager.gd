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
	var spawned_troop: Node3D = spawnable_troop.troop_prefab.instantiate() as Node3D
	spawned_troop.path = start_selected_spawner.get_next_path()
	add_child(spawned_troop)
	spawned_troop.global_position = MovementUtilities.get_path_start_position(spawned_troop.path)
	pass
