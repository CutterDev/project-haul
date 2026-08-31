extends Control

@onready var shield_label: Label = $VBoxContainer/HB/Shields
@onready var max_shield_label: Label = $VBoxContainer/HB2/MaxShields

var shield_system: ShieldSystem

var last_value: float = 0.0
var last_max_value: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func initialize_system(system: ShieldSystem):
	shield_system = system



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var shield_value = shield_system.current_shield
	var max_shield_value = shield_system.max_shield

	if not is_equal_approx(last_value, shield_value):
		last_value = shield_value
		shield_label.text = "%5.2f" % shield_value
	if not is_equal_approx(last_max_value, max_shield_value):
		last_max_value = max_shield_value
		max_shield_label.text = "%5.2f" % max_shield_value
