extends Node3D
@onready var node_viewport: SubViewport = $SubViewport
@onready var node_quad: MeshInstance3D = $Quad
@onready var node_area: Area3D = $Screen/Area3D

var target_camera: Camera3D

# Used for checking if the mouse is inside the Area3D.
var is_mouse_inside = false
# The last processed input touch/mouse event. To calculate relative movement.
var last_event_pos_2d = null
# The time of the last event in seconds since engine start.
var last_event_time: float = -1.0


func _ready():
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)
	target_camera = node_viewport.get_camera_3d()

var last_hovered_area: Area3D = null

func _mouse_entered_area():
	is_mouse_inside = true
	print("Mouse entered")

func _mouse_exited_area():
	is_mouse_inside = false
	print("Mouse exited")


func _unhandled_input(event: InputEvent):
	# Check if the event is a mouse or touch event
	if event is InputEventMouseButton or event is InputEventMouseMotion or event is InputEventScreenDrag or event is InputEventScreenTouch:
		# Handled via Physics Picking, skip passing standard mouse input to SubViewport here
		return
		
	node_viewport.push_input(event)

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	# Get mesh size to detect edges and make conversions. This code only support PlaneMesh and QuadMesh.
	var quad_mesh_size = node_quad.mesh.size

	# Event position in Area3D in world coordinate space.
	var event_pos_3d = event_position

	# Current time in seconds since engine start.
	var now: float = Time.get_ticks_msec() / 1000.0

	# Convert position to a coordinate space relative to the Area3D node.
	# NOTE: affine_inverse accounts for the Area3D node's scale, rotation, and position in the scene!
	event_pos_3d = node_quad.global_transform.affine_inverse() * event_pos_3d

	# TODO: Adapt to bilboard mode or avoid completely.

	var event_pos_2d: Vector2 = Vector2()

	if is_mouse_inside:
		# Convert the relative event position from 3D to 2D.
		event_pos_2d = Vector2(event_pos_3d.x, -event_pos_3d.y)

		# Right now the event position's range is the following: (-quad_size/2) -> (quad_size/2)
		# We need to convert it into the following range: -0.5 -> 0.5
		event_pos_2d.x = event_pos_2d.x / quad_mesh_size.x
		event_pos_2d.y = event_pos_2d.y / quad_mesh_size.y
		# Then we need to convert it into the following range: 0 -> 1
		event_pos_2d.x += 0.5
		event_pos_2d.y += 0.5

		# Finally, we convert the position to the following range: 0 -> viewport.size
		event_pos_2d.x *= node_viewport.size.x
		event_pos_2d.y *= node_viewport.size.y
		# We need to do these conversions so the event's position is in the viewport's coordinate system.

	elif last_event_pos_2d != null:
		# Fall back to the last known event position.
		event_pos_2d = last_event_pos_2d

	# Set the event's position and global position.
	event.position = event_pos_2d
	if event is InputEventMouse:
		event.global_position = event_pos_2d

	# Calculate the relative event distance.
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		# If there is not a stored previous position, then we'll assume there is no relative motion.
		if last_event_pos_2d == null:
			event.relative = Vector2(0, 0)
		# If there is a stored previous position, then we'll calculate the relative position by subtracting
		# the previous position from the new position. This will give us the distance the event traveled from prev_pos.
		else:
			event.relative = event_pos_2d - last_event_pos_2d
			event.velocity = event.relative / (now - last_event_time)

	# Update last_event_pos2D with the position we just calculated.
	last_event_pos_2d = event_pos_2d

	# Update last_event_time to current time.
	last_event_time = now

	# Finally, send the processed input event to the viewport.
	node_viewport.push_input(event, true)


func get_ray_from_screen_pos(pos_2d: Vector2) -> Dictionary:
	if not target_camera:
		return {}
	
	# Project ray origin and direction from target camera using 2D screen coordinates
	var ray_origin: Vector3 = target_camera.project_ray_origin(pos_2d)
	var ray_dir: Vector3 = target_camera.project_ray_normal(pos_2d)
	var ray_length: float = 1000.0 # Adjust reach as needed
	
	return {
		"from": ray_origin,
		"to": ray_origin + ray_dir * ray_length
	}