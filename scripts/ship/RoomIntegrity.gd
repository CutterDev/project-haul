extends Area3D
class_name ShipRoom

signal taken_hit(damage: float)

@export var room_name: String = "room"

@onready var coll: CollisionShape3D = $CollisionShape3D

# 0.00 Percentage
## How much the room can take before its not functional anymore
var integrity: float = 100.0


