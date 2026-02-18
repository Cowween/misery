extends AbilityRange
class_name DiagonalCrossRange

func get_tiles_in_range(origin: Variant = null, _direction: Vector3 = Vector3.FORWARD) -> Array[Vector3]:
	var tiles: Array[Vector3] = []
	
	var start_point: Vector3
	if origin != null:
		start_point = origin
	elif actor:
		start_point = actor.cell
	else:
		return tiles
		
	if not grid: grid = preload("res://Resources/Grid.tres")

	if min_range == 0:
		tiles.append(start_point)

	var directions = [
		Vector3(1, 0, 1), Vector3(1, 0, -1),
		Vector3(-1, 0, 1), Vector3(-1, 0, -1)
	]

	var start_dist = max(1, min_range)
	
	for dir in directions:
		for r in range(start_dist, max_range + 1):
			var tile = start_point + (dir * r)
			if grid.is_within_bounds(tile):
				tiles.append(tile)
			else:
				break

	return tiles
