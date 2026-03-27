extends GridMap

# Generates the list of placed tiles
func get_walkable_cells() -> Array[Vector3]:
	var walkable_cells : Array[Vector3] = []
	for cell in get_used_cells():
		walkable_cells.append(Vector3(cell))
	return walkable_cells
