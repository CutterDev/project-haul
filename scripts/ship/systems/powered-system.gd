extends Node3D

class_name PoweredSystem

var current_power: int = 0

# Happens if room gets damaged too much.
var is_disabled: bool = false

func increment_power(amount: int):
	current_power += amount

func decrement_power(amount: int):
	current_power -= amount