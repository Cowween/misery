extends Node
class_name Main

const DIRECTIONS = [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]

@export var grid : Resource = preload("res://Resources/Grid.tres")
@export var cursor_offset := Vector3(0,1,0)
@export var state_machine : BattleStateMachine

@onready var camera := $CameraContainer/CameraPivot/Camera3D
@onready var pivot := $CameraContainer/CameraPivot
@onready var battle_ui := $"UI elements/BattleUI"
@onready var attack_interface := $"UI elements/attack_interface"

var occupied_tiles := {} 
# Initiative variables
var queue := []
var queue_in_action := []
var current : Character

# Input / Global variables
var dragging := false
var cursor_pos := Vector3()
var attack_zone := []
var current_target : Character

# == INITIALIZATION ==
func _ready() -> void:
	# Initiative Setup
	queue = get_tree().get_nodes_in_group("Characters")
	queue.sort_custom(sort_queue)
	for i in queue:
		i.SignalBus = $SignalBus
		occupied_tiles[i] = grid.calculate_grid_coordinates(Vector3i(i.position.x, 0, i.position.z))
	
	queue_in_action = queue.duplicate()
	current = queue_in_action.pop_front()
	$Arrow.target = current._path_follow
	occupied_tiles[current] = null
	
	# UI Updates
	battle_ui.update_ap(current.action_points)
	battle_ui.update_p_health(current.max_hp, current.hp)
	
	# Camera Setup
	$CameraContainer.position = current.position
	pivot.basis = current.basis
	
	# Battle State
	state_machine.signal_bus = $SignalBus

# == MAIN LOOP ==
func _process(_delta: float) -> void:
	# 1. Global Cursor Tracking
	cursor_pos = grid.calculate_grid_coordinates(camera.get_cursor_world_position())
	cursor_pos = grid.clamp(cursor_pos)
	$Cursor.position = grid.calculate_map_position(cursor_pos + cursor_offset)
	
	# 2. Hover Info (Always Active)
	if cursor_pos in occupied_tiles.values():
		var target = occupied_tiles.find_key(cursor_pos)
		battle_ui.display_enemy_info(target.cname, target.hp, target.max_hp)
	else:
		battle_ui.hide_enemy_info()

	# 3. Path Drawing (Only if ArrowMap is active)
	if $ArrowMap._pathfinder:
		var nearest_no_occupy = cursor_pos
		if is_occupied(cursor_pos):
			nearest_no_occupy = get_nearest_surrounding_tile(current.cell, cursor_pos)
		$ArrowMap.draw(current.cell, nearest_no_occupy, current.action_points)

	# 4. Debug Action Add
	#if Input.is_action_just_pressed("ui_accept"):
		#add_action($Character, 4)

# == INPUT HANDLING ==
func _unhandled_input(event: InputEvent) -> void:
	# 1. Global Camera Controls (Always accessible)
	_handle_camera_input(event)
	
	# 2. Delegate Gameplay Inputs to State Machine
	#state_machine.handle_input(event)

func _handle_camera_input(event: InputEvent) -> void:
	if event.is_action("right_click"):
		if event.is_pressed():
	
			dragging = true
		else:
		
			dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		$CameraContainer.rotation.y -= event.relative.x / pivot.sensitivity
		pivot.rotation.x -= event.relative.y / pivot.sensitivity
		
		pivot.rotation.x = clamp(pivot.rotation.x, -PI/4, PI/4)

# == HELPER FUNCTIONS FOR STATES ==

# Called by MoveSelectionState
func select_unit_for_movement(cell: Vector3) -> void:
	if cell != current.cell:
		return
		
	# Uses the existing flood fill logic to determine blue tiles
	var fill_inst = _flood_fill(current.cell, current.action_points, current.atk_range)
	var points := []
	
	for i in fill_inst:
		# 0 = Movement (Blue)
		if fill_inst[i] == 0: 
			$Overlay.set_cell_item(i, 0)
			if not is_occupied(i):
				points.append(i)
		# 1 = Attack Border (Red) - Optional to show here
		elif fill_inst[i] == 1:
			$Overlay.set_cell_item(i, 1)

	$ArrowMap.initialise(points)

# Called by SelectionState / MoveSelectionState
func deselect_unit_for_movement(_cell: Vector3) -> void:
	$ArrowMap.stop()
	$Overlay.clear()

# Called by AttackTargetingState
func attack_mode(enable: bool) -> void:
	if enable:
		var fill_inst = _flood_fill(current.cell, 0, current.atk_range)
		for i in fill_inst:
			# 1 = Red Attack Range
			if fill_inst[i] == 1:
				$Overlay.set_cell_item(i, 1)
	else:
		$Overlay.clear()
		if attack_interface:
			attack_interface.hide_attacks()

