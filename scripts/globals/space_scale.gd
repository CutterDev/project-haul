# SpaceScale.gd (Autoload as "SpaceScale")
extends Node

## Global scale multiplier for planetary bodies and distances
var world_scale: float = 100.0

## Base conversion: 1 raw base unit = 1,000 km
const KM_PER_BASE_UNIT: float = 1000.0

## Base Speed of Light in raw units/sec
const BASE_SPEED_OF_LIGHT: float = 300.0

## Helper methods so other scripts don't have to duplicate conversion math
func get_km_per_godot_unit() -> float:
	return KM_PER_BASE_UNIT / world_scale

func godot_units_to_km(units: float) -> float:
	return units * get_km_per_godot_unit()

func get_scaled_lightspeed(factor: float = 1.0) -> float:
	return BASE_SPEED_OF_LIGHT * world_scale * factor