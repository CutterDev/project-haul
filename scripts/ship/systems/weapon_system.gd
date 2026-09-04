extends PoweredSystem

class_name WeaponSystem

var weapons: Dictionary[String, Weapon]

# total power among weapons needed
var max_power_needed: int = 0
var power_in_use: int = 0
func _ready() -> void:
	get_weapons()

func get_weapons():
	for weapon: Weapon in $"../../Weapons".get_children():
		max_power_needed += weapon.power_needed
		weapons[weapon.name] = weapon


func requested_power_weapon(weapon_name: String):
	print("Request power weapon: ", weapon_name)
	if weapons.has(weapon_name):
		var available_power = current_power - power_in_use
		var weapon = weapons[weapon_name]
		var power_needed = weapon.power_needed
		if available_power >= power_needed:
			power_in_use += power_needed
			weapon.power_up()


func requested_shutdown_weapon(weapon_name: String):
	if weapons.has(weapon_name):
		var weapon = weapons[weapon_name]
		if not weapon.is_powered:
			return
		var power_needed = weapon.power_needed
		power_in_use -= weapon.power_needed
		weapon.power_down()