extends Control

@onready var weapon_label: Label = $VBoxContainer/Weapon
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_weapon_name(wep_name: String) -> void:
	print("Setting name")
	weapon_label.text = wep_name

func set_charge(progress: float):
	progress_bar.value = progress