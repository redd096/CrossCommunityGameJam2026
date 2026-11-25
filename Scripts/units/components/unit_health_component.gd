extends Node
class_name UnitHealthComponent

## The character component used show health. [br]
@export var health_bar : UnitHealthBar

var _unit: OrphanUnit ## the unit to get the health value from
var _prev_hp: float ## previous unit HP

func init(unit: OrphanUnit):
	_unit = unit
	health_bar.set_max_health(unit.start_hp)

func _process(_delta: float) -> void:
	if (_unit.current_hp != _prev_hp):
		_prev_hp = _unit.current_hp
		health_bar.set_health(_unit.current_hp)
