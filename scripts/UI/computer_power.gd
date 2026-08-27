extends Control
class_name PowerComputer
@onready var systems: HBoxContainer = $Panel/MarginContainer/VBoxContainer/PowerSystems
@onready var power_container: HBoxContainer = $Panel/MarginContainer/VBoxContainer/MarginContainer/TotalPower

var power_system_ps = preload("res://scenes/ui/powersystem/powersystem.tscn")
var power_node_ps = preload("res://scenes/ui/powersystem/powernode.tscn")

var current_power = 0 
var power_nodes: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func init_system(node_amount: int) -> void:
	current_power = node_amount
	for x in node_amount:
		print("add power")
		var power_node = power_node_ps.instantiate()
		power_container.add_child(power_node)
		power_nodes.push_back(power_node)


func add_system(system_node):
	var new_system: ComputerPowerSystem = power_system_ps.instantiate()
	new_system.system_name = system_node.name
	new_system.attempted_power_increment.connect(_on_system_power_incremented)
	new_system.power_decremented.connect(_on_system_power_decremented)
	systems.add_child(new_system)


func _on_system_power_incremented(sender: ComputerPowerSystem):
	if current_power > 0:
		current_power -= 1
		var power_node = power_nodes.pop_back()
		sender.add_power(power_node)

func _on_system_power_decremented(_sender: ComputerPowerSystem, power_node):
	power_nodes.push_back(power_node)
	current_power += 1
	power_node.reparent(power_container)
