extends Node3D
class_name ComputerScreen

# Add this at the top of ComputerScreen.gd
signal screen_input_received(event: InputEvent, pos_2d: Vector2)
signal interaction_clicked(target: Area3D)

@onready var node_viewport: SubViewport = $SubViewport
@onready var node_quad: MeshInstance3D = $Quad
@onready var node_area: Area3D = $Screen/Area3D

var target_camera: Camera3D

var is_mouse_inside = false
var last_event_pos_2d: Vector2 = Vector2.INF
var last_event_time: float = -1.0

# Debug indicator node
var debug_cube: MeshInstance3D

# Current target of the mouse when mouse hovers room
var mouse_target: Area3D = null
func _ready():
	node_area.mouse_entered.connect(_mouse_entered_area)
	node_area.mouse_exited.connect(_mouse_exited_area)
	node_area.input_event.connect(_mouse_input_event)
	
	target_camera = node_viewport.get_camera_3d()
	_setup_debug_cube()
	_sync_aspect_ratios()
func _sync_aspect_ratios() -> void:
	var quad_size: Vector2 = node_quad.mesh.size
	var quad_aspect: float = quad_size.x / quad_size.y

	# Option 1: Adjust SubViewport resolution height to match the Quad's aspect ratio
	node_viewport.size.y = int(node_viewport.size.x / quad_aspect)

	# Option 2: Ensure the SubViewport Camera's keep_aspect setting matches
	if target_camera:
		target_camera.keep_aspect = Camera3D.KEEP_WIDTH

func _setup_debug_cube():
	debug_cube = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.1, 0.1, 0.1) # Small cube size
	
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.RED
	
	debug_cube.mesh = box_mesh
	debug_cube.material_override = mat
	
	# FIX: Attach to the target camera's parent (the actual 3D scene root inside the SubViewport)
	if target_camera:
		target_camera.get_parent().add_child(debug_cube)
	else:
		# Fallback if camera hasn't been retrieved yet
		call_deferred("_attach_debug_cube")

func _attach_debug_cube():
	target_camera = node_viewport.get_camera_3d()
	if target_camera and debug_cube and not debug_cube.get_parent():
		target_camera.get_parent().add_child(debug_cube)

func _mouse_entered_area():
	is_mouse_inside = true
	if debug_cube:
		debug_cube.visible = true


func _mouse_exited_area():
	is_mouse_inside = false
	if debug_cube:
		debug_cube.visible = false


func _unhandled_input(event):
	# Check if the event is a non-mouse/non-touch event
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(event, mouse_event):
			# If the event is a mouse/touch event, then we can ignore it here, because it will be
			# handled via Physics Picking.
			return
	node_viewport.push_input(event)
	
func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if not is_mouse_inside and (last_event_pos_2d == null or last_event_pos_2d == Vector2.INF):
		return

	var now: float = Time.get_ticks_msec() / 1000.0
	var quad_size: Vector2 = node_quad.mesh.size
	var local_pos: Vector3 = node_quad.global_transform.affine_inverse() * event_position

	var event_pos_2d: Vector2
	var raycast_pos_2d: Vector2

	if is_mouse_inside:
		# Standard 1:1 UV Mapping for 2D SubViewport UI interaction
		var uv_x: float = clamp((local_pos.x / quad_size.x) + 0.5, 0.0, 1.0)
		var uv_y: float = clamp(0.5 - (local_pos.y / quad_size.y), 0.0, 1.0)

		event_pos_2d = Vector2(
			uv_x * float(node_viewport.size.x),
			uv_y * float(node_viewport.size.y)
		)

		# Custom aspect ratio mapping specifically for the inner 3D Raycast camera
		var ray_uv_y: float = clamp(0.5 - (local_pos.y / (quad_size.y * 1.5)), 0.0, 1.0)
		raycast_pos_2d = Vector2(
			uv_x * float(node_viewport.size.x),
			ray_uv_y * float(node_viewport.size.y)
		)
	elif last_event_pos_2d != null and last_event_pos_2d != Vector2.INF:
		event_pos_2d = last_event_pos_2d
		raycast_pos_2d = last_event_pos_2d

	# Duplicate the event so modifications don't leak to global inputs
	var viewport_event: InputEvent = event.duplicate()

	# Mutate input event coordinates for Control components inside SubViewport
	if viewport_event is InputEventMouse:
		viewport_event.position = event_pos_2d
		viewport_event.global_position = event_pos_2d

		if viewport_event is InputEventMouseMotion:
			if last_event_pos_2d == null or last_event_pos_2d == Vector2.INF:
				viewport_event.relative = Vector2.ZERO
				viewport_event.velocity = Vector2.ZERO
			else:
				viewport_event.relative = event_pos_2d - last_event_pos_2d
				var delta_time: float = now - last_event_time
				viewport_event.velocity = viewport_event.relative / delta_time if delta_time > 0.0 else Vector2.ZERO

	# Store current frame state
	last_event_pos_2d = event_pos_2d
	last_event_time = now

	# Dispatch accurate 2D input coordinates to UI controls inside SubViewport
	node_viewport.push_input(viewport_event)

	# SubViewport 3D raycasting using the custom aspect-adjusted raycast position
	if not target_camera:
		target_camera = node_viewport.get_camera_3d()

	if target_camera:
		target_camera.keep_aspect = Camera3D.KEEP_WIDTH

		var ray_origin: Vector3 = target_camera.project_position(raycast_pos_2d, target_camera.near)
		var ray_far: Vector3 = target_camera.project_position(raycast_pos_2d, target_camera.far)
		var ray_dir: Vector3 = (ray_far - ray_origin).normalized()

		var space_state = target_camera.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000.0)
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var hit = space_state.intersect_ray(query)

		if not hit.is_empty():
			var collider = hit.collider
			if collider.has_method("on_mouse_entered"):
				if collider != mouse_target:
					if mouse_target != null:
						mouse_target.on_mouse_exited()
					collider.on_mouse_entered()
					mouse_target = collider
			else:
				if mouse_target != null:
					mouse_target.on_mouse_exited()
				mouse_target = null

			if debug_cube:
				debug_cube.global_position = hit["position"]
		else:
			if mouse_target != null:
				mouse_target.on_mouse_exited()
			mouse_target = null

			if debug_cube:
				debug_cube.global_position = ray_origin + ray_dir * 5.0

	# Signal emission dispatch
	if mouse_target != null and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
		interaction_clicked.emit(mouse_target)
	else:
		screen_input_received.emit(event, event_pos_2d)