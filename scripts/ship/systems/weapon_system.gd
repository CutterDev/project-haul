extends PoweredSystem

class_name WeaponSystem

var weapons: Array[Weapon]

# total power among weapons needed
var max_power_needed: int = 0

func _ready() -> void:
	get_weapons()

func get_weapons():
	for weapon: Weapon in $"../../Weapons".get_children():
		max_power_needed += weapon.power_needed
		weapons.append(weapon)
