extends Node3D

# Used for checking if the mouse is inside the Area3D.
var is_mouse_inside = false
# The last processed input touch/mouse event. To calculate relative movement.
var last_event_pos_2d = null
# The time of the last event in seconds since engine start.
var last_event_time: float = -1.0

@onready var node_viewport: SubViewport = $SubViewport
@onready var node_quad: MeshInstance3D = $Quad
@onready var node_area: Area3D = $Screen/Area3D

func _ready():
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)


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
	# Get mesh size to detect edges and make conversions. (QuadMesh / PlaneMesh)
	var quad_mesh_size = node_quad.mesh.size

	# Event position in Area3D in world coordinate space.
	var event_pos_3d = event_position

	# Current time in seconds since engine start.
	var now: float = Time.get_ticks_msec() / 1000.0

	# Convert position to a coordinate space relative to the Quad node.
	event_pos_3d = node_quad.global_transform.affine_inverse() * event_pos_3d

	var event_pos_2d: Vector2 = Vector2.ZERO

	if is_mouse_inside:
		# Convert relative event position from 3D to 2D.
		event_pos_2d = Vector2(event_pos_3d.x, -event_pos_3d.y)

		# Convert range from (-quad_size/2 -> quad_size/2) to (-0.5 -> 0.5)
		event_pos_2d.x = event_pos_2d.x / quad_mesh_size.x
		event_pos_2d.y = event_pos_2d.y / quad_mesh_size.y
		
		# Convert range from (-0.5 -> 0.5) to (0.0 -> 1.0)
		event_pos_2d += Vector2(0.5, 0.5)

		# Convert range from (0.0 -> 1.0) to SubViewport pixel size
		event_pos_2d.x *= node_viewport.size.x
		event_pos_2d.y *= node_viewport.size.y

	elif last_event_pos_2d != null:
		# Fall back to the last known event position.
		event_pos_2d = last_event_pos_2d

	# Duplicate the event to avoid modifying global input state directly
	var cloned_event = event.duplicate()

	# Set the event's position and global position.
	if cloned_event is InputEventMouse or cloned_event is InputEventGesture:
		cloned_event.position = event_pos_2d
		cloned_event.global_position = event_pos_2d

	# Calculate relative movement
	if cloned_event is InputEventMouseMotion or cloned_event is InputEventScreenDrag:
		if last_event_pos_2d == null:
			cloned_event.relative = Vector2.ZERO
		else:
			cloned_event.relative = event_pos_2d - last_event_pos_2d
			var delta_time = now - last_event_time
			if delta_time > 0:
				cloned_event.velocity = cloned_event.relative / delta_time

	last_event_pos_2d = event_pos_2d
	last_event_time = now

	# Send processed input event to the viewport.
	node_viewport.push_input(cloned_event)