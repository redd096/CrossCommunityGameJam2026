extends Node
class_name EnemyManager

@export var spawner: MapNode
@export var spawnable_troops: Array[EnemySpawnChance] ## every time, one of these is picked randomly by its percentage
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
	# the spawner tower was conquered by the Player: stop spawning
	if spawner.current_faction != UnitUtilities.ECharacterFaction.ENEMY:
		return

	# pick a random troop
	var troop: TroopResource = _get_random_troop()
	if troop == null:
		push_warning("EnemyManager: there are no troops to spawn in spawnable_troops")
		return

	# instantiate troops and initialize them, one formation slot per unit
	var offsets: Array[Vector2] = MovementUtilities.get_formation_offsets(troop.formation_size, troop.formation_spacing, troop.formation_max_columns)
	for slot: Vector2 in offsets:
		var spawned_troop: MovableOrphanUnit = troop.troop_prefab.instantiate() as MovableOrphanUnit
		add_child(spawned_troop)
		spawned_troop.setup(troop, spawner, slot)


## Pick a random troop, using percentages. Return null if there are no valid troops
func _get_random_troop() -> TroopResource:
	# ignore empty elements of the array
	var chances: Array[EnemySpawnChance] = spawnable_troops.filter(func(chance: EnemySpawnChance): return chance and chance.troop and chance.percentage > 0.0)
	if chances.is_empty():
		return null

	# calculate total if the total isn't 100
	var total: float = 0.0
	for chance: EnemySpawnChance in chances:
		total += chance.percentage

	# e.g. with A=70 and B=30, a value under 70 is A, else B
	var random_value: float = randf() * total
	for chance: EnemySpawnChance in chances:
		random_value -= chance.percentage
		if random_value < 0.0:
			return chance.troop

	# fallback to the last in the list
	return chances.back().troop
