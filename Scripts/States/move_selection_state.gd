# misery/Scripts/States/move_selection_state.gd
extends BattleState


func enter(_msg: Dictionary = {}) -> void:
	main.select_unit_for_movement(main.current.cell)
	print("Move selection state")

func exit() -> void:
	# We DO NOT clear the overlay here immediately if transitioning to Moving, 
	# but main.deselect_unit_for_movement handles cleanup nicely.
	main.deselect_unit_for_movement()

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var cursor_pos = main.cursor_pos
		
		# 1. Clicked Self -> Cancel
		if cursor_pos == main.current.cell:
			state_machine.change_state("SelectionState")
			return
		# 2. Check for "Attack After Walk" (Clicking a red tile with an enemy)
		# We access 'attack_zone' from Main
		if cursor_pos in main.attack_zone and main.is_occupied_by_unit(cursor_pos):
			var target_unit = main.occupied_tiles.find_key(cursor_pos)
			if target_unit.is_in_group("Characters"):
				# Logic: Find nearest tile, pathfind, then queue attack
				_initiate_move(cursor_pos, true) 
				return

		# 3. Normal Move (Clicking a valid blue path point)
		# We check ArrowMap path size or overlay validity
		if main.get_node("ArrowMap").current_path.size() > 1:
			_initiate_move(cursor_pos, false)

func _initiate_move(target_cell: Vector3, is_attack_queued: bool) -> void:
	var move_target := target_cell
	var surrounding_tiles := []
	
	for dir in DIRECTIONS:
		surrounding_tiles.append(main.current.cell+dir)
	
	if move_target in surrounding_tiles and is_attack_queued:
		state_machine.change_state("AttackTargetingState", {
			"auto_target": target_cell
		})
		return
	
	# If attacking, we need the nearest valid standable tile, not the enemy tile itself
	if is_attack_queued:
		move_target = main.get_nearest_surrounding_tile(main.current.cell, target_cell)
		# Force the ArrowMap to redraw path to this new valid tile so 'current_path' is correct
		main.get_node("ArrowMap").draw(main.current.cell, move_target, main.current.action_points)

	# Execute Move
	main.current.walk_along(main.get_node("ArrowMap").current_path)
	
	# Transition to Blocking State
	state_machine.change_state("MovingState", {
		"attack_after_walk": is_attack_queued,
		"target_pos": target_cell # Remember where the enemy was
	})
