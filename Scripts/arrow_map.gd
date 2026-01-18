extends GridMap

@export var grid: Resource

var _pathfinder: PathFinder

var current_path := PackedVector3Array()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialise(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)
	
func draw(path_start: Vector3, path_end: Vector3) -> void:
	clear()
	current_path = _pathfinder.calculate_point_path(path_start, path_end)
	#print(current_path)
	var prev_cell = path_start
	for i in current_path.size():
		var cell = current_path[i]
		var cell_pos = local_to_map(cell)
		var rot = Basis.IDENTITY   # get_cell_item_basis(cell_pos).looking_at(map_to_local(prev_cell))
		#print(cell, prev_cell)
		#print(cell_pos)
		if i != 0:
			if cell == current_path[-1]:

				if cell - prev_cell == Vector3(1, 0, 0):
					rot = rot.rotated(Vector3.UP, -PI/2)
				elif cell - prev_cell == Vector3(-1, 0, 0):
					rot = rot.rotated(Vector3.UP, PI/2)
				elif cell - prev_cell == Vector3(0, 0, 1):
					rot = rot.rotated(Vector3.UP, PI)
				
				set_cell_item(cell, 1, get_orthogonal_index_from_basis(rot)) #22
			elif ((cell - prev_cell).abs() == Vector3(0,0,1) and (cell - current_path[i+1]).abs() == Vector3(1,0,0)) or ((cell - prev_cell).abs() == Vector3(1,0,0) and (cell - current_path[i+1]).abs() == Vector3(0,0,1)):
				
				if (prev_cell - cell == Vector3(-1, 0, 0) and current_path[i+1] - cell == Vector3(0, 0, 1)) or (prev_cell - cell == Vector3(0, 0, 1) and current_path[i+1] - cell == Vector3(-1, 0, 0)):
					rot = rot.rotated(Vector3.UP, -PI)
				elif (prev_cell - cell == Vector3(1, 0, 0) and current_path[i+1] - cell == Vector3(0, 0, 1)) or (prev_cell - cell == Vector3(0, 0, 1) and current_path[i+1] - cell == Vector3(1, 0, 0)):
					rot = rot.rotated(Vector3.UP, -PI/2)
				elif (prev_cell - cell == Vector3(-1, 0, 0) and current_path[i+1] - cell == Vector3(0, 0, -1)) or (prev_cell - cell == Vector3(0, 0, -1) and current_path[i+1] - cell == Vector3(-1, 0, 0)):
					rot = rot.rotated(Vector3.UP, PI/2)
				set_cell_item(cell, 2, get_orthogonal_index_from_basis(rot))
			else:
				if cell - prev_cell == Vector3(1,0,0) or cell - prev_cell == Vector3(-1,0,0):
					rot = rot.rotated(Vector3.UP, PI/2)
				set_cell_item(cell, 0, get_orthogonal_index_from_basis(rot))
		prev_cell = cell
	#print(get_used_cells())

func stop() -> void:
	_pathfinder = null
	clear()
