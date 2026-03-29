extends GridMap

@export var grid: Resource

var _pathfinder: PathFinder

var current_path := PackedVector3Array()
var cached_terrain := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialise(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells, cached_terrain)
	
func get_path_only(path_start: Vector3, path_end: Vector3, path_size := 0) -> void :
	clear()
	current_path = _pathfinder.calculate_point_path(path_start, path_end)
	if path_size != 0 and current_path.size() > path_size + 1:
		current_path.resize(path_size+1)
	
func draw(path_start: Vector3, path_end: Vector3, path_size := 0, is_occupied:=false) -> void:
	clear()
	current_path = _pathfinder.calculate_point_path(path_start, path_end)
	#print(current_path)
	if path_size != 0 and current_path.size() > path_size + 1:
		current_path.resize(path_size+1)
	if is_occupied:
		current_path.resize(current_path.size()-1)
	var prev_cell = path_start
	for i in current_path.size():
		var cell = current_path[i]
		var cell_pos = local_to_map(cell)
		var rot = Basis.IDENTITY   # get_cell_item_basis(cell_pos).looking_at(map_to_local(prev_cell))
		#print(cell, prev_cell)
		#print(cell_pos)
		if i != 0:
			# Flatten the direction vectors so height doesn't break rotation
			var dir_to_prev = (prev_cell - cell)
			dir_to_prev.y = 0
			var dir_from_prev = (cell - prev_cell)
			dir_from_prev.y = 0
			
			if cell == current_path[-1]:
				if dir_from_prev == Vector3(1, 0, 0): rot = rot.rotated(Vector3.UP, -PI/2)
				elif dir_from_prev == Vector3(-1, 0, 0): rot = rot.rotated(Vector3.UP, PI/2)
				elif dir_from_prev == Vector3(0, 0, 1): rot = rot.rotated(Vector3.UP, PI)
				set_cell_item(cell, 1, get_orthogonal_index_from_basis(rot)) 
			
			elif i + 1 < current_path.size():
				var dir_to_next = (current_path[i+1] - cell)
				dir_to_next.y = 0
				
				var is_corner = (dir_from_prev.abs() == Vector3(0,0,1) and dir_to_next.abs() == Vector3(1,0,0)) or (dir_from_prev.abs() == Vector3(1,0,0) and dir_to_next.abs() == Vector3(0,0,1))
				
				if is_corner:
					if (dir_to_prev == Vector3(-1, 0, 0) and dir_to_next == Vector3(0, 0, 1)) or (dir_to_prev == Vector3(0, 0, 1) and dir_to_next == Vector3(-1, 0, 0)):
						rot = rot.rotated(Vector3.UP, -PI)
					elif (dir_to_prev == Vector3(1, 0, 0) and dir_to_next == Vector3(0, 0, 1)) or (dir_to_prev == Vector3(0, 0, 1) and dir_to_next == Vector3(1, 0, 0)):
						rot = rot.rotated(Vector3.UP, -PI/2)
					elif (dir_to_prev == Vector3(-1, 0, 0) and dir_to_next == Vector3(0, 0, -1)) or (dir_to_prev == Vector3(0, 0, -1) and dir_to_next == Vector3(-1, 0, 0)):
						rot = rot.rotated(Vector3.UP, PI/2)
					set_cell_item(cell, 2, get_orthogonal_index_from_basis(rot))
				else:
					if dir_from_prev == Vector3(1,0,0) or dir_from_prev == Vector3(-1,0,0):
						rot = rot.rotated(Vector3.UP, PI/2)
					set_cell_item(cell, 0, get_orthogonal_index_from_basis(rot))
		prev_cell = cell
	#print(get_used_cells())

func stop() -> void:
	_pathfinder = null
	clear()
