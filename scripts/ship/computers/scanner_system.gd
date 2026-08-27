extends ComputerHandler
# Computer System that handles the Scanner for ships
class_name ScannerSystem


signal room_targeted(target: Area3D)


@export var ship_target: Ship
@export var reset_rotation_speed: float = 10.0
@export var rotation_sensitivity: float = 0.005

@onready var camera: Camera3D = $Computer/SubViewport/ShipModel/Camera
@onready var ship_pos: Node3D = $Computer/SubViewport/ShipModel/ShipPosition
@onready var scanner_world: Node3D = $Computer/SubViewport/ShipModel
@onready var computer: ComputerScreen = $Computer

var packed_scannedroom: PackedScene = preload("res://scenes/ships/Models/scanned_room.tscn")
var ship_model: Node3D
var start_position: Vector3
var rooms: Array[Area3D] = []

var scroll_speed: float = 1.0
var display_distance: float = 10.0

var last_event_pos2d: Vector2 = Vector2.ZERO
var is_rotating: bool = false

func _ready() -> void:
	computer.screen_input_received.connect(_on_computer_screen_input)
	computer.interaction_clicked.connect(_interaction)
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

	ship_model.position = dir * display_distance
	start_position = dir
	ship_model.rotation = ship_target.rotation

	# Aim camera at the ship model
	camera.look_at(ship_model.global_position, Vector3.UP)

func _process(delta: float) -> void:
	ship_model.position = start_position * display_distance


func _on_computer_screen_input(event: InputEvent, event_pos_2d: Vector2) -> void:
	# 1. Scroll Wheel Zoom
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			display_distance -= scroll_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			display_distance += scroll_speed
		
		display_distance = clampf(display_distance, 5.0, 20.0)

	# 2. Left Click Press/Release
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_rotating = true
			last_event_pos2d = event_pos_2d
		else:
			is_rotating = false

# 3. Drag Mouse to Rotate Ship
	elif event is InputEventMouseMotion and is_rotating:
		var delta_2d: Vector2 = event_pos_2d - last_event_pos2d
		last_event_pos2d = event_pos_2d
		
		if ship_model and camera:
			# Get camera's Up and Right vectors relative to the ship model's local space
			var cam_basis: Basis = camera.global_transform.basis
			var ship_basis_inv: Basis = ship_model.global_transform.basis.inverse()

			# Local axes for rotation relative to screen orientation
			var local_up: Vector3 = ship_basis_inv * cam_basis.y
			var local_right: Vector3 = ship_basis_inv * cam_basis.x

			# Rotate around camera-aligned local axes
			ship_model.rotate(local_up, delta_2d.x * rotation_sensitivity)
			ship_model.rotate(local_right, -delta_2d.y * rotation_sensitivity)


func create_box_area(room_name: String, box_size: Vector3, area_position: Vector3) -> Area3D:
	var newroom = packed_scannedroom.instantiate()
	newroom.name = room_name
	newroom.room_position = area_position
	newroom.room_size = box_size
	
	ship_model.add_child(newroom)

	return newroom

func _on_area_body_entered(body: Node3D) -> void:
	print("Body entered area: ", body.name)

func _interaction(target: Area3D):
	# can do something here 
	print("Target: ", target)
	for room in ship_target.rooms:
		if room.name == target.name:
			room_targeted.emit(room)
