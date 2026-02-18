extends AbilityRange
class_name LineRange

@export var use_actor_rotation: bool = true

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
	if origin == null and use_actor_rotation and actor:
		cast_dir = _get_facing_direction()
	
	var start_dist = max(1, min_range)
	
	for r in range(start_dist, max_range + 1):
		var tile = start_point + (cast_dir * r)
		if grid.is_within_bounds(tile):
			tiles.append(tile)
		else:
			break

	return tiles
