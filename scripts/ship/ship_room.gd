extends Area3D
class_name ShipRoom

signal taken_hit(damage: float)

@export var room_name: String = "room"

@onready var coll: CollisionShape3D = $CollisionShape3D

@export var powered_system: PoweredSystem
# 0.00 Percentage
## How much the room can take before its not functional anymore
var integrity: float = 1000.0


func take_damage(amount: float) -> void:
	taken_hit.emit(amount)