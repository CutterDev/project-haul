extends MarginContainer

@onready var weapon_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/WeaponName

var power_needed: int = 0
var weapon_name: String = ""

func _ready() -> void:
	weapon_label.text = weapon_name