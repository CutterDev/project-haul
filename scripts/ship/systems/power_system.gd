extends Node3D
## This handles the power for the ship and passing power nodes to each
## system that needs power
class_name ShipSystem

@export var start_power: int = 6

@onready var power_computer: PowerComputer= $"../PowerSystemComputer/Computer/SubViewport/Control"

var weapon_node_name: String = "WeaponSystem"
var weapon_system: WeaponSystem

var oxygen_node_name: String = "OxygenSystem"
var oxygen_system: OxygenSystem

var shield_node_name: String = "ShieldSystem"
var shield_system: ShieldSystem

var engine_node_name: String = "EngineSystem"
var engine_system: EngineSystem


func _ready() -> void:
	get_systems()
	power_computer.init_system(start_power)

# Functions
func get_systems() -> void:
	if has_node(shield_node_name):
		shield_system = get_node(shield_node_name)
		power_computer.add_system(shield_system)
	if has_node(oxygen_node_name):
		oxygen_system = get_node(oxygen_node_name)
		power_computer.add_system(oxygen_system)
	if has_node(weapon_node_name):
		weapon_system = get_node(weapon_node_name)
		power_computer.add_system(weapon_system)
	if has_node(engine_node_name):
		engine_system = get_node(engine_node_name)
		power_computer.add_system(engine_system)
