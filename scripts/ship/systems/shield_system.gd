extends PoweredSystem
class_name ShieldSystem

var current_shield: float = 0
var shield_per_bar: float = 250


func _ready():
	minimum_power_needed = 2



func max_shield():
	return current_power * shield_per_bar