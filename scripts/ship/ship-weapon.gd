extends Node3D
class_name Weapon

@export_file_path var ammo_path
@export var charge_rate: float = 10.0
@export var fire_rate_per_shot: float = 0.35
@export var power_needed: int = 1
@export var shots: int = 3

# Damage per shot
@export var damage: float = 0.0

var ammo_scene: PackedScene
var target: Area3D = null
var charge_timer: float = 0.0
var charge_speed: float = 1.0
var fire_rate_timer: float = 0.0
var shot_count:int  = 0

var is_powered: bool = false

enum WeaponType
{
	LASER,
	TORPEDO
}

func _ready() -> void:
	fire_rate_timer = fire_rate_per_shot
	if ammo_path != null:
		ammo_scene = load(ammo_path)
	
func _process(delta: float) -> void:
	# print("is_powered: ", is_powered)
	# print("Has Target: ", target != null)
	
	if is_powered and target != null:
		if charge_rate > charge_timer:
			print("Charging")
			charge_timer += delta
		else:
			if fire_rate_per_shot > fire_rate_timer:
				fire_rate_timer += delta * charge_speed
			elif shot_count < shots:
				shot_count += 1
				fire_rate_timer = 0.0
				# FIREEEEEE
				print("FIREEEEE")
				var laser_instance = ammo_scene.instantiate()
				laser_instance.position = global_position
				get_tree().root.add_child(laser_instance)
				laser_instance.set_target(target.global_position)
			if shot_count == shots:
				charge_timer = 0.0
				shot_count = 0
				# Make sure the first shot always goes off the second the charge is ready
				fire_rate_timer = fire_rate_per_shot
	else:
		# bring charge down slowly like the power is leaking out.
		if charge_timer > 0:
			charge_timer -= delta
		else: 
			charge_timer = 0


func get_charge_progress() -> float:
	return (charge_timer / charge_rate) * 100.0


func powered_up() -> void:
	is_powered = true


func powered_down() -> void:
	is_powered = true