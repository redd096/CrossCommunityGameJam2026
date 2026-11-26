class_name TroopResource extends Resource

## ScriptableObject for the troop, used by PlayerUI to show buttons and spawn troops on click [br]
## Stats are applied to unit on spawn

@export var troop_prefab: PackedScene ## MovableOrphanUnit
@export var faction: UnitUtilities.ECharacterFaction

@export_group("Stats")
@export var cost: int = 10 ## mana to spawn the whole formation
@export var formation_size: int = 1 ## how many units are spawned together with one click
@export var health: float = 100.0 ## health of every single unit
@export_range(0.0, 20.0, 0.1, "or_greater", "suffix:m/s") var move_speed: float = 5.0
@export_range(0.5, 20.0, 0.1, "or_greater", "suffix:m") var attack_range: float = 2.0 ## radius of the attack area (its center is 1m in front of the unit)
@export var attack_damage: float = 20.0 ## damage of every attack
@export_range(0.15, 10.0, 0.05, "or_greater", "suffix:s") var attack_delay: float = 0.2 ## seconds between attacks (minimum 0.15, because units look for targets every 0.1 seconds)

@export_group("Player UI")
@export var troop_name: StringName
@export var icon: Texture2D

@export_group("Formation")
@export var formation_max_columns: int = 3 ## max units side by side in a row
@export var formation_spacing: float = 1.2 ## distance between units, both side by side and between rows
