extends AbilityRange
class_name DiamondRange

func get_tiles_in_range(origin: Variant = null, _direction: Vector3 = Vector3.FORWARD) -> Array[Vector3]:
	var tiles: Array[Vector3] = []
	
	# 1. Resolve Start Point (Matching your original logic)
	var start_point: Vector3
	if origin != null:
		start_point = origin
	elif actor:
		start_point = actor.cell
	else:
		return tiles # No valid start point

	if not grid:
		grid = preload("res://Resources/Grid.tres")

	# 2. Fetch the physical floor tiles from the base class helper
	var walkable = walkable_cells

	# 3. 3D Volume Scan (Mathematically equivalent to a 3D BFS)
	for x in range(-max_range, max_range + 1):
		for z in range(-max_range, max_range + 1):
			for y in range(-max_range, max_range + 1):
				
				# 3D Manhattan Distance: Each step of height (y) costs 1 range
				var current_dist = abs(x) + abs(y) + abs(z)
				
				# Add to results if inside min/max range
				if current_dist >= min_range and current_dist <= max_range:
					var target_tile = start_point + Vector3(x, y, z)
					
					# "Cast Down" check: Ensure the tile is actually a physical floor
					# This implicitly acts as your bounds check, since walkable cells are always in bounds
					if walkable.has(target_tile):
						tiles.append(target_tile)
						
	return tiles
