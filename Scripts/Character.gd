extends Node
class_name Character

enum AnimState
{
	IDLE,
	RUN
}

var anim_state : AnimState

func _ready() -> void :
	anim_state = AnimState.IDLE

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("run")) :
		anim_state = AnimState.RUN
	if (event.is_action_released("run")) :
		anim_state = AnimState.IDLE
