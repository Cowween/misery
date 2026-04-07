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
@onready var debug_cursor := $"UI elements/BattleUI/DebugCursorPos"
@onready var ground := $Ground
@onready var terrain := $Terrain # Your new terrain GridMap


var walkable_cells : Array[Vector3] = []
var levels : Array[Vector3]
var cached_terrain_data := {}    # Stores Vector3: rules_dict
#var occupied_tiles := {} #In the format of Character: Cell
var cell_occupants := {} # Maps Vector3 -> Character
# Initiative variables
var queue := []
var queue_in_action := []
var current : Character

# Input / Global variables
var dragging := false
var cursor_pos := Vector3()
var attack_zone := [] # Stores just the red tiles now
var current_target : Character
var focus_target := false
var current_range : Array[Vector3]

# == INITIALIZATION ==
func _ready() -> void:
	
	_cache_terrain()
	_get_levels()
	
	$ArrowMap.cached_terrain = cached_terrain_data
	
	#print(cached_terrain_data.get(Vector3(4,0,5)))
	
	# Initiative Setup
	walkable_cells = ground.get_walkable_cells()
	queue = get_tree().get_nodes_in_group("Characters")
	queue.sort_custom(sort_queue)
	for i in queue:
		i.terrain_cache = cached_terrain_data
		i.signal_bus = $SignalBus
		
	
	
	queue_in_action = queue.duplicate()
	current = queue_in_action.pop_front()
	queue_in_action.append(current)
	battle_ui.update_initiative(queue_in_action)
	$Arrow.target = current._path_follow
	current.turn_start()
	
	# UI Updates
	battle_ui.update_ap(current.action_points)
	battle_ui.update_p_health(current.max_hp, current.hp)
	battle_ui.update_adrenaline(current.adrenaline, current.max_adr)
	
	# Camera Setup
	$CameraContainer.position = current.position
	pivot.basis = current.basis
	
	# Battle State
	state_machine.initialise()
	state_machine.signal_bus = $SignalBus
	refresh_occupancy()
	#print("cell occcu list", cell_occupants)


# == MAIN LOOP ==
func _process(_delta: float) -> void:
	# 1. Global Cursor Tracking
	var raw_pos = grid.calculate_grid_coordinates(camera.get_cursor_world_position())
	raw_pos = grid.clamp(raw_pos)
	
	# NEW: Force cursor to snap to the nearest actual floor tile height
	var snapped = false
	for y_offset in range(-2, 3): # Check slightly above and below the mouse hit
		var check_pos = Vector3(raw_pos.x, raw_pos.y + y_offset, raw_pos.z)
		if walkable_cells.has(check_pos):
			cursor_pos = check_pos
			snapped = true
			break
			
	# Fallback if no floor is under the mouse
	if not snapped:
		cursor_pos = raw_pos

	$Cursor.position = grid.calculate_map_position(cursor_pos) + cursor_offset
	debug_cursor.text = str($Cursor.position) + ", " + str(cursor_pos)
	# 2. Hover Info (Always Active)
	if not focus_target:
		if cursor_pos in cell_occupants.keys():
			var target : Character = get_character_at(cursor_pos)
			battle_ui.display_enemy_info(target)
		else:
			battle_ui.hide_enemy_info()

	# 3. Path Drawing (Only if ArrowMap is active)
	if $ArrowMap._pathfinder and current.is_in_group("Player"):
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
func select_unit_for_movement(cell: Vector3, draw_overlay:=true) -> void:
	if cell != current.cell: return
	
	# A. Get Movement Grid (Blue Tiles)
	var move_grid_data := get_movement_grid(current)
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
	if draw_overlay:
		
		for t in valid_move_tiles:
			$Overlay.set_cell_item(t, 0) # 0 = Blue
		
		attack_zone = red_tiles
		for t in red_tiles:
			$Overlay.set_cell_item(t, 1) # 1 = Red

	# E. Initialize Pathfinding
	var points : Array[Vector3] = []
	#print(valid_move_tiles)
	for t in valid_move_tiles:
		if not is_occupied(t):
			points.append(t)
	current_range = points
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
	if not (target_coordinates in attack_zone and target_coordinates in cell_occupants.keys()):
		return
		
	var target = get_character_at(target_coordinates)
	if target and target.is_in_group("Characters"):
		current_target = target
		attack_interface.display_attacks(target, current)

func character_aiming(enable: bool) -> void:
	if enable:
		var tile = get_nearest_surrounding_tile(cursor_pos, current.cell)
		current._path_follow.look_at(grid.calculate_map_position(tile), Vector3(0,1,0), true)
		current._path_follow.rotation.x = 0
		current._path_follow.rotation.z = 0

