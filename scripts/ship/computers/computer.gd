extends Node3D
class_name ComputerScreen

# Add this at the top of ComputerScreen.gd
signal screen_input_received(event: InputEvent, pos_2d: Vector2)

@onready var node_viewport: SubViewport = $SubViewport
@onready var node_quad: MeshInstance3D = $Quad
@onready var node_area: Area3D = $Screen/Area3D

var target_camera: Camera3D

var is_mouse_inside = false
var last_event_pos_2d = null
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


func _unhandled_input(event: InputEvent):
	node_viewport.push_input(event)

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int):
	if not is_mouse_inside:
		return

	var quad_size: Vector2 = node_quad.mesh.size

# 1. Get raw hit position relative to the Quad's center local space
	var local_pos: Vector3 = node_quad.global_transform.affine_inverse() * event_position
	
	# Account for global mesh scaling on the quad instance
	var quad_scale: Vector3 = node_quad.global_transform.basis.get_scale()
	var effective_size := Vector2(
		quad_size.x * quad_scale.x,
		quad_size.y * quad_scale.y
	)

	# 2. Calculate pure normalized UV coordinates (0.0 to 1.0)
	var uv_x: float = clamp((local_pos.x / quad_size.x) + 0.5, 0.0, 1.0)
	
	# FIX: Divide local_pos.y by 2.0 to eliminate the 2x height offset
	var uv_y: float = clamp(0.5 - (local_pos.y / (quad_size.y * 1.5)), 0.0, 1.0)

	# 3. Map directly to integer SubViewport pixel space
	var event_pos_2d := Vector2(
		uv_x * float(node_viewport.size.x),
		uv_y * float(node_viewport.size.y)
	)

	# Emit signal so ComputerHandler receives both event AND mapped 2D position
	screen_input_received.emit(event, event_pos_2d)
	if not target_camera:
		target_camera = node_viewport.get_camera_3d()

	if target_camera:
		# CRITICAL FIX: Lock camera aspect mode to prevent Y-scaling stretch distortion
		target_camera.keep_aspect = Camera3D.KEEP_WIDTH

		# Project frustum rays precisely from camera near and far planes
		var ray_origin: Vector3 = target_camera.project_position(event_pos_2d, target_camera.near)
		var ray_far: Vector3 = target_camera.project_position(event_pos_2d, target_camera.far)
		var ray_dir: Vector3 = (ray_far - ray_origin).normalized()

		var space_state = target_camera.get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_origin + ray_dir * 1000.0)
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var hit = space_state.intersect_ray(query)

	
		if not hit.is_empty():
			var collider = hit.collider
			print("Collider has method: ", collider.has_method("on_mouse_entered"))
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
