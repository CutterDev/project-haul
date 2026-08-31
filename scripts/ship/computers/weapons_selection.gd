extends Control
class_name WeaponsSelection

@onready var weapons_list: VBoxContainer = $VBoxContainer/WeaponsList
var weapon_item_ps: PackedScene = preload("res://scenes/computers/weaponselection_item.tscn")
# Called when the node enters the scene tree for the first time.

var weapon_items: Array = []

func _ready() -> void:
	pass # Replace with function body.


func initialize_selection(weapons: Array[Weapon]):
	for weapon in weapons:
		var weapon_item = weapon_item_ps.instantiate()
		weapon_items.append(weapon_item)
		weapon_item.weapon_name = weapon.name
		weapons_list.add_child(weapon_item)