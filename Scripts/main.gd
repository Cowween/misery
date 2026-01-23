extends Node

const DIRECTIONS = [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]

@export var grid : Resource = preload("res://Resources/Grid.tres")
@export var cursor_offset := Vector3(0,1,0)

@onready var camera = $CameraContainer/CameraPivot/Camera3D
@onready var pivot = $CameraContainer/CameraPivot

var occupied_tiles = {} #occupied_tiles stores a dictionary with a whatever object as a key, and its coordinates as the value
#initiative
var queue = []
var queue_in_action = []
var current
var dragging = false
var unit_selected_for_movement = false
var cursor_pos = Vector3()
var attacking := false
var attack_zone := []
var attack_after_walk := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	
	#Initiative
	queue = get_tree().get_nodes_in_group("Characters")
	queue.sort_custom(sort_queue)
	for i in queue:
		i.SignalBus = $SignalBus
		occupied_tiles[i] = grid.calculate_grid_coordinates(Vector3i(i.position.x, 0, i.position.z))
	queue_in_action = queue.duplicate()
	current = queue_in_action.pop_front()
	occupied_tiles[current] = null
	$BattleUI.AP = current.action_points
	$BattleUI.update_p_health(current.max_hp, current.hp)
	
	#var points = _flood_fill(current.cell, current.action_points)
	#print(current.cell)
	#$ArrowMap.initialise(points)
	$CameraContainer.position  = current.position
	pivot.basis = current.basis


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		add_action($Character, 4)
	$Arrow.target = current._path_follow
	cursor_pos = grid.calculate_grid_coordinates(camera.get_cursor_world_position())
	cursor_pos = grid.clamp(cursor_pos)
	if cursor_pos in occupied_tiles.values():
		var target = occupied_tiles.find_key(cursor_pos)
		$BattleUI.display_enemy_info(target.cname, target.hp, target.max_hp) #display the stats of the target
	else:
		$BattleUI.hide_enemy_info()
	#print(occupied_tiles)
	$Cursor.position = grid.calculate_map_position(cursor_pos+cursor_offset)
	#print(cursor_pos)
	#print($Cursor.position)
	#print(current_pos, target_pos)
	if unit_selected_for_movement:
		var nearest_no_occupy = cursor_pos
		if is_occupied(cursor_pos):
			nearest_no_occupy = get_nearest_surrounding_tile(current.cell, cursor_pos)
		$ArrowMap.draw(current.cell, nearest_no_occupy, current.action_points)
	#print($Ground.local_to_map($CameraPivot/Camera3D.get_cursor_world_position()))
	#print(occupied_tiles)
func _flood_fill(cell: Vector3, max_distance: int, atk: int) -> Dictionary:
	#generate the instructions for the flood fill. 0 for standard movement, 1 for attack range
	var fill_inst := {}
	var queue := [cell]
	var came_from := {}
	var cost := {}
	var range := []
	var atk_range := []
	
	cost[cell] = max_distance
	came_from[cell] = null
	while not queue.is_empty():
		var current = queue.pop_front()

		if not grid.is_within_bounds(current):
			continue
		if current in range:
			continue
		if cost[current] < 0:
			continue
			
		#cost system for pathfinding for future implementation with different cost terrains

		range.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector3 = current + direction
			if is_occupied(coordinates):
	# Enemy tile is attackable
				continue
			if coordinates in range:
				continue
			if not came_from.has(coordinates):
				cost[coordinates] = cost[current] - 1
				came_from[coordinates] = current

			queue.append(coordinates)
	queue = find_edge_tiles(range)
	came_from = {}
	for i in queue:
		cost[i] = atk
		came_from[i] = null
	while not queue.is_empty():
		var current = queue.pop_front()
		if cost[current] < 0:
			continue
		if current in atk_range:
			continue
		if not grid.is_within_bounds(current):
			continue
			
		atk_range.append(current)
			
		for dir in DIRECTIONS:
			var next = current + dir

			if not came_from.has(next):
				cost[next] = cost[current] - 1
				came_from[next] = current
			queue.append(next)
	for i in range:
		fill_inst[i] = 0
		atk_range.erase(i)
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
		var temp = end+dir
		if is_occupied(temp):
			continue
		if start.distance_to(temp) < dist:
			result = temp
			dist = start.distance_to(temp)
	return result

