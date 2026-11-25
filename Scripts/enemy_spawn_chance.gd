class_name EnemySpawnChance extends Resource

## Used by EnemyManager: a troop and percentage to be spawned

## the troop to spawn
@export var troop: TroopResource
## relative to the sum of the list, so it works also if the total is greater than 100 (0 = never)
@export_range(0.0, 100.0, 1.0, "suffix:%") var percentage: float = 100.0 
