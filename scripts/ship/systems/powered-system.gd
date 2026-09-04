extends Node3D
class_name PoweredSystem
signal power_changed(new_amount: int)

var current_power: int = 0

# Happens if room gets damaged too much.
var is_disabled: bool = false

func increment_power():
	current_power += 1
	power_changed.emit(current_power)
func decrement_power():
	current_power -= 1
	power_changed.emit(current_power)