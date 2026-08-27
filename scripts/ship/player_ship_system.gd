extends Ship

@onready var weapon_system: ScannerSystem = $ShipScanner

@onready var hud = $"../CanvasLayer/HUD"

func _ready() -> void:
	super._ready()
	weapon_system.room_targeted.connect(room_targeted)
	for child in $Weapons.get_children():
		if child is Weapon:
			weapons.append(child)


func _process(delta: float) -> void:
	if selected_weapon != null:
		hud.set_charge(selected_weapon.get_charge_progress())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# Check main keyboard number row (0-9)
		if event.keycode >= KEY_0 and event.keycode <= KEY_9:
			var number_pressed: int = event.keycode - KEY_0
			_on_number_pressed(number_pressed)
			get_viewport().set_input_as_handled()

func _on_number_pressed(num: int):
	var selected_num = num - 1
	if selected_num < weapons.size():
		selected_weapon = weapons[num - 1]
		hud.set_weapon_name(selected_weapon.name)
		print("Selected Weapon: ", selected_weapon)

func room_targeted(target: Area3D) -> void:
	print(selected_weapon)
	if selected_weapon != null:
		selected_weapon.target = target
