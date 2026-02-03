extends AbilityRange
class_name DiamondRange

func get_tiles_in_range() -> Array[Vector3]:
	var tiles: Array[Vector3] = []
	
	if not actor or not grid:
		return tiles

	var start_point = actor.cell
	
	# BFS Initialization
	var queue: Array[Vector3] = [start_point]
	
	# Dictionary to track visited tiles and their distance from center
	# Key: Vector3 (tile coordinate), Value: int (distance)
	var visited = {start_point: 0}
	
	# Directions: Forward, Back, Left, Right (No diagonals for Diamond/Manhattan)
	var directions = [
		Vector3(0, 0, 1),
		Vector3(0, 0, -1),
		Vector3(1, 0, 0),
		Vector3(-1, 0, 0)
	]

	while not queue.is_empty():
		var current_tile = queue.pop_front()
		var current_dist = visited[current_tile]

		# 1. Add to results if within valid range (min/max)
		if current_dist >= min_range and current_dist <= max_range:
			tiles.append(current_tile)

		# 2. Stop expanding if we've reached the max range
		if current_dist >= max_range:
			continue

		# 3. Expand to neighbors
		for dir in directions:
			var next_tile = current_tile + dir
			
			# Check if tile is inside grid bounds and hasn't been visited yet
			if grid.is_within_bounds(next_tile) and not visited.has(next_tile):
				visited[next_tile] = current_dist + 1
				queue.append(next_tile)
	
	return tiles