# Called by AttackTargetingState
func target_mode(target_coordinates: Vector3) -> void:
	if not (target_coordinates in attack_zone and target_coordinates in occupied_tiles.values()):
		return
		
	var target = occupied_tiles.find_key(target_coordinates)
	if target.is_in_group("Characters"):
		current_target = target
		attack_interface.display_attacks(target, current)

func character_aiming(enable: bool) -> void:
	if enable:
		var tile = get_nearest_surrounding_tile(cursor_pos, current.cell)
		current._path_follow.look_at(grid.calculate_map_position(tile), Vector3(0,1,0), true)
		current._path_follow.rotation.x = 0
		current._path_follow.rotation.z = 0

# == PATHFINDING & UTILS ==
# Kept strictly as a calculation engine. Logic for *when* to call this is now in States.
func _flood_fill(cell: Vector3, max_distance: int, atk: int) -> Dictionary:
	var fill_inst := {}
	var queue := [cell]
	var came_from := {}
	var cost := {}
	var range := []
	var atk_range := []
	
	# Part 1: Movement (Blue)
	cost[cell] = max_distance
	came_from[cell] = null
	
	while not queue.is_empty():
		var curr = queue.pop_front()
		if not grid.is_within_bounds(curr): continue
		if curr in range: continue
		if cost[curr] < 0: continue
			
		range.append(curr)
		
		for direction in DIRECTIONS:
			var coordinates: Vector3 = curr + direction
			if is_occupied(coordinates): continue
			if coordinates in range: continue
			
			if not came_from.has(coordinates):
				cost[coordinates] = cost[curr] - 1
				came_from[coordinates] = curr
			queue.append(coordinates)

	# Part 2: Attack Range (Red) - from edges
	queue = find_edge_tiles(range)
	came_from = {} # Reset for attack calc
	for i in queue:
		cost[i] = atk
		came_from[i] = null
		
	while not queue.is_empty():
		var curr = queue.pop_front()
		if cost[curr] < 0: continue
		if curr in atk_range: continue
		if not grid.is_within_bounds(curr): continue
			
		atk_range.append(curr)
			
		for dir in DIRECTIONS:
			var next = curr + dir
			if not came_from.has(next):
				cost[next] = cost[curr] - 1
				came_from[next] = curr
			queue.append(next)
	
	# Final Assembly
	for i in range:
		fill_inst[i] = 0
		atk_range.erase(i) # Remove overlap
	
	attack_zone = atk_range
	for i in atk_range:
		fill_inst[i] = 1
		
	return fill_inst

func find_edge_tiles(tiles: Array) -> Array:
	var edges := []
	for tile in tiles:
		for dir in DIRECTIONS:
			var neighbor = tile + dir
			if not tiles.has(neighbor):
				edges.append(tile)
				break
	return edges

func get_nearest_surrounding_tile(start: Vector3, end: Vector3) -> Vector3:
	var dist := 9223372036854775807
	var result := Vector3()
	for dir in DIRECTIONS:
		var temp = end + dir
		if is_occupied(temp): continue
		
		var d = start.distance_to(temp)
		if d < dist:
			result = temp
			dist = d
	return result

func is_occupied(cell: Vector3) -> bool:
	return is_occupied_by_unit(cell)
	
func is_occupied_by_unit(cell: Vector3) -> bool:
	return cell in occupied_tiles.values()

func sort_queue(a, b):
	return a.initiative > b.initiative

func add_action(target, number):
	target.action_points += number

# == SIGNALS FROM UI / BUS ==
# Most logic delegates to the state machine or updates global tracking

func _on_battle_ui_attack() -> void:
	# Toggle attack state via the machine
	if state_machine.current_state.name == "AttackTargetingState":
		state_machine.change_state("SelectionState")
	else:
		state_machine.change_state("AttackTargetingState")

func _on_signal_bus_action_done() -> void:
	# Reset global state
	if queue_in_action.size() == 0:
		queue_in_action = queue.duplicate()

	var tile = grid.calculate_grid_coordinates(Vector3i(current.position.x, 0, current.position.z))
	occupied_tiles[current] = tile
	
	# Switch Turn
	current = queue_in_action.pop_front()
	current.initialise()
	occupied_tiles[current] = null
	$Arrow.target = current._path_follow
	
	# Update Camera & UI
	current.current_basis = current.transform.basis
	pivot.basis = current.basis
	$CameraContainer.position = current._path_follow.global_position
	battle_ui.update_p_health(current.hp, current.max_hp)
	
	# Reset State Machine to idle for new character
	state_machine.change_state("SelectionState")



func _on_signal_bus_atk_pressed(atk_id: int) -> void:
	print("atk pressed")
	current.attack(current_target, atk_id)
