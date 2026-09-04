extends Node3D
class_name Weapon
signal weapon_status_changed(status: WeaponStatus)
signal charge_progress_changed(progress: float)

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
var weapon_status: WeaponStatus
var is_powered: bool = false

enum WeaponType
{
	LASER,
	TORPEDO
}

# Configurable refresh rate (e.g., 0.05 = 20 updates per second max)
var emit_interval: float = 0.05 
var emit_timer: float = 0.0
var last_emitted_progress: float = -1.0

func _ready() -> void:
	fire_rate_timer = fire_rate_per_shot
	if ammo_path != null:
		ammo_scene = load(ammo_path)
	
func _process(delta: float) -> void:
	if is_powered:
		if weapon_status != WeaponStatus.FIRING:
			if charge_rate > charge_timer:
				charge_timer += delta
			elif weapon_status != WeaponStatus.READY:
				charge_timer = charge_rate + 1
				_change_weapon_status(WeaponStatus.READY)

		if target != null and (weapon_status == WeaponStatus.READY || weapon_status == WeaponStatus.FIRING):
			_change_weapon_status(WeaponStatus.FIRING)
			charge_timer = 0.0
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
				_change_weapon_status(WeaponStatus.CHARGING)
				shot_count = 0
				# Make sure the first shot always goes off the second the charge is ready
				fire_rate_timer = fire_rate_per_shot
	else:
		# bring charge down slowly like the power is leaking out.
		if charge_timer > 0:
			charge_timer -= delta
		else: 
			charge_timer = 0.0

	# Handle throttled signal emission
	_check_and_emit_charge_progress(delta)


func get_charge_progress() -> float:
	if charge_rate == 0.0:
		return 0.0
	return clampf((charge_timer / charge_rate) * 100.0, 0.0, 100.0)


func _check_and_emit_charge_progress(delta: float) -> void:
	emit_timer += delta
	if emit_timer >= emit_interval:
		emit_timer = 0.0
		
		# Round to 1 decimal place (or integer) to avoid floating-point jitter
		var current_progress: float = snappedf(get_charge_progress(), 0.1)
		
		# Only emit if the percentage actually changed
		if not is_equal_approx(current_progress, last_emitted_progress):
			last_emitted_progress = current_progress
			charge_progress_changed.emit(current_progress)


func power_up() -> void:
	is_powered = true
	_change_weapon_status(WeaponStatus.CHARGING)
	

func power_down() -> void:
	is_powered = false
	if weapon_status == WeaponStatus.FIRING:
		charge_timer = 0.0
		shot_count = 0
		fire_rate_timer = fire_rate_per_shot
	_change_weapon_status(WeaponStatus.OFFLINE)


func _change_weapon_status(status: WeaponStatus):
	weapon_status = status
	weapon_status_changed.emit(status)
enum WeaponStatus
{
	OFFLINE,
	CHARGING,
	READY,
	FIRING
}