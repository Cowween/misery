extends AbilityRange
class_name LineRange

@export var use_actor_rotation: bool = true

func get_tiles_in_range() -> Array[Vector3]:
	var tiles: Array[Vector3] = []
	
	if not actor or not grid:
		return tiles

	var center = actor.cell
	
	if min_range == 0:
		tiles.append(center)
	
	var direction = _get_facing_direction()
	var start_dist = max(1, min_range)
	
	for r in range(start_dist, max_range + 1):
		var tile = center + (direction * r)
		
		if grid.is_within_bounds(tile):
			tiles.append(tile)
		else:
			break

	return tiles

func _get_facing_direction() -> Vector3:
	if not use_actor_rotation or not actor:
		return Vector3.FORWARD

	var forward = -actor.global_transform.basis.z
	if abs(forward.x) > abs(forward.z):
		return Vector3(sign(forward.x), 0, 0)
	else:
		return Vector3(0, 0, sign(forward.z))
