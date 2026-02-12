# misery/Scripts/States/selection_state.gd
extends BattleState

func enter(_msg: Dictionary = {}) -> void:
	# Clear any previous overlays/selections
	print("Selection state")
	main.deselect_unit_for_movement() 
	main.attack_mode(false)
	
	if not signal_bus.is_connected("special_pressed", _on_special_pressed):
		signal_bus.special_pressed.connect(_on_special_pressed)

func exit() -> void:
	if signal_bus.is_connected("special_pressed", _on_special_pressed):
		signal_bus.special_pressed.disconnect(_on_special_pressed)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var cursor_pos = main.cursor_pos
		
		# 1. Select Own Unit -> Go to Movement
		if cursor_pos == main.current.cell:
			state_machine.change_state("MoveSelectionState")
			return
		
		# 2. Select Enemy -> (Optional) Target Mode without moving?
		# For now, we stick to your logic: Clicking an enemy here just inspects them (handled by Main._process)

func _on_special_pressed(toggle: bool, ability_id: int) -> void:
	state_machine.change_state("SpecialSelectionState", {
		"special": main.current.special_abilities[ability_id]})
