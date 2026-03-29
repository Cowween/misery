extends Node
class_name PathFinder

const DIRECTIONS = [Vector3.BACK, Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]
const MAX_STEP_HEIGHT = 1 # Defines how steep a slope a unit can climb

var _grid: Resource
var _astar := AStar3D.new()
var _terrain_cache := {}

func _init(grid: Grid, walkable_cells: Array, terrain_cache: Dictionary) -> void:
	_grid = grid
	_terrain_cache = terrain_cache
	var cell_mapping := {}
	for cell in walkable_cells:
		cell_mapping[cell] = _grid.as_index(cell)
	_add_and_connect_points(cell_mapping)
	
func calculate_point_path(start: Vector3, end: Vector3) -> PackedVector3Array:
	var start_index = _grid.as_index(start)
	var end_index = _grid.as_index(end)
	
	if _astar.has_point(start_index) and _astar.has_point(end_index):
		return _astar.get_point_path(start_index, end_index)
	else:
		return PackedVector3Array()
	
func _add_and_connect_points(cell_mappings: Dictionary) -> void:
	for point in cell_mappings:
		_astar.add_point(cell_mappings[point], point)
	
	for point in cell_mappings:
		for neighbour_index in find_neighbouring_indices(point,cell_mappings):
			_astar.connect_points(cell_mappings[point], neighbour_index)
	
func find_neighbouring_indices(cell: Vector3, cell_mappings: Dictionary) -> Array:
	var out := []

	for direction in DIRECTIONS:
		for y_offset in [0, 1, -1]:
			var neighbour = cell + direction + Vector3(0, y_offset, 0)
			if not cell_mappings.has(neighbour): continue
			
			var next_rules = _terrain_cache.get(neighbour, {"is_stair": false, "cost": 1})
			
			# Abstract Vertical Check
			if neighbour.y != cell.y:
				var curr_rules = _terrain_cache.get(cell, {"is_stair": false})
				if not next_rules.is_stair and not curr_rules.is_stair:
					continue
			
			if not _astar.are_points_connected(cell_mappings[cell], cell_mappings[neighbour]):
				# BAKE COST INTO ASTAR WEIGHT: 
				# This ensures pathfinding actually picks the shortest AP path, not just shortest tile path
				_astar.set_point_weight_scale(cell_mappings[neighbour], next_rules.cost)
				out.push_back(cell_mappings[neighbour])
			break 
	return out
