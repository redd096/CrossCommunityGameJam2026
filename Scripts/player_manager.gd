class_name PlayerManager extends Node
## Player manager: manage mana, selected spawn and so on

@export_group("Mana")
@export var max_mana: int = 100
@export var increment_mana_per_second: float = 10
@export_group("Spawn and select spawn")
@export var camera: Camera3D
@export var spawners: Array[Spawner]	## Every spawner in scene the player can select
@export var start_selected_spawner: Spawner
@export_group("Troops")
@export var spawnable_troops: Array[TroopResource]

const RAY_LENGTH = 1000.0

var current_mana: float
var current_spawner: Spawner

signal on_update_mana(from: int, to: int)
signal on_select_spawner(previous_spawner: Spawner, new_spawner: Spawner)
signal on_spawn_troop(troop: Node3D)


func _ready() -> void:
	# on start set max mana
	add_mana(max_mana)
	set_spawner(start_selected_spawner)


func _process(delta: float) -> void:
	# increase mana over time
	add_mana(increment_mana_per_second * delta)


func _unhandled_input(event: InputEvent) -> void:
	# check left mouse button click,
	# use _unhandled_input to ignore clicks consumed by UI
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_select_spawner(event.position)


#region public api

## Add value to current mana
func add_mana(increment: float) -> void:
	current_mana = clampf(current_mana + increment, 0, max_mana)
	on_update_mana.emit(current_mana, max_mana)


## Remove value from current mana
func remove_mana(decrement: float) -> void:
	add_mana(-decrement)


## If enough mana, spawn troop on selected spawner
func try_spawn_troop(troop: TroopResource) -> void:
	# if mana is enough, decrease it to spawn troop on selected spawner
	if current_mana >= troop.cost:
		remove_mana(troop.cost)
		var spawned_troop: Node3D = troop.troop_prefab.instantiate() as Node3D
		add_child(spawned_troop)
		on_spawn_troop.emit(spawned_troop)
		print("todo - troop script and call init? - update also TroopResource.troop_prefab comment")
	# else, show warning
	else:
		print("todo - show warning when mana isn't enough")


## Set selected spawner
func set_spawner(spawner: Spawner) -> void:
	var previous_spawner: Spawner = current_spawner
	current_spawner = spawner
	on_select_spawner.emit(previous_spawner, current_spawner)

#endregion


func _try_select_spawner(mouse_position: Vector2) -> void:
	# raycast from camera to mouse position
	var from: Vector3 = camera.project_ray_origin(mouse_position)
	var to: Vector3 = from + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)

	# the collider is the spawner body (e.g. StaticBody3D)
	if not hit.is_empty() and hit.collider in spawners:
		set_spawner(hit.collider)
		print("todo - spawner script instead of Node3D?")
