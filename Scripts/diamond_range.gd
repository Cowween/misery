extends AbilityRange
class_name DiamondRange

func get_tiles_in_range(origin: Variant = null, _direction: Vector3 = Vector3.FORWARD) -> Array[Vector3]:
	var tiles: Array[Vector3] = []
	
	# 1. Resolve Start Point
	var start_point: Vector3
	if origin != null:
		start_point = origin
	elif actor:
		start_point = actor.cell
	else:
		return tiles # No valid start point

	if not grid:
		grid = preload("res://Resources/Grid.tres")

	# 2. BFS Logic to find tiles within distance
	var queue: Array[Vector3] = [start_point]
	var visited = {start_point: 0}
	
	var directions = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]

	while not queue.is_empty():
		var current_tile = queue.pop_front()
		var current_dist = visited[current_tile]

		# Add to results if inside min/max range
		if current_dist >= min_range and current_dist <= max_range:
			tiles.append(current_tile)

		# Stop expanding if we hit max range
		if current_dist >= max_range:
			continue

		for dir in directions:
			var next_tile = current_tile + dir
			
			# Check bounds
			if grid.is_within_bounds(next_tile) and not visited.has(next_tile):
				visited[next_tile] = current_dist + 1
				queue.append(next_tile)
	
	return tiles
