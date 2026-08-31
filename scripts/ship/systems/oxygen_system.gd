extends PoweredSystem
class_name OxygenSystem

var oxygen_levels: float = 100
var oxygen_generate_speed: float = 2
var oxygen_loss_speed: float = 5

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if current_power == 0:
		if oxygen_levels > 0:
			oxygen_levels -= delta * oxygen_loss_speed
		else:
			oxygen_levels = 0
	elif current_power > 0:
		if oxygen_levels < 100:
			oxygen_levels += delta * oxygen_generate_speed
		else:
			oxygen_levels = 100