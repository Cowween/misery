extends AbilityRange
class_name ConeRange

func get_tiles_in_range(origin: Variant = null, direction: Vector3 = Vector3.FORWARD) -> Array[Vector3]:
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

	# Determine Direction
	var cast_dir = direction
	if origin == null and actor:
		cast_dir = _get_facing_direction()
	
	# Calculate lateral (right) vector for width
	var lateral_dir = Vector3.ZERO
	if cast_dir.z != 0: 
		lateral_dir = Vector3(1, 0, 0)
	else:
		lateral_dir = Vector3(0, 0, 1)

	var start_dist = max(1, min_range)

	for r in range(start_dist, max_range + 1):
		var spine_pos = start_point + (cast_dir * r)
		
		# Cone width: expands by 1 on each side per step
		for w in range(-r, r + 1):
			var tile = spine_pos + (lateral_dir * w)
			
			if grid.is_within_bounds(tile):
				tiles.append(tile)

	return tiles
