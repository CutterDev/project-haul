extends Area3D
class_name ComputerHandler
@onready var computer_cam: Camera3D = $ComputerCamera
@onready var coll: CollisionShape3D = $CollisionShape3D

var player_cam: Camera3D = null

var interacting = false

var can_swap_timer = 0.0
var swap_rate = 0.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if interacting:
		if can_swap_timer < swap_rate:
			can_swap_timer += delta
		if Input.is_action_just_pressed("interact") and can_swap_timer >= swap_rate:
			print("swap")

func interact(cam: Camera3D):
	print("Interacting")
	coll.disabled = true
	computer_cam.current = true
	interacting = true
	if player_cam == null:
		player_cam = cam
	player_cam.current = false
	set_process.call_deferred(true)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func stop_interact():
	can_swap_timer = 0.0
	interacting = false
	player_cam.set_current_cam()
	coll.disabled = false
