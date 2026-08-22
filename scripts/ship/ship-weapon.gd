extends Node3D

class_name Weapon

@export var charge_time: float = 0.0
@export var fire_rate_per_shot: float = 0.0
@export var power_needed: int = 1
@export var shots: int = 1
 
# Damage per shot
@export var damage: float = 0.0

var is_powered: bool = false
var has_target: bool = false
var charge_timer: float = 0.0
var fire_rate_timer: float = 0.0
var shot_count:int  = 0
enum WeaponType
{
	LASER,
	TORPEDO
}

func _ready() -> void:
	fire_rate_timer = fire_rate_per_shot

func _process(delta: float) -> void:
	if is_powered and has_target:
		if charge_time > charge_timer:
			charge_timer += delta
		else:
			if fire_rate_per_shot > fire_rate_timer:
				fire_rate_timer += delta
			elif shot_count < shots:
				shot_count += 1
				fire_rate_timer = 0.0
				# FIREEEEEE
			
			if shot_count == shots:
				charge_timer = 0.0
				shot_count = 0
				# Make sure the first shot always goes off the second the charge is ready
				fire_rate_timer = fire_rate_per_shot
	