extends Area3D

@onready var collshape: CollisionShape3D = $CollisionShape3D
@onready var mesh: MeshInstance3D = $MeshInstance3D

var room_position: Vector3 = Vector3.ZERO
var room_size: Vector3 = Vector3.ONE

func _ready() -> void:
	position = room_position
	print("Room Size", room_size)
	
	# Duplicate shape/mesh resources so sizing doesn't affect other instances
	collshape.shape = collshape.shape.duplicate()
	mesh.mesh = mesh.mesh.duplicate()
	collshape.shape.size = room_size
	mesh.mesh.size = room_size

	# Make material unique to this mesh instance
	var base_mat = mesh.get_active_material(0)
	if base_mat:
		mesh.set_surface_override_material(0, base_mat.duplicate())


func on_mouse_exited() -> void:
	set_model_color(Color.from_rgba8(0, 224, 200, 104))

func on_mouse_entered() -> void:
	set_model_color(Color.from_rgba8(0, 224, 200, 200))


func set_model_color(new_color: Color) -> void:
	# Retrieve surface override material unique to this MeshInstance3D
	var mat = mesh.get_surface_override_material(0) as ShaderMaterial
	if mat:
		mat.set_shader_parameter("albedo_color", new_color)
