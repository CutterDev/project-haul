extends Camera3D

@export var ray_length: float = 100.0
@export_flags_3d_physics var filter

@onready var movement: MovementController = $".."

var interacting: bool = false
var debug_mesh_instance: MeshInstance3D
var debug_immediate_mesh: ImmediateMesh
var debug_material: StandardMaterial3D
var can_swap_timer = 0.0
var swap_rate = 0.1

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

func _physics_process(_delta: float) -> void:
	if not interacting and can_swap_timer < swap_rate:
		can_swap_timer += _delta
	shoot_ray()
	
func shoot_ray() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length

	# Draw Debug Line
	draw_debug_line(from, to)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	# Turn line green if hit
	if result:
		debug_material.albedo_color = Color.GREEN
		var collider = result.collider

		if not interacting and collider.has_method("interact") and Input.is_action_just_pressed("interact") and can_swap_timer >= swap_rate:
			print("interacting")
			collider.interact(self)
			interacting = true
			movement.enable_movement(false)
	else:
		debug_material.albedo_color = Color.RED


func draw_debug_line(from: Vector3, to: Vector3) -> void:
	debug_immediate_mesh.clear_surfaces()
	debug_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	debug_immediate_mesh.surface_add_vertex(from)
	debug_immediate_mesh.surface_add_vertex(to)
	debug_immediate_mesh.surface_end()

func _exit_tree() -> void:
	if is_instance_valid(debug_mesh_instance):
		debug_mesh_instance.queue_free()

func set_current_cam():
	print("no longer interacting")
	interacting = false
	make_current()
	movement.enable_movement(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	can_swap_timer = 0
