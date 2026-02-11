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

func get_visual_expansion(edge_tiles: Array, included_tiles: Dictionary) -> Array[Vector3]:
	var attack_tiles: Array[Vector3] = []
	var queue = edge_tiles.duplicate()
	var visited = included_tiles.duplicate() # Copy so we don't mess up original grid
	
	# We use a simple dictionary to track remaining range for the expansion
	var distance_tracker = {} 
	for tile in queue:
		distance_tracker[tile] = max_range # Start with full attack range

	var directions = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]

	while not queue.is_empty():
		var current = queue.pop_front()
		var current_dist = distance_tracker[current]
		
		if current_dist <= 0:
			continue
			
		for dir in directions:
			var next = current + dir
			
			# If we haven't visited this tile yet (it wasn't in movement, and not in attack yet)
			if grid.is_within_bounds(next) and not visited.has(next):
				visited[next] = 1 # Mark as visited
				distance_tracker[next] = current_dist - 1
				
				# Add to the red zone list
				attack_tiles.append(next)
				queue.append(next)
				
	return attack_tiles
