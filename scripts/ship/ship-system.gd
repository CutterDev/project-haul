extends Node3D
## Holds the Power, oxygen etc
class_name ShipSystem

@export_file("*.tscn", "*.scn") var model_path: String
@export var is_model: bool = false

var hull_health: float = 1000
var max_health: float = 1000


var rooms: Array[ShipRoom] = []
var selected_weapon: Weapon = null
var selected_wep_num: int = -1
var weapons: Array [Weapon]

func _ready() -> void:
	print("ready")
	if not is_model:
		global_position *= SpaceScale.world_scale
	
	if has_node("Rooms"):
		for room in $Rooms.get_children():
			print(room.name)
			rooms.append(room)

func get_hull_integrity() -> float:
	return hull_health / max_health
