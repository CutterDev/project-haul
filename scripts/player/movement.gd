extends CharacterBody3D
class_name MovementController

var can_move: bool = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 5
var jump_speed = 5
var mouse_sensitivity = 0.002

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera3D.rotation.x = clampf(
			$Camera3D.rotation.x - event.relative.y * mouse_sensitivity,
			deg_to_rad(-70),
			deg_to_rad(70)
		)

func _physics_process(delta):
	if can_move:
		velocity.y += -gravity * delta
		var input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var movement_dir = transform.basis * Vector3(input.x, 0, input.y)
		velocity.x = movement_dir.x * speed
		velocity.z = movement_dir.z * speed

	move_and_slide()
	# if is_on_floor() and Input.is_action_just_pressed("jump"):
	#     velocity.y = jump_speed

func enable_movement(enable: bool) -> void:
	can_move = enable
	if not can_move:
		velocity = Vector3.ZERO