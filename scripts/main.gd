extends Node3D

@export var planet_scene: PackedScene # Assign Planet.tscn in Inspector
@export var ship_node: Node3D         # Drag your Ship node here in Inspector

# Global scale multiplier for all planets and distances
@export var world_scale: float = 100.0

# Base Speed of Light in Godot Units (1 unit = 1,000 km -> 300 units/s)
const BASE_SPEED_OF_LIGHT: float = 300.0

# Multiplier for warp/sub-light speed (e.g., 1.0 = 100% c, 0.5 = 0.5c)
@export_range(0.01, 10.0) var lightspeed_factor: float = 1.0

var target_planet_key: String = "umbra1"
var universe_node: Node3D

# Transit state tracking
var is_in_transit: bool = false
var transit_target_pos: Vector3 = Vector3.ZERO
var transit_direction: Vector3 = Vector3.ZERO

# Base unscaled planet properties (1 unit = 1,000 km)
var base_planets: Dictionary = {
    "umbra1": {
        "display_name": "Venus Equivalent",
        "pos": Vector3(-300.0, -42.8, 0.0),
        "radius": 6.05,
        "exosphere_alt": 0.5
    },
    "umbra2": {
        "display_name": "Earth Equivalent",
        "pos": Vector3(300.0, 31.5, 0.0),
        "radius": 6.37,
        "exosphere_alt": 0.5
    }
}

# Calculated at runtime based on world_scale
var planets: Dictionary = {}

func _ready() -> void:
    _setup_universe_container()
    _apply_world_scale()
    for planet_name in planets:
        var new_planet = planet_scene.instantiate()
        universe_node.add_child(new_planet)
        new_planet.setup_planet(planets[planet_name])

func _setup_universe_container() -> void:
    if has_node("Universe"):
        universe_node = get_node("Universe") as Node3D
    else:
        universe_node = Node3D.new()
        universe_node.name = "Universe"
        add_child(universe_node)

func _apply_world_scale() -> void:
    planets.clear()
    for key in base_planets:
        var base_data = base_planets[key]
        planets[key] = {
            "display_name": base_data["display_name"],
            "pos": base_data["pos"] * world_scale,
            "radius": base_data["radius"] * world_scale,
            "exosphere_alt": base_data["exosphere_alt"] * world_scale
        }

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        if ship_node:
            pass
            # start_transit(target_planet_key)

func start_transit(planet_key: String) -> void:
    var planet_data = planets[planet_key]
    transit_target_pos = get_exosphere_target(planet_key, ship_node.global_position)
    
    # Rotate ship toward target planet
    ship_node.look_at(planet_data["pos"], Vector3.UP)
    
    # Offset if ship mesh orientation requires it
    ship_node.rotate_object_local(Vector3.UP, deg_to_rad(90))
    
    # Calculate travel direction vector from ship to target
    var vector_to_target: Vector3 = transit_target_pos - ship_node.global_position
    transit_direction = vector_to_target.normalized()
    
    is_in_transit = true

func _physics_process(delta: float) -> void:
    if not is_in_transit:
        return
        
    var scaled_speed: float = BASE_SPEED_OF_LIGHT * world_scale * lightspeed_factor
    var step_distance: float = scaled_speed * delta
    var remaining_distance: float = ship_node.global_position.distance_to(transit_target_pos)
    
    if remaining_distance <= step_distance:
        # Final step to reach exact arrival destination
        _shift_universe(-transit_direction * remaining_distance)
        _on_transit_complete()
    else:
        # Move universe in opposite direction of travel
        _shift_universe(-transit_direction * step_distance)

func _shift_universe(offset: Vector3) -> void:
    # Shift world container
    universe_node.global_position += offset
    
    # Update stored target positions to stay aligned with shifted world space
    transit_target_pos += offset
    for key in planets:
        planets[key]["pos"] += offset

func _on_transit_complete() -> void:
    is_in_transit = false
    print("Arrived at target exosphere boundary!")
    target_planet_key = "umbra2" if target_planet_key == "umbra1" else "umbra1"

func get_exosphere_target(planet_name: String, from_position: Vector3) -> Vector3:
    var planet_data = planets[planet_name]
    var planet_pos: Vector3 = planet_data["pos"]
    var stop_distance: float = planet_data["radius"] + planet_data["exosphere_alt"]
    
    var direction = (from_position - planet_pos)
    if direction.length_squared() < 0.001:
        direction = Vector3.FORWARD
    else:
        direction = direction.normalized()
        
    return planet_pos + (direction * stop_distance)