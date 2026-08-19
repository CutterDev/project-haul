extends Node3D
## Holds the Power, oxygen etc
class_name ShipSystem

@export_file("*.tscn", "*.scn") var model_path: String



@export var is_model: bool = false
var hull_health: float = 1000
var max_health: float = 1000

var rooms: Array[ShipRoom] = []

func _ready() -> void:
	print("ready")
	if not is_model:
		global_position *= SpaceScale.world_scale
	for room in $Rooms.get_children():
		rooms.append(room)

func get_hull_integrity() -> float:
	return hull_health / max_health
