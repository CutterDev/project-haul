extends Node2D

const FULL_FUEL: float = 1000
var fuel: float = 0 

var rooms: Array[Room] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# 0 - 100.00%
func get_fuel_percentage() -> float:
	return fuel / FULL_FUEL
