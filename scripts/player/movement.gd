extends CharacterBody3D
class_name MovementController

var can_move: bool = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 5
var jump_speed = 5
var mouse_sensitivity = 0.002

@onready var camera_3d: Camera3D = $Camera3D
@onready var particles: GPUParticles3D = $Camera3D/SpeedParticles
var particle_material: ParticleProcessMaterial


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	can_move = true
	particle_material = particles.process_material as ParticleProcessMaterial

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_3d.rotation.x = clampf(
			camera_3d.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-70),
			deg_to_rad(70)
		)

func _physics_process(delta):
	var current_speed: float = velocity.length()

	particle_material.initial_velocity_min = current_speed * 1.5
	particle_material.initial_velocity_max = current_speed * 2.0
	particles.emitting = current_speed > 5.0

	if can_move:
		velocity.y += -gravity * delta
		var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
		# In Godot, -transform.basis.z is player forward, transform.basis.x is player right.
		# Since rotate_y() rotates the player node, transform.basis ALREADY tracks looking direction.
		var forward = -transform.basis.z
		var right = transform.basis.x
		
		# Flatten Y axis so looking up/down doesn't affect speed
		forward.y = 0.0
		right.y = 0.0
		forward = forward.normalized()
		right = right.normalized()

		# Combine input with local facing direction
		# Note: Godot's Input.get_vector returns positive Y for down/backward, negative Y for up/forward
		var movement_dir = (right * input.x + forward * (-input.y))

		velocity.x = movement_dir.x * speed
		velocity.z = movement_dir.z * speed

	move_and_slide()

func enable_movement(enable: bool) -> void:
	can_move = enable
	if not can_move:
		velocity = Vector3.ZERO
