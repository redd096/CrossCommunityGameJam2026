class_name PlayerUISpawnButton extends Control
## Button showed in PlayerUI to spawn troops

@export var button: Button

var _troop: TroopResource
var _on_click_callback: Callable


func _ready() -> void:
	# register event
	button.pressed.connect(_on_click)


## Save values and update ui
func setup(troop: TroopResource, on_click_callback: Callable) -> void:
	_troop = troop
	_on_click_callback = on_click_callback

	button.text = str(troop.troop_name, "\n", troop.cost, "p")
	button.icon = troop.icon


func _on_click() -> void:
	# when button is clicked, call callback
	if _on_click_callback:
		_on_click_callback.call(_troop)
	