extends BattleState

# 'msg' allows passing data between states (e.g. "attack_target": enemy)
"""
1. Select a target to approach
2. Approach target
3. If target in range, attack
4. Attack using a specific chain to combo status effects
"""

var current : AI_Character
var target : Character

func enter(_msg: Dictionary = {}) -> void:
	if not signal_bus.is_connected("walk_finished", _on_walk_finished):
		signal_bus.walk_finished.connect(_on_walk_finished)
	
	#Movement
	current = main.current
	target = current.current_targeting.acquire_target("Player", main.occupied_tiles)
	print("Target is: ", target.cname)
	var target_pos := main.get_nearest_surrounding_tile(current.cell, target.cell)
	move_to_target(target_pos)

func exit() -> void:
	if signal_bus.is_connected("walk_finished", _on_walk_finished):
		signal_bus.walk_finished.disconnect(_on_walk_finished)

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass
	
func move_to_target(target_pos : Vector3) -> void:
	main.select_unit_for_movement(current.cell, false)
	#var edges := main.find_edge_tiles(main.current_range)
	var shortest_dist := 999999999
	var actual_end := target_pos
	for i in main.current_range:
		var curr_dist := target_pos.distance_to(i)
		if target_pos.distance_to(i) <= shortest_dist:
			#print("Dist to ", i, " is ", target_pos.distance_to(i))
			actual_end = i
			shortest_dist = curr_dist
	#print(actual_end)
	
	
	main.get_node("ArrowMap").get_path_only(current.cell, actual_end, current.action_points)
	if main.get_node("ArrowMap").current_path.size() > 1:
		current.walk_along(main.get_node("ArrowMap").current_path)
	else:
		_on_walk_finished()
	
func _on_walk_finished() -> void:
	print("AI Walk FInished")
	current.ai_attack(target) #need to reference from special targeting mode
	
	current.action_points = 0
	state_machine.change_state("SelectionState")
		
