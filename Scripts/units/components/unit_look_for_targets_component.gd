extends Node
class_name UnitLookForTargetsComponent

## Component that look for possible targets

@export var targets_area: Area3D
@export var targets_shape: CollisionShape3D ## shape of targets_area


## Set radius of the area
func set_radius(radius: float) -> void:
	# create a new shape, because the one in the scene is shared between every unit
	var shape := SphereShape3D.new()
	shape.radius = radius
	targets_shape.shape = shape


## Is this unit still in area?
func is_in_area(target: OrphanUnit) -> bool:
	return targets_area.overlaps_body(target)


## Check in area if there are units of this faction
func are_there_targets(faction_to_check: UnitUtilities.ECharacterFaction) -> bool:
	for body: Node3D in FightUtilities.find_targets_in_area(targets_area):
		var unit: OrphanUnit = body as OrphanUnit
		if unit and unit.is_alive and unit.faction == faction_to_check:
			return true
	
	return false


## Return the closest unit of this faction in area
func find_target(faction_to_check: UnitUtilities.ECharacterFaction) -> OrphanUnit:
	# keep only units of the requested faction
	var targets: Array[Node3D] = []
	for body: Node3D in FightUtilities.find_targets_in_area(targets_area):
		var unit: OrphanUnit = body as OrphanUnit
		if unit and unit.is_alive and unit.faction == faction_to_check:
			targets.append(unit)

	# then pick the best one
	return FightUtilities.get_best_target_in_list(targets_area.global_position, targets) as OrphanUnit
