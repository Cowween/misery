extends Node
class_name PathFinder

const DIRECTIONS = [Vector3.BACK, Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]

var _grid: Resource

var _astar := AStar3D.new()

func _init(grid: Grid, walkable_cells: Array) -> void:
	
	_grid = grid
	
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
		var neighbour: Vector3 = cell + direction
		if not cell_mappings.has(neighbour):
			continue
		
		if not _astar.are_points_connected(cell_mappings[cell], cell_mappings[neighbour]):
			out.push_back(cell_mappings[neighbour])
	return out
