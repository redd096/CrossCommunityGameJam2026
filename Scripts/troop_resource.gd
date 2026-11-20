class_name TroopResource extends Resource
## ScriptableObject for the troop, used by PlayerUI to show buttons and spawn troops on click

@export var troop_name: StringName
@export var troop_prefab: PackedScene # Troop script?
@export var cost: int = 10
@export var icon: Texture2D