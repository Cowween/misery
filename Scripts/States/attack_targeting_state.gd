# misery/Scripts/States/attack_targeting_state.gd
extends BattleState

func enter(msg: Dictionary = {}) -> void:
	print("Attack targeting state")
	main.attack_mode(true)
	
	# Handle "Attack After Walk" auto-targeting
	if msg.has("auto_target"):
		var target_pos = msg.get("auto_target")
		# We verify the target is still valid/in range
		if target_pos in main.attack_zone:
			main.target_mode(target_pos)

	# Listen for the UI confirming an attack
	if not main.get_node("SignalBus").is_connected("atk_pressed", _on_attack_executed):
		main.get_node("SignalBus").atk_pressed.connect(_on_attack_executed)

func exit() -> void:
	main.attack_mode(false)
	main.attack_interface.hide_attacks()
	if main.get_node("SignalBus").is_connected("atk_pressed", _on_attack_executed):
		main.get_node("SignalBus").atk_pressed.disconnect(_on_attack_executed)

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var cursor_pos = main.cursor_pos
		
		# Click Enemy -> Open Menu
		if cursor_pos in main.attack_zone and main.is_occupied_by_unit(cursor_pos):
			main.target_mode(cursor_pos)
		else:
			# Click Empty -> Cancel back to Selection
			state_machine.change_state("SelectionState")

# Called when the player actually clicks "Slash" or "Fireball" in the UI
func _on_attack_executed(_atk_id: int) -> void:
	# Main.gd handles the actual damage logic via its own signal connection
	# We just need to exit this state
	main.current.attack(main.current_target, _atk_id)
	state_machine.change_state("SelectionState")
