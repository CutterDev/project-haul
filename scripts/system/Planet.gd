extends Node3D

@onready var planet_mesh: MeshInstance3D = $PlanetMesh
@onready var exosphere_mesh: MeshInstance3D = $ExoSphere

# Function to initialize planet size and location from your dictionary
func setup_planet(data: Dictionary) -> void:
	# 1. Set global position
	global_position = data["pos"]
	
	# 2. Scale planet body (Diameter = Radius * 2)
	var body_diameter = data["radius"] * 2.0
	planet_mesh.scale = Vector3.ONE * body_diameter
	
	# 3. Scale exosphere shell (Radius + Exosphere Altitude) * 2
	var exosphere_radius = data["radius"] + data["exosphere_alt"]
	var exosphere_diameter = exosphere_radius * 2.0
	exosphere_mesh.scale = Vector3.ONE * exosphere_diameter
	
