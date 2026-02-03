extends AbilityRange
class_name ConeRange

func get_tiles_in_range() -> Array[Vector3]:
	var tiles: Array[Vector3] = []
	
	if not actor or not grid:
		return tiles

	var center = actor.cell
	
	if min_range == 0:
		tiles.append(center)

	var direction = _get_facing_direction()
	
	# Calculate lateral (right) vector for width expansion
	var lateral_dir = Vector3.ZERO
	if direction.z != 0: 
		lateral_dir = Vector3(1, 0, 0) # If facing Z, lateral is X
	else:
		lateral_dir = Vector3(0, 0, 1) # If facing X, lateral is Z

	var start_dist = max(1, min_range)

	for r in range(start_dist, max_range + 1):
		var spine_pos = center + (direction * r)
		
		# 90-degree cone width logic: width expands by 1 on each side per step
		# At distance 1: width is -1 to 1 (3 tiles)
		# At distance 2: width is -2 to 2 (5 tiles)
		for w in range(-r, r + 1):
			var tile = spine_pos + (lateral_dir * w)
			
			if grid.is_within_bounds(tile):
				tiles.append(tile)

	return tiles

func _get_facing_direction() -> Vector3:
	if not actor:
		return Vector3.FORWARD

	var forward = -actor.global_transform.basis.z
	if abs(forward.x) > abs(forward.z):
		return Vector3(sign(forward.x), 0, 0)
	else:
		return Vector3(0, 0, sign(forward.z))
