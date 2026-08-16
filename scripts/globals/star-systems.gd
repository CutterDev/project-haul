extends Node3D


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