func select_unit_for_movement(cell: Vector3) -> void:
	if cell != current.cell:
		return
	var fill_inst = _flood_fill(current.cell, current.action_points, current.atk_range)
	var points := []
	for i in fill_inst:
		#await get_tree().create_timer(0.1).timeout 
		$Overlay.set_cell_item(i, fill_inst[i])
		if not is_occupied(i):
			points.append(i)
	$ArrowMap.initialise(points)
	unit_selected_for_movement = true
	
func deselect_unit_for_movement(cell:Vector3) -> void:
	$ArrowMap.stop()
	unit_selected_for_movement = false
	$Overlay.clear()
	
func is_occupied(cell: Vector3) -> bool:
	return is_occupied_by_unit(cell)
	
func is_occupied_by_unit(cell: Vector3) -> bool:
	
	return cell in occupied_tiles.values()
	
func add_action(target, number):
	target.action_points += number

func sort_queue(a, b):
	if a.initiative > b.initiative:
		return true
	else:
		return false

func _input(event: InputEvent) -> void:

	if event.is_action("right_click"):
		if event.is_pressed():
	
			dragging = true
		else:
		
			dragging = false
	
	elif event is InputEventMouseMotion and dragging:
		$CameraContainer.rotation.y -= event.relative.x / pivot.sensitivity
		pivot.rotation.x -= event.relative.y / pivot.sensitivity
		
		pivot.rotation.x = clamp(pivot.rotation.x, -PI/4, PI/4)
	if event.is_action_pressed("left_click"):
		if attacking: #attack mode triggered by either pressing attack or pressing on a hostile square
			print("Attacking", cursor_pos, occupied_tiles)
			print(cursor_pos in occupied_tiles)
			if cursor_pos in attack_zone and cursor_pos in occupied_tiles.values(): #check if cursor position is inside the occupied tiles
				print("here")
				var target = occupied_tiles.find_key(cursor_pos) #convert the cursor to the actual target
				if target.is_in_group("Characters"): #checl for groups here
					current.attack(target)
					$Overlay.clear()
					attacking = false
					print(target.hp)
			
			
		elif unit_selected_for_movement:
			if cursor_pos == current.cell:
				deselect_unit_for_movement(cursor_pos)
			else:
				print(attack_zone)
				print(cursor_pos)
				if cursor_pos in attack_zone && occupied_tiles.values().has(cursor_pos) and occupied_tiles.find_key(cursor_pos).is_in_group("Characters"):
					attack_after_walk = true
					print("Attacking after walk")
					
				current.walk_along($ArrowMap.current_path)
				deselect_unit_for_movement(cursor_pos)
				
		else:
			select_unit_for_movement(cursor_pos)
			
func attack_mode() -> void:
	var fill_inst = _flood_fill(current.cell, 0, current.atk_range)
	for i in fill_inst:
			#await get_tree().create_timer(0.1).timeout 
		$Overlay.set_cell_item(i, fill_inst[i])
	

func _on_signal_bus_action_done() -> void:
	if queue_in_action.size() == 0:
		queue_in_action = queue.duplicate()

	var tile = grid.calculate_grid_coordinates(Vector3i(current.position.x, 0, current.position.z))
	occupied_tiles[current] = tile
	print(tile)
	current = queue_in_action.pop_front()
	current.initialise()
	occupied_tiles[current] = null
	current.current_basis = current.transform.basis
	pivot.basis = current.basis
	$CameraContainer.position = current._path_follow.global_position
	$BattleUI.AP = current.action_points
	$BattleUI.update_p_health(current.hp, current.max_hp)
	print("new hp", current.hp)
	


func _on_signal_bus_walk_finished() -> void:
	$BattleUI.AP = current.action_points
	if attack_after_walk:
		attack_after_walk = false
		attacking = true
		attack_mode()


func _on_battle_ui_attack() -> void:
	#If i want to attack: first turn to attack mode, then select target
	
	if attacking:
		$Overlay.clear()
		attacking = false
		print("atk off")
	else:
		attack_mode()
		attacking = true
		print("atk on")
