extends PoweredSystem
class_name ShieldSystem

# Current sheild of ship.
var current_shield: float = 0
# how much shield the current shield can charge to.
var max_shield: float = 0
## Base shield when the base power is met.
var base_shield: float = 1000
## Amount of power needed to charge shield
var base_power_needed: int = 2

# This is per EXTRA bar ontop of 2 more.
var shield_per_extra_bar: float = 250

var charge_speed: float = 50
# drain speed if power is lost
var drain_speed: float = 50

# the delay for the shield to kick in charging again
var charge_delay_timer: float = 0.0
var charge_delay: float = 5.0

func _ready():
	pass

func _process(delta: float) -> void:
	if (charge_delay_timer < charge_delay):
		charge_delay_timer += delta
	else:
		# drain power
		if current_power < base_power_needed:
			if current_shield > 0:
				current_shield -= drain_speed * delta
			else:
				current_shield = 0
		else:

			if current_shield < max_shield:
				current_shield += charge_speed * delta
			else:
				current_shield = max_shield
		
func get_shield_percentage():
	return (current_shield / max_shield) * 100.00

func increment_power():
	current_power += 1
	power_check()
func decrement_power():
	current_power -= 1
	power_check()

func power_check():
	if (current_power >= base_power_needed):
		var extra_shield = current_power - base_power_needed
		max_shield = base_shield + (shield_per_extra_bar * extra_shield)
	else:
		max_shield = 0
	