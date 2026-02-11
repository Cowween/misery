# misery/Scripts/States/selection_state.gd
extends BattleState

func enter(_msg: Dictionary = {}) -> void:
	# Clear any previous overlays/selections
	print("Selection state")
	main.deselect_unit_for_movement(Vector3.ZERO) 
	main.attack_mode(false)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var cursor_pos = main.cursor_pos
		
		# 1. Select Own Unit -> Go to Movement
		if cursor_pos == main.current.cell:
			state_machine.change_state("MoveSelectionState")
			return
		
		# 2. Select Enemy -> (Optional) Target Mode without moving?
		# For now, we stick to your logic: Clicking an enemy here just inspects them (handled by Main._process)
