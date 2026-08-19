extends Camera3D

@export var ray_length: float = 100.0
@export_flags_3d_physics var filter: int

@onready var movement: MovementController = $".."

@export var toggle_cooldown: float = 0.5 # Delay in seconds
var cooldown_timer: float = 0.0
var try_interacting: bool = false
var interacting: bool = false
var debug_mesh_instance: MeshInstance3D
var debug_immediate_mesh: ImmediateMesh
var debug_material: StandardMaterial3D
var can_swap_timer: float = 0.0
var swap_rate: float = 0.1

var current_interaction: Object = null

func _ready() -> void:
	# Set up debug drawing nodes
	debug_mesh_instance = MeshInstance3D.new()
	debug_immediate_mesh = ImmediateMesh.new()
	debug_material = StandardMaterial3D.new()
	
	debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	debug_material.albedo_color = Color.RED
	debug_mesh_instance.material_override = debug_material
	debug_mesh_instance.mesh = debug_immediate_mesh
	
	get_tree().root.call_deferred("add_child", debug_mesh_instance)

func _unhandled_input(event: InputEvent) -> void:
	# Only register initial press, ignore key echo repeats
	if event.is_action_pressed("interact", false):
		try_interacting = true

func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

func _physics_process(_delta: float) -> void:
	shoot_ray()
	# Consume the input request at the end of the physics frame
	try_interacting = false

func shoot_ray() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length

	# Draw Debug Line
	draw_debug_line(from, to)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	if filter:
		query.collision_mask = filter
		
	var result = space_state.intersect_ray(query)
	
	# If currently interacting, handle toggling off/stopping interaction
	if interacting:
		if _can_interact():
			if is_instance_valid(current_interaction) and current_interaction.has_method("stop_interact"):
				cooldown_timer = toggle_cooldown
				current_interaction.stop_interact()
				movement.enable_movement(true)
				interacting = false
		return

	# Handle raycast targeting
	if result:
		debug_material.albedo_color = Color.GREEN
		current_interaction = result.collider
		
		if is_instance_valid(current_interaction) and current_interaction.has_method("interact") and _can_interact():
			cooldown_timer = toggle_cooldown
			current_interaction.interact(self)
			interacting = true
	else:
		debug_material.albedo_color = Color.RED
		current_interaction = null

func _can_interact() -> bool:
	return cooldown_timer <= 0.0 and try_interacting

func draw_debug_line(from: Vector3, to: Vector3) -> void:
	debug_immediate_mesh.clear_surfaces()
	debug_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	debug_immediate_mesh.surface_add_vertex(from)
	debug_immediate_mesh.surface_add_vertex(to)
	debug_immediate_mesh.surface_end()

func _exit_tree() -> void:
	if is_instance_valid(debug_mesh_instance):
		debug_mesh_instance.queue_free()

func set_current_cam() -> void:
	print("no longer interacting")
	interacting = false
	make_current()
	movement.enable_movement(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	can_swap_timer = 0.0