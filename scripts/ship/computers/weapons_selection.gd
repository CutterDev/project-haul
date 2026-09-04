extends Control
class_name WeaponsSelection
signal weapon_selected(weapon: Weapon)

@onready var weapons_list: VBoxContainer = $HBoxContainer/VBoxContainer/WeaponsList
@onready var power_amount: Label = $HBoxContainer/VBoxContainer/PowerLabel

var weapon_item_ps: PackedScene = preload("res://scenes/ui/weaponselection_item.tscn")
# Called when the node enters the scene tree for the first time.

var weapon_items: Dictionary[String, SelectableWeapon] = {}
var current_power: int = 0

var selected_weapon: SelectableWeapon = null

func _ready() -> void:
	pass # Replace with function body.


func initialize_selection(system: WeaponSystem):
	var count = 0
	for key in system.weapons.keys():
		var weapon: Weapon = system.weapons[key]
		var weapon_item: = weapon_item_ps.instantiate()
		var weaponname = weapon.name
		weapon_items[weaponname] = weapon_item
		weapon_item.weapon_name = weaponname
		weapon_item.weapon = weapon
		weapon_item.weapon_priority = count
		weapon_item.request_power_up.connect(system.requested_power_weapon)
		weapon_item.request_power_down.connect(system.requested_shutdown_weapon)
		weapon_item.weapon_selected.connect(_weapon_selected)
		weapon.weapon_status_changed.connect(weapon_item.weapon_status_changed)
		weapon.charge_progress_changed.connect(weapon_item.charge_progress_changed)

		count += 1
		weapons_list.add_child(weapon_item)
		


func on_power_changed(new_amount: int):
	current_power = new_amount
	set_power_label()

	# will have to check 
func set_power_label():
	power_amount.text = "Power: %s" % current_power

func _weapon_selected(item: SelectableWeapon):
	if selected_weapon != item:
		if selected_weapon != null:
			selected_weapon.unselect()
		selected_weapon = item
		selected_weapon.select()
		weapon_selected.emit(item.weapon)