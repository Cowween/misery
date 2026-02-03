extends AbilityRange
class_name CrossRange

func get_tiles_in_range() -> Array[Vector3]:
	var tiles: Array[Vector3] = []
	
	if not actor or not grid:
		return tiles

	var center = actor.cell
	
	# Handle Center (Distance 0) explicitly if min_range is 0
	if min_range == 0:
		tiles.append(center)

	var directions = [
		Vector3(0, 0, 1),
		Vector3(0, 0, -1),
		Vector3(1, 0, 0),
		Vector3(-1, 0, 0)
	]

	# Start loop from max(1, min_range) to skip center if needed
	var start_dist = max(1, min_range)
	
	for dir in directions:
		for r in range(start_dist, max_range + 1):
			var tile = center + (dir * r)
			
			if grid.is_within_bounds(tile):
				tiles.append(tile)
			else:
				# Optimization: If we hit a map edge, stop checking further in this direction
				break
	return tiles
