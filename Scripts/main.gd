extends Node

const DIRECTIONS = [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]

@export var grid : Resource = preload("res://Resources/Grid.tres")
@export var cursor_offset := Vector3(0,1,0)

@onready var camera = $CameraContainer/CameraPivot/Camera3D
@onready var pivot = $CameraContainer/CameraPivot

var occupied_tiles = {}
#initiative
var queue = []
var queue_in_action = []
var current
var dragging = false
var unit_selected_for_movement = false
var cursor_pos = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	
	#Initiative
	queue = get_tree().get_nodes_in_group("Characters")
	queue.sort_custom(sort_queue)
	for i in queue:
		i.SignalBus = $SignalBus
	queue_in_action = queue.duplicate()
	current = queue_in_action.pop_front()
	occupied_tiles[current] = null
	$BattleUI.AP = current.action_points
	$BattleUI.HP_max = current.max_hp
	$BattleUI.HP = current.hp
	
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
	#print(occupied_tiles)
	$Cursor.position = grid.calculate_map_position(cursor_pos+cursor_offset)
	#print(cursor_pos)
	#print($Cursor.position)
	#print(current_pos, target_pos)
	if unit_selected_for_movement:
		$ArrowMap.draw(current.cell, cursor_pos)
	#print($Ground.local_to_map($CameraPivot/Camera3D.get_cursor_world_position()))
	#print(occupied_tiles)
func _flood_fill(cell: Vector3, max_distance: int) -> Array:
	var array := []
	var queue := [cell]
	var came_from := {}
	var cost := {}
	
	cost[cell] = max_distance
	came_from[cell] = null
	while not queue.is_empty():
		var current = queue.pop_front()

		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue
		if cost[current] < 0:
			continue
			
		#cost system for pathfinding for future implementation with different cost terrains


		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector3 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue
			if not came_from.has(coordinates):
				cost[coordinates] = cost[current] - 1
				came_from[coordinates] = current

			queue.append(coordinates)
	return array

func select_unit_for_movement(cell: Vector3) -> void:
	if cell != current.cell:
		return
	var points = _flood_fill(current.cell, current.action_points)
	for i in points:
		#await get_tree().create_timer(0.1).timeout 
		$Overlay.set_cell_item(i, 0)
	$ArrowMap.initialise(points)
	unit_selected_for_movement = true
	
func deselect_unit_for_movement(cell: Vector3) -> void:
	$ArrowMap.stop()
	unit_selected_for_movement = false
	$Overlay.clear()
	
func is_occupied(cell: Vector3) -> bool:
	return is_occupied_by_unit(cell)
	
func is_occupied_by_unit(cell: Vector3) -> bool:
	var occupied_tiles := []
	
	for i in queue:
		occupied_tiles.append(i.cell)
	
	return cell in occupied_tiles
	
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
		if unit_selected_for_movement:
			if cursor_pos == current.cell:
				deselect_unit_for_movement(cursor_pos)
			else:
				current.walk_along($ArrowMap.current_path)
				deselect_unit_for_movement(cursor_pos)
				
		else:
			select_unit_for_movement(cursor_pos)
			
func attack(target) -> void:
	pass


func _on_signal_bus_action_done() -> void:
	if queue_in_action.size() == 0:
		queue_in_action = queue.duplicate()

	var tile = grid.calculate_grid_coordinates(Vector3i(current.position.x, 0, current.position.z))
	occupied_tiles[current] = tile
	current = queue_in_action.pop_front()
	current.initialise()
	occupied_tiles[current] = null
	current.current_basis = current.transform.basis
	pivot.basis = current.basis
	$CameraContainer.position = current._path_follow.global_position
	$BattleUI.AP = current.action_points
	


func _on_signal_bus_walk_finished() -> void:
	$BattleUI.AP = current.action_points
