class_name PlayerUIManager extends Control
## Manager used to update the UI of the player

@export var player_manager: PlayerManager
@export var mana_slider: Slider
@export var mana_label: Label
@export var button_prefab: PackedScene # PlayerUISpawnButton
@export var buttons_container: Control


func _ready() -> void:
	# connect events
	player_manager.on_update_mana.connect(set_mana)
	# set default values
	set_mana(player_manager.current_mana, player_manager.max_mana)
	set_spawnable_troops(player_manager.spawnable_troops)


## Update mana slider
func set_mana(value: float, max_value: float) -> void:
	mana_slider.max_value = max_value
	mana_slider.value = value
	mana_label.text = str(value as int, " / ", max_value as int)


## Set buttons to spawn troops
func set_spawnable_troops(spawnable_troops: Array[TroopResource]) -> void:
	# clear previous buttons
	for child: Node in buttons_container.get_children():
		child.queue_free()
	
	# instantiate new buttons
	for troop: TroopResource in spawnable_troops:
		var new_button: PlayerUISpawnButton = button_prefab.instantiate() as PlayerUISpawnButton
		new_button.setup(troop, player_manager.try_spawn_troop)
		buttons_container.add_child(new_button)
