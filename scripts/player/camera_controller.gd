extends Camera3D

@export var ray_length: float = 100.0
@export_flags_3d_physics var filter

@onready var movement: MovementController = $".."

func _physics_process(delta: float) -> void:
	shoot_ray()

func shoot_ray() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to, filter)
	
	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider
		if collider.has_method("interact") and Input.is_action_pressed("interact"):
			collider.interact()
