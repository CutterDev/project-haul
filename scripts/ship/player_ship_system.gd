extends ShipSystem



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# Check main keyboard number row (0-9)
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			var number_pressed: int = event.keycode - KEY_0
			_on_number_pressed(number_pressed)
			get_viewport().set_input_as_handled()

func _on_number_pressed(num: int):
	if num < weapons.size():
		selected_weapon = weapons[0]
		