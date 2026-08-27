extends Control
class_name ComputerPowerSystem
signal attempted_power_increment(sender: ComputerPowerSystem)
signal power_decremented(sender: ComputerPowerSystem, power_node)

@onready var system_label: Label =  $Vbox/Margin/SystemName
@onready var increment_node: Button = $Vbox/Increase
@onready var decrement_node: Button = $Vbox/Decrease
@onready var power_nodes_container: VBoxContainer = $Vbox/Panel/Margin/PowerNodes

var system_name: String = ""

var total_power: int = 0
var power_nodes: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	system_label.text = system_name
	increment_node.pressed.connect(_on_increment_pressed)
	decrement_node.pressed.connect(_on_decrement_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_decrement_pressed():
	if total_power > 0:
		total_power -= 1
		var power_node = power_nodes.pop_back()
		
		power_decremented.emit(self,power_node)


func _on_increment_pressed():
	attempted_power_increment.emit(self)

func add_power(power_node: Control):
	total_power += 1
	power_node.reparent(power_nodes_container)
	power_nodes.push_back(power_node)
