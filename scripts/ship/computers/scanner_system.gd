extends ComputerHandler
# Computer System that handles the Scanner for ships


@export var ship_target: ShipSystem
@export var reset_rotation_speed: float = 10.0
@onready var camera: Camera3D = $Computer/SubViewport/ShipModel/Camera
@onready var ship_pos: Node3D = $Computer/SubViewport/ShipModel/ShipPosition
@onready var scanner_world: Node3D = $Computer/SubViewport/ShipModel

var packed_scannedroom: PackedScene = preload("res://scenes/ships/Models/scanned_room.tscn")#
var ship_model: Node3D
var rooms: Array[Area3D] = []

var target_basis: Basis
var resetting_ship: bool

func _ready() -> void:
	var model_scene = load(ship_target.model_path)
	ship_model = model_scene.instantiate()
	ship_model.rotation =  ship_target.rotation
	ship_model.ready.connect(ship_ready)
	scanner_world.add_child(ship_model)

func ship_ready() -> void:
	for room in ship_target.rooms:
		print("Room Size: ", room.coll.shape.size)
		rooms.append(create_box_area(room.name, room.coll.shape.size, room.position))

	# Direction vector from your ship (self) to ship_target
	var dir: Vector3 = (ship_target.global_position - self.global_position).normalized()
	
	# Set model local position in front of camera along 'dir'
	var display_distance: float = 10.0
	ship_model.position = dir * display_distance
	ship_model.rotation = ship_target.rotation

	# Aim camera at the ship model
	camera.look_at(ship_model.global_position, Vector3.UP)

func create_box_area(room_name: String, box_size: Vector3, area_position: Vector3) -> Area3D:
	var newroom = packed_scannedroom.instantiate()
	newroom.name = room_name
	newroom.room_position = area_position
	newroom.room_size = box_size
	
	ship_model.add_child(newroom)

	return newroom

func _on_area_body_entered(body: Node3D) -> void:
	print("Body entered area: ", body.name)

func draw_arrow(
	from: Vector3, 
	to: Vector3, 
	color: Color = Color.GREEN, 
	head_size: float = 0.5, 
	duration: float = 2.0
) -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()

	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	var direction := (to - from).normalized()
	if direction == Vector3.ZERO:
		return

	# Calculate basis for head lines
	var up := Vector3.UP if abs(direction.dot(Vector3.UP)) < 0.99 else Vector3.RIGHT
	var right := direction.cross(up).normalized()
	up = right.cross(direction).normalized()

	var head_base := to - (direction * head_size)

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	
	# Shaft
	immediate_mesh.surface_add_vertex(from)
	immediate_mesh.surface_add_vertex(to)
	
	# Arrow Head (4-point cone base)
	var arrow_points: Array[Vector3] = [
		head_base + (right * head_size * 0.5),
		head_base - (right * head_size * 0.5),
		head_base + (up * head_size * 0.5),
		head_base - (up * head_size * 0.5)
	]

	for pt in arrow_points:
		# Connect head points to tip
		immediate_mesh.surface_add_vertex(to)
		immediate_mesh.surface_add_vertex(pt)

	# Connect base of head to form a cross ring
	immediate_mesh.surface_add_vertex(arrow_points[0])
	immediate_mesh.surface_add_vertex(arrow_points[2])
	immediate_mesh.surface_add_vertex(arrow_points[2])
	immediate_mesh.surface_add_vertex(arrow_points[1])
	immediate_mesh.surface_add_vertex(arrow_points[1])
	immediate_mesh.surface_add_vertex(arrow_points[3])
	immediate_mesh.surface_add_vertex(arrow_points[3])
	immediate_mesh.surface_add_vertex(arrow_points[0])

	immediate_mesh.surface_end()

	# Add to tree
	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.root:
		tree.root.add_child.call_deferred(mesh_instance)