# == PATHFINDING & UTILS ==
func _get_levels() -> void:
	for i in range(grid.size.y + 1):
		levels.append(Vector3(0, i, 0))
		
	#print(levels)
func _cache_terrain() -> void:
	cached_terrain_data.clear()
	print(terrain.get_used_cells())
	for cell in ground.get_used_cells():
		var v_cell = Vector3(cell)
		var index = terrain.get_cell_item(cell)
		cached_terrain_data[v_cell] = grid.get_rules(index)

# NEW: Calculates ONLY movement (Blue Tiles)
# Replaces the first half of _flood_fill
func get_movement_grid(moving_unit: Character) -> Dictionary:
	var move_grid := {} 
	var queue := [moving_unit.cell]
	move_grid[moving_unit.cell] = moving_unit.action_points
	
	while not queue.is_empty():
		var curr = queue.pop_front()
		var current_ap = move_grid[curr]
		if current_ap <= 0: continue

		for direction in DIRECTIONS:
			for y_offset in [0, 1, -1]:
				var next = curr + direction + Vector3(0, y_offset, 0)
				
				# --- 1. OVERSIZED FOOTPRINT CHECK ---
				var fits_in_space = true
				for x_offset in range(moving_unit.side_length):
					for z_offset in range(moving_unit.side_length):
						var test_cell = next + Vector3(x_offset, 0, z_offset)
						
						if not grid.is_within_bounds(test_cell): fits_in_space = false; break
						if not walkable_cells.has(test_cell): fits_in_space = false; break
						if is_occupied(test_cell, moving_unit): fits_in_space = false; break
					
					if not fits_in_space: break
				
				if not fits_in_space: continue 
				
				var next_rules = cached_terrain_data.get(next, grid.get_rules(-1))
				if not next_rules.passable: continue
				
				# --- 2. STAIR / HEIGHT CHECK ---
				if next.y != curr.y:
					var curr_rules = cached_terrain_data.get(curr, grid.get_rules(-1))
					var valid_climb = (curr_rules.is_stair and next_rules.is_entrance) or \
									  (curr_rules.is_entrance and next_rules.is_stair)
					if not valid_climb:
						continue 
						
				# --- 3. APPLY COST ---
				var next_ap = current_ap - next_rules.cost
				if next_ap >= 0 and (not move_grid.has(next) or next_ap > move_grid[next]):
					move_grid[next] = next_ap
					queue.append(next)
					
				if walkable_cells.has(next): break
				
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
	var lowest_result := start # Default to start to avoid null errors
	var shortest_result := start
	for dir in DIRECTIONS:
		for i in levels:
			var temp = Vector3(end.x, 0, end.z) + dir + i
			if is_occupied(temp): continue
			if not temp in walkable_cells: continue # Safety check
			
			var d = start.distance_to(temp)
			if d < dist and temp.y == start.y:
				lowest_result = temp
				dist = d
			elif d < dist:
				shortest_result = temp
				dist = d
	if lowest_result == start:
		return shortest_result
	
	#print(lowest_result)
	return lowest_result
func refresh_occupancy() -> void:
	cell_occupants.clear()
	var all_units = get_tree().get_nodes_in_group("Characters")
	#print("all units", all_units)
	for unit in all_units:
		if unit:
			# Update the root cell based on their physical 3D location
			unit.cell = grid.calculate_grid_coordinates(unit.global_position)
			print(unit.cell)
			# Map every single tile in their footprint to this unit
			for footprint_tile in unit.get_occupied_cells():
				cell_occupants[footprint_tile] = unit
				
func get_character_at(check_cell: Vector3) -> Character:
	return cell_occupants.get(check_cell, null)

func is_occupied(check_cell: Vector3, ignore_unit: Character = current) -> bool:
	var occupant = get_character_at(check_cell)
	if occupant and occupant != ignore_unit:
		return true
	return false
	

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

	refresh_occupancy()
	current.turn_end()
	
	# Switch Turn
	current = queue_in_action.pop_front()
	queue_in_action.append(current)
	battle_ui.update_initiative(queue_in_action)
	current.initialise()
	$Arrow.target = current._path_follow
	current.turn_start()
	
	# Update Camera & UI
	current.current_basis = current.transform.basis
	pivot.basis = current.basis
	$CameraContainer.position = current._path_follow.global_position
	battle_ui.update_p_health(current.hp, current.max_hp)
	battle_ui.update_adrenaline(current.adrenaline, current.max_adr)
	
	state_machine.change_state("SelectionState")


func _on_signal_bus_unit_death(unit: Character) -> void:
	for i in unit.get_occupied_cells():
		cell_occupants.erase(i)
	queue.erase(unit)
	queue_in_action.erase(unit)
