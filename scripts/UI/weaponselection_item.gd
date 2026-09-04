extends MarginContainer
class_name SelectableWeapon
signal request_power_down(weapon_name: String)
signal request_power_up(weapon_name: String)
signal weapon_selected(item: SelectableWeapon)
@onready var weapon_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/WeaponName
@onready var offline_section: Control = $MarginContainer/HBoxContainer/VBoxContainer/Offline
@onready var online_section: Control = $MarginContainer/HBoxContainer/VBoxContainer/Online
@onready var online_status: Label = $MarginContainer/HBoxContainer/VBoxContainer/Online/Status
@onready var charge_bar: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/Online/ProgressBar
var weapon_name: String = ""
var weapon_priority: int = -1
var weapon: Weapon = null
var weapon_powered: bool = false

var requested: bool = false
func _ready() -> void:
	weapon_label.text = weapon_name


func _on_button_pressed() -> void:
	if weapon_powered:
		request_power_down.emit(weapon_name)
	else:
		request_power_up.emit(weapon_name)
	requested = true
	weapon_selected.emit(self)

func weapon_status_changed(status: Weapon.WeaponStatus):
	if status == Weapon.WeaponStatus.OFFLINE:
		weapon_powered = false
		offline_section.visible = true
		online_section.visible = false
	else:
		weapon_powered = true
		online_section.visible = true
		offline_section.visible = false
		match status:
			Weapon.WeaponStatus.CHARGING:
				weapon_label.text = "Charging"
			Weapon.WeaponStatus.READY:
				weapon_label.text = "Ready"
			Weapon.WeaponStatus.FIRING :
				weapon_label.text = "Firing!!!!"

func charge_progress_changed(progress: float):
	charge_bar.value = progress

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		modulate = Color.hex(0x54a3e8)
		weapon_selected.emit(self)

func unselect():
	modulate = Color.hex(0xFFFFFF)

func select():
	modulate = Color.hex(0x54a3e8)