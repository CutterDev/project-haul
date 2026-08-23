extends Node3D
## This handles the power for the ship and passing power nodes to each
## system that needs power
class_name PowerSystem

## How much power the ship holds.
var power_capacity: int = 0

var used_power: int = 0

var weapon_node_name: String = "WeaponSystem"
var weapon_system: WeaponSystem

var oxygen_node_name: String = "OxygenSystem"
var oxygen_system: OxygenSystem

var shield_node_name: String = "ShieldSystem"
var shield_system: ShieldSystem

func _ready() -> void:
	get_systems()






# Functions
func get_systems() -> void:
	if has_node(shield_node_name):
		shield_system = $shield_node_name
	if has_node(oxygen_node_name):
		shield_system = $oxygen_node_name
	if has_node(weapon_node_name):
		shield_system = $weapon_node_name
