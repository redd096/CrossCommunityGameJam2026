class_name TroopResource extends Resource
## ScriptableObject for the troop, used by PlayerUI to show buttons and spawn troops on click

@export var troop_prefab: PackedScene # OrphanUnit

@export_group("Player UI")
@export var troop_name: StringName
@export var cost: int = 10
@export var icon: Texture2D

@export_group("Formation")
@export var formation_size: int = 1 ## how many units are spawned together with one click
@export var formation_max_columns: int = 3 ## max units side by side in a row
@export var formation_spacing: float = 1.2 ## distance between units, both side by side and between rows
