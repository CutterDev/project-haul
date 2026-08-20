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

