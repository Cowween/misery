extends AbilityRange
class_name DiagonalCrossRange

func get_tiles_in_range() -> Array[Vector3]:
	var tiles: Array[Vector3] = []
	
	if not actor or not grid:
		return tiles

	var center = actor.cell
	
	if min_range == 0:
		tiles.append(center)

	# Diagonal Directions: Forward-Right, Forward-Left, Back-Right, Back-Left
	var directions = [
		Vector3(1, 0, 1),
		Vector3(1, 0, -1),
		Vector3(-1, 0, 1),
		Vector3(-1, 0, -1)
	]

	var start_dist = max(1, min_range)
	
	for dir in directions:
		for r in range(start_dist, max_range + 1):
			var tile = center + (dir * r)
			
			if grid.is_within_bounds(tile):
				tiles.append(tile)
			else:
				break

	return tiles
