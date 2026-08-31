extends Control

@onready var oxygen_label: Label = $HB/Oxygen

var oxygen_system: OxygenSystem

var last_value: float = 0.0
func initialize_system(system: OxygenSystem):
	oxygen_system = system


func _process(_delta: float) -> void:
	if not is_equal_approx(last_value, oxygen_system.oxygen_levels):
		last_value = oxygen_system.oxygen_levels
		set_oxygen_label()

func set_oxygen_label():
	oxygen_label.text = "%3.2f" % oxygen_system.oxygen_levels
