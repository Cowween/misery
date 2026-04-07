extends BattleState

var current: Character
var target_tile: Vector3

func enter(_msg: Dictionary = {}) -> void:
	current = main.current
	# We fire off the async turn sequence immediately
	print("AI State for ", current.cname)
	_execute_ai_turn()

func exit() -> void:
	pass # No more signal disconnecting needed!

func _execute_ai_turn() -> void:
	# GAME FEEL: Brief pause so the camera settles and player recognizes it's the enemy's turn
	await get_tree().create_timer(0.4).timeout
	main.select_unit_for_movement(current.cell, false)
	# ==========================================
	# STEP 1 & 2: DECIDE AND EXECUTE MOVEMENT
	# ==========================================
	var move_grid = main.get_movement_grid(current)
	target_tile = current.current_targeting.get_best_move("Player", move_grid, main.cell_occupants)
	
	if target_tile != current.cell:
		var arrow_map = main.get_node("ArrowMap")
		arrow_map.get_path_only(current.cell, target_tile, current.action_points)
		var path = arrow_map.current_path
		
		if path.size() > 1:
			current.walk_along(path)
			# INLINE WAIT: The script pauses here until the physical movement finishes
			await signal_bus.walk_finished
	
	# GAME FEEL: Brief pause after moving before striking
	await get_tree().create_timer(0.3).timeout
	
	# ==========================================
	# STEP 3 & 4: DECIDE AND EXECUTE ATTACK
	# ==========================================
	var attack_plan = current.current_targeting.get_best_attack_target(
	current.cell, 
	current.action_points, 
	"Player", 
	main.cell_occupants 
	)
	
	# Check if the array is valid and contains a target
	if attack_plan.size() >= 2 and attack_plan[0] != null:
		var target_char = attack_plan[0]
		var ability = attack_plan[1]
		
		current.attack(target_char, ability)
		
		# Optional: If your attack animations take time, you can add another await here!
		# await signal_bus.attack_finished 
		
	# ==========================================
	# STEP 5: END TURN
	# ==========================================
	#await get_tree().create_timer(0.5).timeout
	if current.action_points > 0:
		current.action_points = 0
