extends Node3D

## Holds the Power, oxygen etc
class_name ShipSystem

var hull_health: float = 1000
var max_health: float = 1000

var rooms: Array[ShipRoom] = []

func _ready() -> void:
	global_position *= SpaceScale.world_scale
	for room in $Rooms.get_children():
		rooms.append(room)

func get_hull_integrity() -> float:
	return hull_health / max_health
