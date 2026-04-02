extends Resource
class_name Grid

# 1. Change size to Vector3! (Width, Height, Depth)
@export var size := Vector3(20, 10, 20) 
var cell_size := Vector3(2, 2, 2) : set = on_cell_size
const TERRAIN_RULES = {
	-1: {"cost": 1, "passable": true,  "is_stair": false, "is_entrance": false},
	2:  {"cost": 1, "passable": false, "is_stair": false, "is_entrance": false}, # Impassable
	1:  {"cost": 2, "passable": true,  "is_stair": false, "is_entrance": false}, # Difficult
	0:  {"cost": 1, "passable": true,  "is_stair": true,  "is_entrance": false}, # Stair
	3:  {"cost": 1, "passable": true,  "is_stair": false, "is_entrance": true }  # Stair Entrance
}

# Helper to safely get terrain data for any cell
func get_rules(terrain_index: int) -> Dictionary:
	return TERRAIN_RULES.get(terrain_index, TERRAIN_RULES[-1])
	
func on_cell_size(value):
	print("Change from", cell_size, "to", value)
	print_stack()
	cell_size = value
	


var _half_cell_size = cell_size / 2

func calculate_map_position(grid_position: Vector3) -> Vector3:
	# Calculate the exact world position
	#print(cell_size)
	return Vector3(
		grid_position.x * cell_size.x + _half_cell_size.x,
		grid_position.y * cell_size.y + cell_size.y, # Use full height to reach the 'roof'
		grid_position.z * cell_size.z + _half_cell_size.z
	)

func calculate_grid_coordinates(map_position: Vector3) -> Vector3:
	# We subtract half the cell's height so the top surface registers as the block underneath it
	var adjusted_pos = map_position - Vector3(0, _half_cell_size.y, 0)
	# Add a tiny epsilon (0.01) to prevent floating point rounding errors on the edges
	return (adjusted_pos / cell_size).floor()

# 2. Update bounds to check X, Y, AND Z
func is_within_bounds(cell_coordinates: Vector3) -> bool:
	var out := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	out = out and cell_coordinates.z >= 0 and cell_coordinates.z < size.z
	return out and cell_coordinates.y >= 0 and cell_coordinates.y < size.y

# 3. Update clamp to clamp X, Y, AND Z
func clamp(grid_position: Vector3) -> Vector3:
	var out := grid_position
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	out.z = clamp(out.z, 0, size.z - 1.0)
	return out

# 4. Make the index true 3D so paths don't overwrite each other
func as_index(cell: Vector3) -> int:
	return int(cell.x + (size.x * cell.z) + (size.x * size.z * cell.y))
