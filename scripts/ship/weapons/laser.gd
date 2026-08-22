extends Node3D

@export var speed: float = 200.0
@export var max_distance: float = 100.0

@onready var ray_cast: RayCast3D = $RayCast3D

var target_position: Vector3
var distance_traveled: float = 0.0

func _ready() -> void:
	# Ensure raycast points forward along the direction of travel (-Z in 3D)
	ray_cast.target_position = Vector3(0, 0, -10.0)
	ray_cast.enabled = true

func set_target(target_pos: Vector3) -> void:
	target_position = target_pos
	look_at(target_position, Vector3.UP)

func _process(delta: float) -> void:
	# Check for hits before moving to prevent tunneling through objects
	if ray_cast.is_colliding():
		_on_hit(ray_cast.get_collider(), ray_cast.get_collision_point())
		return

	# Move forward along local -Z axis
	var move_step: float = speed * delta
	translate(Vector3(0, 0, -move_step))
	
	# Track distance and despawn if it misses everything
	# distance_traveled += move_step
	# if distance_traveled >= max_distance:
	# 	queue_free()

func _on_hit(collider: Object, hit_position: Vector3) -> void:
	print("Hit: ", collider.name, " at ", hit_position)
	
	# Deal damage if the collider has a damage method
	if collider.has_method("take_damage"):
		collider.take_damage(10)
		
	queue_free()