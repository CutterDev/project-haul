extends Camera3D

@export var target_pivot: Vector3 = Vector3.ZERO

@export var min_distance: float = 1.0
@export var max_distance: float = 20.0
@export var zoom_speed: float = 0.5


var is_dragging: bool = false
var yaw: float = 0.0
var pitch: float = 0.0
var distance: float = 10.0

func _ready() -> void:
	pass