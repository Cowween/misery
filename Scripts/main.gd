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
var attack_zone := [] # Stores just the red tiles now
var current_target : Character

# == INITIALIZATION ==
func _ready() -> void:
	# Initiative Setup
	queue = get_tree().get_nodes_in_group("Characters")
	queue.sort_custom(sort_queue)
	for i in queue:
		i.signal_bus = $SignalBus
		occupied_tiles[i] = grid.calculate_grid_coordinates(Vector3i(i.position.x, 0, i.position.z))
	
	queue_in_action = queue.duplicate()
	current = queue_in_action.pop_front()
	$Arrow.target = current._path_follow
	occupied_tiles[current] = null
	current.turn_start()
	
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
		var target : Character = occupied_tiles.find_key(cursor_pos)
		battle_ui.display_enemy_info(target)
	else:
		battle_ui.hide_enemy_info()

	# 3. Path Drawing (Only if ArrowMap is active)
	if $ArrowMap._pathfinder:
		var nearest_no_occupy = cursor_pos
		if is_occupied(cursor_pos):
			nearest_no_occupy = get_nearest_surrounding_tile(current.cell, cursor_pos)
		$ArrowMap.draw(current.cell, nearest_no_occupy, current.action_points)

# == INPUT HANDLING ==
func _unhandled_input(event: InputEvent) -> void:
	# 1. Global Camera Controls (Always accessible)
	_handle_camera_input(event)
	
	# 2. Delegate Gameplay Inputs to State Machine

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

func overlay_draw(cells: Array[Vector3], id: int) -> void:
	$Overlay.clear()
	for i in cells:
		$Overlay.set_cell_item(i, id)

# Called by MoveSelectionState
# REFACTORED: Now splits movement calculation from range expansion
func select_unit_for_movement(cell: Vector3) -> void:
	if cell != current.cell: return
	
	# A. Get Movement Grid (Blue Tiles)
	var move_grid_data := get_movement_grid(current.cell, current.action_points)
	var valid_move_tiles := move_grid_data.keys()
	
	# B. Find Edges for Attack Expansion
	var edges := find_edge_tiles(valid_move_tiles)
	
	# C. Get Attack Range from Active Ability (Polymorphic Expansion)
	var red_tiles := []
	var active_range_node := _get_active_range_node()
	
	if active_range_node:
		# Use the new generic logic (works for Diamond, Cone, Line)
		red_tiles = active_range_node.get_visual_expansion(edges, move_grid_data)
	else:
		# Fallback if no ability equipped: Use internal Diamond logic
		var fallback_range := DiamondRange.new()
		fallback_range.max_range = current.atk_range
		fallback_range.grid = grid
		red_tiles = fallback_range.get_visual_expansion(edges, move_grid_data)
		fallback_range.free()

	# D. Draw Overlays
	$Overlay.clear()
	for t in valid_move_tiles:
		$Overlay.set_cell_item(t, 0) # 0 = Blue
	
	attack_zone = red_tiles
	for t in red_tiles:
		$Overlay.set_cell_item(t, 1) # 1 = Red

	# E. Initialize Pathfinding
	var points := []
	for t in valid_move_tiles:
		if not is_occupied(t):
			points.append(t)
	$ArrowMap.initialise(points)

# Called by SelectionState / MoveSelectionState
func deselect_unit_for_movement(_cell: Vector3 = Vector3.ZERO) -> void:
	$ArrowMap.stop()
	$Overlay.clear()

# Called by AttackTargetingState
# REFACTORED: Uses the AbilityRange node to determine red squares
func attack_mode(enable: bool) -> void:
	if enable:
		$Overlay.clear()
		var red_tiles = []
		var active_range = _get_active_range_node()
		
		if active_range:
			# Get tiles from CURRENT standing position
			red_tiles = active_range.get_tiles_in_range(current.cell)
		else:
			var fallback = DiamondRange.new()
			fallback.max_range = current.atk_range
			fallback.grid = grid
			fallback.actor = current
			red_tiles = fallback.get_tiles_in_range(current.cell)
			fallback.free()
			
		attack_zone = red_tiles
		for t in red_tiles:
			$Overlay.set_cell_item(t, 1)
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

# NEW: Calculates ONLY movement (Blue Tiles)
# Replaces the first half of _flood_fill
func get_movement_grid(start_cell: Vector3, ap: int) -> Dictionary:
	var move_grid := {} # Stores cell: remaining_ap
	var queue := [start_cell]
	
	move_grid[start_cell] = ap 
	
	while not queue.is_empty():
		var curr = queue.pop_front()
		var current_ap = move_grid[curr]
		
		if current_ap <= 0:
			continue

		for direction in DIRECTIONS:
			var next = curr + direction
			
			if not grid.is_within_bounds(next): continue
			if is_occupied(next): continue # Block movement through units
			
			# Cost logic (can be expanded for terrain)
			var next_ap = current_ap - 1 
			
			if not move_grid.has(next) or next_ap > move_grid[next]:
				move_grid[next] = next_ap
				queue.append(next)
				
	return move_grid

# Helper to dynamically find the Range Node on the character's active ability
func _get_active_range_node() -> AbilityRange:
	if current.attack_abilities.size() > 0:
		var ability = current.attack_abilities[0]
		# Find the child node that is an AbilityRange
		return ability.ability_range
	return null

func find_edge_tiles(tiles: Array) -> Array:
	var edges := []
	var tile_dict = {}
	for t in tiles: tile_dict[t] = true
	
	for tile in tiles:
		for dir in DIRECTIONS:
			if not tile_dict.has(tile + dir):
				edges.append(tile)
				break
	return edges

func get_nearest_surrounding_tile(start: Vector3, end: Vector3) -> Vector3:
	var dist := 9223372036854775807.0
	var result := start # Default to start to avoid null errors
	for dir in DIRECTIONS:
		var temp = end + dir
		if is_occupied(temp): continue
		if not grid.is_within_bounds(temp): continue # Safety check
		
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

func _on_battle_ui_attack() -> void:
	if state_machine.current_state.name == "AttackTargetingState":
		state_machine.change_state("SelectionState")
	else:
		state_machine.change_state("AttackTargetingState")

func _on_signal_bus_action_done() -> void:
	if queue_in_action.size() == 0:
		queue_in_action = queue.duplicate()

	var tile = grid.calculate_grid_coordinates(Vector3i(current.position.x, 0, current.position.z))
	occupied_tiles[current] = tile
	current.turn_end()
	
	# Switch Turn
	current = queue_in_action.pop_front()
	current.initialise()
	occupied_tiles[current] = null
	$Arrow.target = current._path_follow
	current.turn_start()
	
	# Update Camera & UI
	current.current_basis = current.transform.basis
	pivot.basis = current.basis
	$CameraContainer.position = current._path_follow.global_position
	battle_ui.update_p_health(current.hp, current.max_hp)
	
	state_machine.change_state("SelectionState")
